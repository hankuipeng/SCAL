% add OPC to path
opc_path = '~/Algorithms/MATLAB_OPC';
addpath(genpath(opc_path));

% path to SCAL code
scal_path = '~/Algorithms/SCAL';
addpath(genpath(scal_path))

clear opc_path scal_path

LASTN = maxNumCompThreads(40);

% generate 2-D data 
% P = 3;
% q = 2;
% Nk = 200;
% K = 3;
% noi = 0.05;
% R = RotMatrix(degtorad(60),[1 1 1]); % 30, 45, 120 degrees 
% %R = RotMatrix(degtorad(45)); % 30, 45, 120 degrees 
% 
% [X Truth] = GenSubDatR(P,q,Nk,K,noi,R);
% N = size(X,1);
% b = 10;
% T = N/b;
% mem = datasample(1:K,N,'Replace',true);
load('parallelisation.mat')

%% run all strategies without parallelisation 
% tic;
% [~, nmi_both] = KSCALa(X,K,q,mem,T,b,Truth,@query0_max,@InfBoth,@LabUpdateTru);
% [~, nmi_resid] = KSCALa(X,K,q,mem,T,b,Truth,@query0_max,@maxResid,@LabUpdateTru);
% [~, nmi_margin] = KSCALa(X,K,q,mem,T,b,Truth,@query0_max,@minMargin,@LabUpdateTru);
% [~, nmi_rs] = KSCALa(X,K,q,mem,T,b,Truth,@RandomSampling,@InfAdd,@LabUpdateTru);
% np_time1 = toc;
% 
% 
% %% run all strategies without parallelisation 
% tic;
% [~, nmi_both] = KSCALa(X,K,q,mem,T,b,Truth,@query0_max,@InfBoth,@LabUpdateTru, LASTN);
% [~, nmi_resid] = KSCALa(X,K,q,mem,T,b,Truth,@query0_max,@maxResid,@LabUpdateTru, LASTN);
% [~, nmi_margin] = KSCALa(X,K,q,mem,T,b,Truth,@query0_max,@minMargin,@LabUpdateTru, LASTN);
% [~, nmi_rs] = KSCALa(X,K,q,mem,T,b,Truth,@RandomSampling,@InfAdd,@LabUpdateTru, LASTN);
% np_time2 = toc;


%% parallelise all strategies
% strategy = ['@query0_max' '@query0_max' '@query0_max' '@RandomSampling'];
% influence = ['@InfBoth' '@maxResid' '@minMargin' '@InfAdd'];
strategy = {@query0_max,@query0_max,@query0_max,@RandomSampling};
influence = {@InfBoth,@maxResid,@minMargin,@InfAdd};
 
s = str2num(getenv('PBS_ARRAYID'));
strategy = strategy{s};
influence = influence{s};

tic;
[~, res] = KSCALa(X,K,q,mem,T,b,Truth,strategy,influence,@LabUpdateTru);
p_time1 = toc;


%%
tic;
[~, res] = KSCALa(X,K,q,mem,T,b,Truth,strategy,influence,@LabUpdateTru, LASTN);
p_time2 = toc;


%%
% save('Parallelisation_res',int2str(i),'.mat')
savefile = [func2str(influence),'.mat'];
save(savefile);
