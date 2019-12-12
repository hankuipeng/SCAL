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

clear opc_path scal_path copkss_path


%% K=4, P=100, q=10, noise = 0.05, 0.1, 0.2, 0.4
P = 100; % dimension of ambient space 
K = 4; % number of clusters 
Nk = 125; % number of data objects per cluster 
N = 500; % total number of data objects 
q = 10;
T = 50;
pct = 0.8;
mem = round(rand(1,N)*K + 0.5)';


%% initialisation
X_v9 = {};
noise = [.01 .05 .1 .15 .2];


%% without updating subspaces
nmi1_varp = [];
nmi5_varp = [];
nmi10_varp = [];

for noi = 1:length(noise)
    [X,truth,~] = genSubspaceData(P,q,K,Nk,noise(noi));
    X_store{q} = X';
    X = X';
    
    [asmt_varp re nmi1] = COPKSCAL_v1(X,K,pct,mem,T,1,truth);
    nmi1_varp(noi,:) = nmi1;
    
    %[asmt_varp re nmi5] = COPKSCAL_v1(X,K,pct,mem,T,5,truth);
    %nmi5_varp(noi,:) = nmi5;
    
    %[asmt_varp re nmi10] = COPKSCAL_v1(X,K,pct,mem,T,10,truth);
    %nmi10_varp(noi,:) = nmi10;
    
end

%% updating subspaces
nmi1_v9 = [];
nmi5_v9 = [];
nmi10_v9 = [];

for noi = 1:length(noise)
    X = X_store{noi};
    
    [~,~,nmi1] = KSCAL_v9(X,K,pct,mem,T,1,truth);
    nmi1_v9(noi,:) = nmi1;
    
    [~,~,nmi5] = KSCAL_v9(X,K,pct,mem,T,5,truth);
    nmi5_v9(noi,:) = nmi5;
    
    [~,~,nmi10] = KSCAL_v9(X,K,pct,mem,T,10,truth);
    nmi10_v9(noi,:) = nmi10;
    
end

clear nmi1 nmi5 nmi10 noi


%% for a specific noise level
plot(nmi10_v9(1,:))
hold on
plot(nmi10_v9(2,:))
hold on
plot(nmi10_v9(3,:))
hold on
plot(nmi10_v9(4,:))
hold on
plot(nmi10_v9(5,:))
hold on
%plot(nmi10_varp(6,:))
%hold on
xlabel('Iterations') 
ylabel('NMI') 
legend({'noise = 0.01', 'noise = 0.05', 'noise = 0.1', 'noise = 0.15', 'noise = 0.2'},'Location','southeast')
hold off