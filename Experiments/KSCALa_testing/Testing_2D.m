%% add necessary paths
addpath('../');

% add OPC to path
toolbox = '/home/hankui/Dropbox/Clustering/WorkLog/By_Language/MATLAB';
addpath(genpath(toolbox));

clear toolbox 
format short g


%% generate 2-D data 
P = 2;
q = 1;
Nk = 200;
K = 3;
noi = 0.1;
R = RotMatrix(degtorad(45)); % 30, 45, 120 degrees 
%R = RotMatrix(degtorad(10),[1 1 1]); % 30, 45, 120 degrees 

[X Truth] = GenSubDatR(P,q,Nk,K,noi,R);


%% plot the data 
scatter(X(Truth==1,1),X(Truth==1,2))
hold on
scatter(X(Truth==2,1),X(Truth==2,2))
hold on
scatter(X(Truth==3,1),X(Truth==3,2))
%set(gca,'visible','off')
hold off


%% set the parameters for AL
N = size(X,1);
b = 10;
T = N/b;
mem = datasample(1:K,N,'Replace',true);


%% Comparing the performance of Hungarian labelling update with Truth table update 
[perf, pur_both] = KSCALa(X,K,q,mem,T,b,Truth,@query0_max,@InfBoth,@LabUpdateHun);
[perf, pur_both_tru] = KSCALa(X,K,q,mem,T,b,Truth,@query0_max,@InfBoth,@LabUpdateTru);


%% plot the comparison
plot(pur_both)
hold on
plot(pur_both_tru)
hold off


%% Using truth table update, comparing various AL strategies 
[~, pur_both] = KSCALa(X,K,q,mem,T,b,Truth,@query0_max,@InfBoth,@LabUpdateTru);
[~, pur_add] = KSCALa(X,K,q,mem,T,b,Truth,@query0_min,@InfAdd,@LabUpdateTru);
[~, pur_del] = KSCALa(X,K,q,mem,T,b,Truth,@query0_max,@InfDel,@LabUpdateTru);
[~, pur_rs] = KSCALa(X,K,q,mem,T,b,Truth,@RandomSampling,@InfAdd,@LabUpdateTru);
[~, pur_resid] = KSCALa(X,K,q,mem,T,b,Truth,@query0_max,@maxResid,@LabUpdateTru);
[~, pur_margin] = KSCALa(X,K,q,mem,T,b,Truth,@query0_max,@minMargin,@LabUpdateTru);


%% plot by number of questions asked 
plot(pur_both)
hold on
plot(pur_add)
hold on
plot(pur_del)
hold on
plot(pur_rs)
hold on
plot(pur_resid)
hold on
plot(pur_margin)
hold on
xlabel('Number of questions asked') 
ylabel('Purity') 
legend({'Both','Addition','Deletion','Random', 'Resid', 'Margin'},'Location','southeast')
hold off



