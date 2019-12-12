%% no noise, K=2, P=100, q=2,4,6,8,10
P = 100; % dimension of ambient space 
K = 4; % number of clusters 
Nk = 125; % number of data objects per cluster 
N = Nk*K; % total number of data objects 

mem = round(rand(1,N)*K + 0.5)';
pct = 0.8;
T = 50;

nmi_varp = [];
asmt_varp = [];
X_store = {};


%% b=1
for q = 1:5
    [X,truth,~] = genSubspaceData(P,q*2,K,Nk);
    X_store{q} = X';
    X = X';
    
    [asmt_varp re nmi1] = KSCAL_v8(X,K,pct,mem,T,1,truth);
    nmi_varp1(q,:) = nmi1;
    
    [asmt_varp re nmi5] = KSCAL_v8(X,K,pct,mem,T,5,truth);
    nmi_varp5(q,:) = nmi5;
    
    [asmt_varp re nmi10] = KSCAL_v8(X,K,pct,mem,T,10,truth);
    nmi_varp10(q,:) = nmi10;
end


%% for a specific q
plot(nmi_varp5(1,:))
hold on
plot(nmi_varp5(2,:))
hold on
plot(nmi_varp5(3,:))
hold on
plot(nmi_varp5(4,:))
hold on
plot(nmi_varp5(5,:))
hold on
xlabel('Iterations') 
ylabel('NMI') 
legend({'q = 2', 'q = 4', 'q = 6','q = 8','q = 10'},'Location','southeast')
hold off