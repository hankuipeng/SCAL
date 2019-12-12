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


%% data generation 

% initial parameters 
P = 100; % dimension of ambient space 
q = 10; % dimension of subspace, assume to be the same across subspaces
K = 2; % number of clusters 
Nk = 1000; % number of data objects per cluster 
N = Nk*K; % total number of data objects 

% this is the original code to generate the data, we will simply read in
% the data 
[X,truth,Utrue] = genSubspaceData(P,q,K,Nk);
X = X';


%% read in the data 
dat = load('d2k2_ex2.mat');
X = dat.X;
truth = dat.truth;
clear dat


%% verify the subspace nature of the data 
[U S V] = svd(X(truth==1,:));
plot(diag(S))


%% Subspace clustering with active learning

% initial parameters 
pct = 0.8;
T = 10;
b = 1;
mem = round(rand(1,N)*K + 0.5)';

% SCAL
[asmt tot_re nmi1] = KSCAL_v3(X,K,pct,mem,10,1,truth);


%% visualization
d2k2_perf = cluster_performance(asmt,truth);
plot(nmi1)
