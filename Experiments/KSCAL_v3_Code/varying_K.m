%% add necessary paths
addpath('../');

% add OPC to path
opc_path = '/home/hankui/Downloads/MATLAB_OPC';
addpath(genpath(opc_path));

% path to my routine MAC
mac_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Language/MATLAB/Minimum_Angle_Clustering_MAC';
addpath(genpath(mac_path));

% add MyToolBox to path
mytools = '/home/hankui/Dropbox/Clustering/WorkLog/By_Language/MATLAB/0_MyToolBox';
addpath(genpath(mytools));

% path to LRR code
lrr_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Language/MATLAB/Low_Rank_Representation_LRR';
addpath(genpath(lrr_path));

% path to SSC code
ssc_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Language/MATLAB/Sparse Subspace Clustering_SSC';
addpath(genpath(ssc_path));

%path to K-Subspaces code
ksub_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Language/MATLAB/K-Subspaces';
addpath(genpath(ksub_path));

% path to SCAL code
scal_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Algorithm/SCAL';
addpath(genpath(scal_path))

copkss_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Algorithm/COPKSS';
addpath(genpath(copkss_path))

clear opc_path mac_path mytools lrr_path ssc_path ksub_path scal_path copkss_path


%% no noise, q=10, P=100, K=2,4,5,10
P = 100; % dimension of ambient space 
N = 1000; % total number of data objects 
q = 10;

nmi1_varp = [];
nmi5_varp = [];
nmi10_varp = [];

asmt_varp = [];
X_store = {};

K = [2 4 5 10];


%% 
for k = 1:4
    Nk = N/K(k); % number of data objects per cluster 
    [X,truth,~] = genSubspaceData(P,q,K(k),Nk);
    X_store{q} = X';
    X = X';
    
    pct = 0.8;
    mem = round(rand(1,N)*K(k) + 0.5)';
    
    [asmt_varp re nmi1] = KSCAL_v3(X,K(k),pct,mem,20,1,truth);
    nmi1_varp(k,:) = nmi1;
    
    [asmt_varp re nmi5] = KSCAL_v3(X,K(k),pct,mem,20,5,truth);
    nmi5_varp(k,:) = nmi5;
    
    [asmt_varp re nmi10] = KSCAL_v3(X,K(k),pct,mem,20,10,truth);
    nmi10_varp(k,:) = nmi10;
    
end


%% for a specific K
plot(nmi10_varp(1,:))
hold on
plot(nmi10_varp(2,:))
hold on
plot(nmi10_varp(3,:))
hold on
plot(nmi10_varp(4,:))
hold on
xlabel('Iterations') 
ylabel('NMI') 
legend({'K = 2', 'K = 4', 'K = 5', 'K = 10'},'Location','southeast')
hold off

