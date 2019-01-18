%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generalization model (McDougle et al., 2017) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Samuel David McDougle; Princeton, NJ; December 2017
%% Email: sdmcdougle@gmail.com

clear;close all;clc;

%% this model captures the idea of "plan-based" generalization (McDougle et al., 2017), where the updating of
%% the slow process has its maximal point at the current state of the fast process
%% Generalization of the slow process is determined by a Gaussian around that point.

%% first we specify our "width of the generalizaion function" parameter
width = 37.76; % value from McDougle et al., 2017

%% number of trials
N = 420; 

%% rotation schedule
%% this simulation uses the ABCA* "rebound" paradigm used in Smith et al. (2006) and McDougle et al. (2015)
%% in this paradigm, after baseline (A), the agent experiences rotation 1 (B) for 200 trials, then the rotation is flipped (C) for 20 trials
%% The task ends with an "error clamp" period (A*), where no errors are experienced.
rotation = [zeros(1,100) 45*ones(1,200) -45*ones(1,20) zeros(1,100)];

%% initialize
slow_tiled = zeros(360,N+1); % implicit states, tiled at every integer degree value of a circle
simError = zeros(1,N); % error vector
slow = zeros(1,N+1); % max slow process (peak of gaussian). 
fast = zeros(1,N+1); % fast process. 
center = zeros(1,N); %% what determines the center of our slow process generalization function (e.g. fast process, target location, etc.)?

%% initial params (from McDougle et al. 2015)
% decay rates
A_slow = .99;
A_fast = .88;
% learning rates
height = .061; % learning rate on slow process (equivalent to the height of the gaussian)
B_fast = .87; % learning rate on fast process


for n = 1:N
    
    %% first, establish the center of implicit
    % fast-process-based generalization?
    center(n) = round(fast(n)) + 180; % have to add 180 for indexing/alignment purposes
    % target-based generalization?
    %center(n) = 180;              
    
    %% log visited slow states
    slow(n) = slow_tiled(center(n),n); % index slow state linked to current center of Gaussian    

    %% calculate error
    if n < 321 % pre error clamp block
    simError(n) = fast(n) + slow(n) - rotation(n);
    end
    
    %% update fast process
    fast(n+1) = A_fast*fast(n) - B_fast*simError(n);    
    
    %% update all slow process states
    %% (note: can also use a von Mises distribution here for more general applications)
    % shift vector to make current fast state the center of the Gaussian generalization function
    idx = 1:360; % index states
    idx_hat = circshift(idx',180-center(n)); % shift the vector into place
    % now update ALL slow process states 
    for j = 1:360
        slow_tiled(idx_hat(j),n+1) = A_slow*slow_tiled(idx_hat(j),n) - (height*exp(-1*(((j-180)^2)/(2*width^2))))*simError(n); % Gaussian update
    end    
    
    %% optional: in error clamp trial phase, fast process = 0 (McDougle et al., 2015)
    if n > 320
        fast(n+1) = 0;
    end    
end

%% PLOTS %%
figure;
colors = {[.55 .06 .61] [0 .45 .74] [.85 .33 .1] [.2 .6 .35]};
markersize = 1;
linewidth = 1;
fontsize = 9;

%% Task Paradigm
subplot(1,3,1);
line([1 100],[0 0],'linewidth',2);hold on;
text(40,5,'BL','fontsize',fontsize+1,'color','k');
line([101 101],[0 45],'linewidth',2);
line([101 300],[45 45],'linewidth',2);
line([300 300],[45 -45],'linewidth',2);
text(170,50,'R1 -45\circ','fontsize',fontsize+1,'color',[.55 .06 .61]);
line([301 320],[-45 -45],'linewidth',2);
line([320 320],[0 -45],'linewidth',2);
line([321 420],[0 0],'linewidth',2);
text(270,-50,'R2 45\circ','fontsize',fontsize+1,'color',[.55 .06 .61]);
text(330,5,'Clamp','fontsize',fontsize+1,'color','k');
axis([1 420 -60 60]);
set(gca,'ytick',-60:15:60);
ylabel('Angle');
title('Rotation Schedule');
legend('Solution','location','southwest');
box off;

%% Time-based Heatmap
subplot(1,3,2);
c=contourf(slow_tiled,20); 
colormap(jet);
caxis([-5,20]);
line([101 101],[1 360],'color','k');
line([321 321],[1 360],'color','k');
str = {'-180','-135','-90','-45','0','45','90','135','180'};
set(gca,'ytick',[1 45 90 135 180 225 270 315 360],'yticklabel',str);
ylabel('Slow Process States (degrees)');
title('Simulated States');

%% SIM
subplot(1,3,3);
% legen dummy code, task lines
plot(1,500,'color',colors{1},'linewidth',2);hold on;
plot(1,500,'color',colors{2},'linewidth',2);plot(1,500,'color',colors{3},'linewidth',2);plot(1,500,'--','color',[.4 .4 .4],'linewidth',1);
line([1 N],[0 0],'color','k');
line([101 101],[-60 60],'color','k');
line([321 321],[-60 60],'color','k');
plot(fast,'color',colors{2},'linewidth',linewidth);
plot(slow+fast,'color',colors{1},'linewidth',linewidth);
plot(slow,'color',colors{3},'linewidth',linewidth);
box off;
h = legend('Observed Output','Fast Process','Slow Process','location','southwest');
set(h,'fontSize',fontsize-2,'linewidth',1);
ylabel('Angle');
xlabel('Trial');
set(gca,'ytick',[-60 -45 -30 -15 0 15 30 45 60],'yticklabel',{'-60','-45','-30','-15','0','15','30','45','60'});
axis([0 N -60 60]);
title('Simulated Observed Behavior');


%% GLOBAL
set(gcf, 'units', 'centimeters', 'pos', [3.2808 12.4883 33.7961 8.0433])
set(gcf,'PaperPositionMode','auto');









