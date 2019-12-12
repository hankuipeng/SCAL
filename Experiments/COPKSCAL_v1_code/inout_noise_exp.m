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

pct = 0.8;
mem = round(rand(1,N)*K + 0.5)';


%% add noise to a different extent 
gvals = [0 .1 .2 .5 .9];

for v=1:length(gvals)
    p = gvals(v);    % fraction of points to corrupt
    [Xt,truth,~] = genSubspaceData(P,q,K,Nk);
    X = X';
    corruptInds = randsample(N,round(p*N));
    Xt(:,corruptInds) = randn(size(Xt(:,corruptInds)));
    
    mu = mean(Xt,2); % mean vector for the data
    Xt = Xt./repmat(sqrt(sum(Xt.^2,1)),P,1); % normalize data
    G = abs(Xt'*Xt); % obtain the Gram matrix
    G = G - diag(diag(G)); % set its diagonal elements to zero
    
    g = sum(G.^2);
    %g = g/max(g);
    gmat(v,:) = sort(g,'descend');
end


% plot the g values 
plot(gmat(1,:))
hold on
plot(gmat(2,:))
hold on
plot(gmat(3,:))
hold on
plot(gmat(4,:))
hold on
plot(gmat(5,:))
hold on
xlabel('$\textbf{x}_{i}$ ($i=1,\ldots,N$)','Interpreter','latex') 
ylabel('$\left\|\textbf{g}\right\|_{2}$','Interpreter','latex') 
legend({'no noise', 'noise = 0.1', 'noise = 0.2', 'noise = 0.5', 'noise = 0.9'},'Location','southeast')
hold off


%% 10 percent noise
[~,~,nmi_10p] = COPKSCAL_v1(Xt',K,pct,mem,50,10,truth);
plot(nmi_10p)


%% plot the performance 
plot(nmi)
hold on
plot(nmi_10p)
hold on
plot(nmi_20p)
hold on
plot(nmi_50p)
hold on
plot(nmi_90p)
hold on
xlabel('Iterations') 
ylabel('NMI') 
legend({'no noise', 'noise = 0.1', 'noise = 0.2', 'noise = 0.5', 'noise = 0.9'},'Location','southeast')
hold off
