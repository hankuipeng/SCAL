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


%% run all strategies without parallelisation 
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
 
% i = str2num(getenv('PBS_ARRAYID'));
% strategy_fh = str2func(strategy(i));
% influence_fh = str2func(influence(i));


%%
res = [];
tic;
parfor (i=1:4,4)
    
    [~, res(i,:)] = KSCALa(X,K,q,mem,T,b,Truth,strategy{i},influence{i},@LabUpdateTru);

end
p_time1 = toc;


%%
res = [];
tic;
parfor (i=1:4,4)
    [~, res(i,:)] = KSCALa(X,K,q,mem,T,b,Truth,strategy{i},influence{i},@LabUpdateTru, LASTN);
end
p_time2 = toc;


%% plotting the results
nmi_both = res(1,:);
nmi_resid = res(2,:);
nmi_margin = res(3,:);
nmi_rs = res(4,:);

for i = 1:floor(T)
    
    Nques(i) = i*b;
    perf_both(i) = nmi_both(i);
    perf_resid(i) = nmi_resid(i);
    perf_margin(i) = nmi_margin(i);
    perf_rs(i) = nmi_rs(i);
    
end

%
plot(Nques./N,perf_both)
hold on
plot(Nques./N,perf_resid)
hold on
plot(Nques./N,perf_margin)
hold on
plot(Nques./N,perf_rs)
hold on
xlabel('Pct. of questions asked') 
ylabel('NMI') 
legend({'SCAL','MaxResid', 'MinMargin','Random'},'Location','southeast')
hold off


%%
save('Parallelisation_res.mat')

