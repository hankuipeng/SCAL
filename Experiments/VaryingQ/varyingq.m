%% add necessary paths
addpath('../');

% add OPC to path
opc_path = '/home/hankui/Downloads/MATLAB_OPC';
addpath(genpath(opc_path));

% path to SCAL code
scal_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Algorithm/SCAL';
addpath(genpath(scal_path))

% path to COP-KSS code
copkss_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Algorithm/COPKSS';
addpath(genpath(copkss_path))

% path to SSC code
ssc_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Algorithm/SparseSubspaceClustering_SSC';
addpath(genpath(ssc_path))

clear opc_path scal_path copkss_path ssc_path

format short g


%% initial parameters
P = 30;
q = 4;
Nk = 200;
nvar = 0.15;

%
b = 10;
K = 3;

[X truth] = genSubspaceData_v2(P,q,Nk,K,nvar);    
N = size(X,1);
T = N/b;
rng('shuffle');
mem = datasample(1:K,N,'Replace',true);


% choose the best initialisation
ninit = 50;
for i=1:ninit
    init(i,:) = datasample(1:K,N,'Replace',true);
    [~, re] = KSCq(X, K, 50, q, init(i,:));
    tot_re(i) = sum(re);
end

[~,ind] = min(tot_re);
mem = init(ind,:);
clear init ind


%% version 12
[~,~,nmi_add] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_min,@InfAdd);
[~,~,nmi_del] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_max,@InfDel);
[~,~,nmi_both] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_max,@InfBoth);
[~,~,nmi_rs] = KSCALq_v12(X,K,q,mem,T,b,truth,@RandomSampling,@InfAdd);
[~,~,nmi_resid] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_max,@maxResid);
[~,~,nmi_margin] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_max,@minMargin);


%%
% [~,~,nmi_al] = KSCALq_v11(X,K,q-1,mem,T,b,truth,@query_v2);
% [~,~,nmi_rs] = KSCALq_v11(X,K,q-1,mem,T,b*K,truth,@RandomSampling);


%% plot against iterations
plot(nmi_al(1,:))
hold on
plot(nmi_rs(1,:))
hold on
xlabel('Iterations') 
ylabel('NMI') 
legend({'Active','Random'},'Location','southeast')
hold off


%% plot against number of questions asked
for i = 1:T
    
    Nques(i) = i*b;
    perf_rs(i) = nmi_rs(i);
    perf_add(i) = nmi_add(i);
    perf_del(i) = nmi_del(i);
    perf_both(i) = nmi_both(i);
    perf_resid(i) = nmi_resid(i);
    perf_margin(i) = nmi_margin(i);
    
end


%
plot(Nques./N,perf_both)
hold on
plot(Nques./N,perf_add)
hold on
plot(Nques./N,perf_del)
hold on
plot(Nques./N,perf_rs)
hold on
plot(Nques./N,perf_resid)
hold on
plot(Nques./N,perf_margin)
hold on
xlabel('Pct. of questions asked') 
ylabel('NMI') 
legend({'Both','Addition','Deletion','Random','MaxResid','MinMargin'},'Location','southeast')
hold off