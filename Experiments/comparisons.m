%% add necessary paths
addpath('../');

% add OPC to path
opc_path = '/home/hankui/Downloads/MATLAB_OPC';
addpath(genpath(opc_path));
% path to SCAL code
scal_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Algorithm/SCAL';
addpath(genpath(scal_path))

copkss_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Algorithm/COPKSS';
addpath(genpath(copkss_path))


clear opc_path scal_path copkss_path asmt_varp


%% borrow the data example from Illustrative_ex.m
x = .01*(-100:100);
x = [x(1:100), x(102:201)];
N = size(x,2);

S1 = 5*x + 2;
noise1 = 5.*rand(1, N);
S1n = S1 + noise1;
X1 = [x;S1n]';

S2 = -10*x - 2;
X2 = [x;S2]';

X = [X1;X2];
K = 2;
truth = [ones(1,N) 2.*ones(1,N)]';

clear x X1 X2 S1 S2 S1n noise1


%% plotting
gscatter(X(:,1),X(:,2),truth);


%% 
[X truth] = genSubspaceData_v2(3,2,200,3,0.01);
%[X,truth,~] = genSubspaceData(3,2,3,200,.1);
%X = X';


%%
scatter3(X(1:200,1),X(1:200,2),X(1:200,3))
hold on
scatter3(X(201:400,1),X(201:400,2),X(201:400,3))
hold on
scatter3(X(401:600,1),X(401:600,2),X(401:600,3))
hold off


%% initial parameters
K = 3; 
%pct = 0.8; 
b = 10;
N = size(X,1);
T = N/b;
q = 1;
mem = round(rand(1,N)*K + 0.5)';


%%



%% SCAL
%[~,re,nmi10] = KSCAL_v11(X,K,pct,mem,T,b,truth,@query);
[~,nmi] = SCAL_v1(X,K,pct,mem,T,b,truth,@query);


%%
[~,~,nmi_cop] = COPKSCAL_v2(X, K, 1, mem, T, b, truth);


%% Random sampling 
%[~,~,nmi_rs] = KSCAL_v10(X,K,pct,mem,T,b,truth,@RandomSampling);
[~,nmi_rs] = SCAL_v1(X,K,pct,mem,T,b,truth,@RandomSampling);



%% 
plot(nmi_rs)
hold on
plot(nmi)
hold on
%plot(nmi_cop)
hold on
xlabel('Iterations') 
ylabel('NMI') 
legend({'Random', 'SCAL', 'COP-SCAL'},'Location','southeast')
hold off


%% plot the reconstruction error
plot(re)



