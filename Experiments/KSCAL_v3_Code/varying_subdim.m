%% no noise, K=2, P=100, q=2,4,6,8,10
P = 100; % dimension of ambient space 
K = 2; % number of clusters 
Nk = 1000; % number of data objects per cluster 
N = Nk*K; % total number of data objects 

nmi_varp = [];
asmt_varp = [];
X_store = {};

for q = 1:5
    [X,truth,~] = genSubspaceData(P,q*2,K,Nk);
    X_store{q} = X';
    X = X';
    
    pct = 0.8;
    T = 1000;
    b = 1;
    mem = round(rand(1,N)*K + 0.5)';
    
    [asmt_varp re nmi] = KSCAL_v3(X,K,pct,mem,10,1,truth);
    nmi_varp(q,:) = nmi;
end

