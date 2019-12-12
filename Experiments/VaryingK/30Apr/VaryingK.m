%% add necessary paths
addpath('../');

% add OPC to path
opc_path = '/home/hankui/Downloads/MATLAB_OPC';
addpath(genpath(opc_path));

% path to SCAL code
scal_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Algorithm/SCAL/Functions/TidyVersion';
addpath(genpath(scal_path))

% path to SSC code
ssc_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Algorithm/SparseSubspaceClustering_SSC';
addpath(genpath(ssc_path))

clear opc_path scal_path ssc_path

format short g


%% generate 2-D data 
P = 3;
q = 2;
Nk = 200;
K = 3;
noi = 0.1;
R = RotMatrix(degtorad(30),[1 1 1]); % 30, 45, 120 degrees 
%R = RotMatrix(degtorad(45)); % 30, 45, 120 degrees 

[X Truth] = GenSubDatR(P,q,Nk,K,noi,R);

N = size(X,1);
b = 10;
T = N/b;


%% plot the data 
scatter3(X(1:200,1),X(1:200,2),X(1:200,3))
hold on
scatter3(X(201:400,1),X(201:400,2),X(201:400,3))
hold on
scatter3(X(401:600,1),X(401:600,2),X(401:600,3))
hold off


%% Using truth table update, comparing various AL strategies 
mem = datasample(1:K,N,'Replace',true);
[~, nmi_both] = KSCALa(X,K,q,mem,T,b,Truth,@query0_max,@InfBoth,@LabUpdateTru);
[~, nmi_margin] = KSCALa(X,K,q,mem,T,b,Truth,@query0_max,@minMargin,@LabUpdateTru);
[~, nmi_add] = KSCALa(X,K,q,mem,T,b,Truth,@query0_min,@InfAdd,@LabUpdateTru);
[~, nmi_del] = KSCALa(X,K,q,mem,T,b,Truth,@query0_max,@InfDel,@LabUpdateTru);
[~, nmi_rs] = KSCALa(X,K,q,mem,T,b,Truth,@RandomSampling,@InfAdd,@LabUpdateTru);
[~, nmi_resid] = KSCALa(X,K,q,mem,T,b,Truth,@query0_max,@maxResid,@LabUpdateTru);


%%
for i = 1:floor(T)
    
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
plot(Nques./N,perf_resid)
hold on
plot(Nques./N,perf_margin)
hold on
plot(Nques./N,perf_rs)
hold on
xlabel('Pct. of questions asked') 
ylabel('NMI') 
legend({'SCAL','SCAL-A','SCAL-D','MaxResid', 'MinMargin','Random'},'Location','southeast')
hold off


%%
save('k5_perf.mat')