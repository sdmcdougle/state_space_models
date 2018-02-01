%% State Space Model of sensorimotor adaptation
%% Samuel David McDougle; Princeton, NJ; December 2017
%% Email: sdmcdougle@gmail.com
%% This code is used for very simple simulations of the standard "state space" model of sensorimotor adaptation, and one variation
%% References:  Smith et al., 2006; McDougle et al., 2016/2017
%% Try tweaking the different parameters

clear;close all;clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Single-process model %%
%%%%%%%%%%%%%%%%%%%%%%%%%%

%% This first model is just a standard, single-process state space model
%% number of trials
N = 420;
%% rotation schedule (50 baseline trials, 320 rotation trials, 50 washout trials)
rotation = [zeros(1,50) 45*ones(1,N-100) zeros(1,50)];
%% free parameters
A_single = .999; % retention factor
B_single = .035; % learning rate
%% initialize
state_single = zeros(1,N+1);
simError = zeros(1,N);

%% RUN MODEL %%
for n = 1:N
    %% error on trial n
    simError(n) = state_single(n) - rotation(n); % error = current state-perturbation
    %% update
    state_single(n+1) = A_single*state_single(n) - B_single*simError(n); % retained state + (learning rate*error)
end
% plot
figure;
plot(state_single,'linewidth',2);hold on;
plot([50 50],[-10 60],'--k');
plot([370 370],[-10 60],'--k');
plot([0 N],[0 0],'k');
axis([0 N -10 60]);
legend('State');
box off;
xlabel('Trial');
ylabel('Simulated Reaching Direction');
title('Single State Model');

%%%%%%%%%%%%%%%%%%%%%%%%
%% Dual-process model %%
%%%%%%%%%%%%%%%%%%%%%%%%

%% This first model uses two states - a fast and a slow state - a la Smith et al (2006)
%% number of trials
N = 420;
%% rotation schedule (50 baseline trials, 320 rotation trials, 50 washout trials)
rotation = [zeros(1,50) 45*ones(1,N-100) zeros(1,50)];
%% initial params
A_fast = .92; % retention factor
A_slow = .99; % retention factor

B_fast = .10; % learning rate
B_slow = .035; % learning rate

%% initialize
fast_state = zeros(1,N+1);
slow_state = zeros(1,N+1);
observed_state = zeros(1,N+1);
simError = zeros(1,N);

%% RUN MODEL %%
for n = 1:N
    %% error on trial n
    observed_state(n) = fast_state(n) + slow_state(n);
    simError(n) = observed_state(n) - rotation(n); % error = combined state - perturbation
    %% updates
    fast_state(n+1) = A_fast*fast_state(n) - B_fast*simError(n); % retained state + (learning rate*error)
    slow_state(n+1) = A_slow*slow_state(n) - B_slow*simError(n); % retained state + (learning rate*error)
    
end
figure;
plot(fast_state,'b','linewidth',2);hold on;
plot(slow_state,'r','linewidth',2);
plot(observed_state,'k','linewidth',2);
plot([50 50],[-10 60],'--k');
plot([370 370],[-10 60],'--k');
plot([0 N],[0 0],'k');
axis([0 N -10 60]);
legend('Fast Process','Slow Process','Observed Output');
box off;
xlabel('Trial');
ylabel('Simulated Reaching Direction/State');
title('Dual-Process Model');

