% This script test performance under different noise level, where the noise
% follows 'inlier-outlier' model, instead of additive noise.


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


%% K=4, P=100, q=10
P = 100; % dimension of ambient space 
K = 4; % number of clusters 
Nk = 125; % number of data objects per cluster 
N = 500; % total number of data objects 
q = 10; % subspace dimension
T=10;

pct = 0.8;
mem = round(rand(1,N)*K + 0.5)';


%% add noise to a different extent 
% gvals = [0 .1 .2 .5 .8];
% 
% for v=1:length(gvals)
%     
%     p = gvals(v);    % fraction of points to corrupt
%     [Xt,truth,~] = genSubspaceData(P,q,K,Nk);
%     classes{v} = truth;
%     corruptInds = randsample(N,round(p*N));
%     Xt(:,corruptInds) = randn(size(Xt(:,corruptInds)));
%     X_store{v} = Xt';
%     
% end


%% varying noise level 
nmi1_varp = [];
nmi5_varp = [];
nmi10_varp = [];

for noi = 1:length(gvals)

    X = X_store{noi};
    
    
    % KSCAL
%     [~,~,nmi1] = KSCAL_v8(X,K,pct,mem,T,1,truth);
%     nmi1_varp(noi,:) = nmi1;
%     
%     [~,~,nmi5] = KSCAL_v8(X,K,pct,mem,T,5,truth);
%     nmi5_varp(noi,:) = nmi5;
%     
%     [~,~,nmi10] = KSCAL_v8(X,K,pct,mem,T,10,truth);
%     nmi10_varp(noi,:) = nmi10;
    
    
    % COP-KSCAL
    [~,~,nmi1c] = COPKSCAL_v1(X,K,pct,mem,T,1,truth);
    cop_nmi1(noi,:) = nmi1c;
    
    [~,~,nmi5c] = COPKSCAL_v1(X,K,pct,mem,T,5,truth);
    cop_nmi5(noi,:) = nmi5c;
    
    [~,~,nmi10c] = COPKSCAL_v1(X,K,pct,mem,T,10,truth);
    cop_nmi10(noi,:) = nmi10c;
    
end

clear nmi1 nmi5 nmi10 nmi1c nmi5c nmi10c 


%% for a specific noise level
% plot(nmi5_varp(1,:))
% hold on
% plot(nmi5_varp(2,:))
% hold on
% plot(nmi5_varp(3,:))
% hold on
% plot(nmi5_varp(4,:))
% hold on
% plot(nmi5_varp(5,:))
% hold on
% xlabel('Iterations') 
% ylabel('NMI') 
% legend({'noise = 0.01', 'noise = 0.05', 'noise = 0.1', 'noise = 0.15', 'noise = 0.2'},'Location','southeast')
% hold off