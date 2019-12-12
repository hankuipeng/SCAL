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


%% 
P = 3;
q = 2;
Nk = 200;
K = 3;
nvar = 0.05;
%[X truth] = genSubspaceData_v3(P,q,Nk,K,nvar);
[X truth] = genSubspaceData_v2(P,q,Nk,K,nvar);
%[X,truth,~] = genSubspaceData(3,2,3,200,.1);
%X = X';


%% plot the data in 3-D
scatter3(X(1:200,1),X(1:200,2),X(1:200,3))
hold on
scatter3(X(201:400,1),X(201:400,2),X(201:400,3))
hold on
scatter3(X(401:600,1),X(401:600,2),X(401:600,3))
hold off


%% initial parameters
b = 10;
N = size(X,1);
T = N/(b*K);
mem = datasample(1:K,N,'Replace',true);


%% clustering with GPCA
groups=gpca_pda_spectralcluster(X',3);
cluster_performance(groups,truth)


%% clustering with SSC 
r = 0; affine = false; outlier = true; rho = 1; alpha = 20;
[missrate,C] = SSC(X',r,affine,alpha,outlier,rho,truth);
cluster_performance(C,truth)


%% clustering with KSC
%[asmt tot_re] = KSCq(X, K, T, 0, mem);
[asmt tot_re nmi_static] = KSCq_v2(X, K, T, q, mem,truth);
cluster_performance(asmt,truth)


%% plotting the result
scatter3(X(asmt==1,1),X(asmt==1,2),X(asmt==1,3))
hold on
scatter3(X(asmt==2,1),X(asmt==2,2),X(asmt==2,3))
hold on
scatter3(X(asmt==3,1),X(asmt==3,2),X(asmt==3,3))
hold off


%% plot the reconstruction error over iterations
plot(tot_re)


%% SCAL
%[~,re,nmi10] = KSCAL_v11(X,K,pct,mem,T,b,truth,@query);
%[~,nmi] = SCAL_v1(X,K,pct,mem,T,b,truth,@query);
%[~,~,nmi_ksc] = KSCALq_v10(X,K,0,asmt,T,b,truth,@query);
%[~,re,nmiv2_rand] = KSCALq_v10(X,K,0,mem,T,b,truth,@query_v2);
%[~,re,nmi_rand] = KSCALq_v10(X,K,0,mem,T,b,truth,@query);
%[~,~,nmi_del] = KSCAL_v8(X, K, pct, mem, T, b, truth);
[~,re,nmi] = KSCALq_v11(X,K,q-1,mem,T,b,truth,@query_v2);


%%
%[~,~,nmi_cop] = COPKSCAL_v2(X, K, 1, mem, T, b, truth);


%% Random sampling 
%[~,~,nmi_rs] = KSCAL_v10(X,K,pct,mem,T,b,truth,@RandomSampling);
%[~,nmi_rs] = SCAL_v1(X,K,pct,mem,T,b,truth,@RandomSampling);
[~,~,nmi_rs] = KSCALq_v11(X,K,q-1,mem,T,b*K,truth,@RandomSampling);
%[~,~,nmi_rs_ksc] = KSCALq_v10(X,K,0,asmt,T,b,truth,@RandomSampling);


%% plot against iterations
plot(nmi_static)
hold on
plot(nmi_rs)
hold on
%plot(nmi_rs_ksc)
hold on
plot(nmi)
hold on
%plot(nmi_ksc)
hold on
xlabel('Iterations') 
ylabel('NMI') 
legend({'KSC', 'KSC + Random', 'KSC + Active'},'Location','southeast')
hold off


%% plot in terms of percentage of questions asked 
for i = 1:T
    Nques(i) = i*b*K;
    perf_scal(i) = nmi(i);
    perf_rs(i) = nmi_rs(i);
    perf_static(i) = nmi_static(i);
end

%
plot(Nques./N,perf_scal)
hold on
plot(Nques./N,perf_rs)
hold on
plot(Nques./N,perf_static)
hold on
xlabel('Pct. of questions asked') 
ylabel('NMI') 
legend({'KSCC + Active', 'KSCC + Random', 'KSC'},'Location','southeast')
hold off
