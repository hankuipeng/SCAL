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
P = 2;
q = 1;
Nk = 200;
nvar = 0.05;

%
b = 10;
K = 3;

[X truth] = genSubspaceData_v2(P,q,Nk,K,nvar);    
N = size(X,1);
T = N/b;
mem = datasample(1:K,N,'Replace',true);


% plot 2-D data
scatter(X(truth==1,1),X(truth==1,2))
hold on
scatter(X(truth==2,1),X(truth==2,2))
hold on
scatter(X(truth==3,1),X(truth==3,2))
hold off


%%
scatter3(X(1:200,1),X(1:200,2),X(1:200,3))
hold on
scatter3(X(201:400,1),X(201:400,2),X(201:400,3))
hold on
scatter3(X(401:600,1),X(401:600,2),X(401:600,3))
hold on
set(gca,'visible','off')
%scatter3(X(601:800,1),X(601:800,2),X(601:800,3))
hold on 
%scatter3(X(801:1000,1),X(801:1000,2),X(801:1000,3))
hold on
%legend({'Cluster 1', 'Cluster 2', 'Cluster 3', 'Cluster 4', 'Cluster 5'},'Location','west')
hold off


%% choose the best initialisation
ninit = 50;
for i=1:ninit
    init(i,:) = datasample(1:K,N,'Replace',true);
    [~, re] = KSCq(X, K, 50, q, init(i,:));
    tot_re(i) = sum(re);
end

[~,ind] = min(tot_re);
mem = init(ind,:);
cluster_performance(mem,truth)

clear init ind


%% version 12
%mem = datasample(1:K,N,'Replace',true);
[~,~,nmi_add] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_min,@InfAdd);
[~,~,nmi_del] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_max,@InfDel);
[~,~,nmi_both] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_max,@InfBoth);
[~,~,nmi_rs] = KSCALq_v12(X,K,q,mem,T,b,truth,@RandomSampling,@InfAdd);
[~,~,nmi_resid] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_max,@maxResid);
[~,~,nmi_margin] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_max,@minMargin);
[~,~,nmi_bothprop] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_max,@InfBothAdj);


%%
queried_id = datasample(1:600,50,'replace',false);
[tmp,tot_re,~,~,~] = KSCCq(X, K, 50, q, mem, truth, queried_id);
cluster_performance(tmp,truth)


%% version 11
[~,~,nmi_al] = KSCALq_v11(X,K,q,mem,T,b,truth,@query_v2);
[~,~,nmi_rs] = KSCALq_v11(X,K,q,mem,T,b*K,truth,@RandomSampling);


%%
scatter3(X(asmt==1,1),X(asmt==1,2),X(asmt==1,3))
hold on
scatter3(X(asmt==2,1),X(asmt==2,2),X(asmt==2,3))
hold on
scatter3(X(diff_id,1),X(diff_id,2),X(diff_id,3))
hold on
scatter3(X(asmt==3,1),X(asmt==3,2),X(asmt==3,3))
hold on
scatter3(X(asmt==4,1),X(asmt==4,2),X(asmt==4,3))
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
    perf_bothprop(i) = nmi_bothprop(i);
    
end


%
plot(Nques./N,perf_bothprop)
hold on
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
legend({'Both (prop)','Both','Addition','Deletion','Random','MaxResid','MinMargin'},'Location','southeast')
hold off