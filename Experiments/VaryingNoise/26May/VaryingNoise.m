%% add necessary paths

% path to SCAL code
scal_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Algorithm/SCAL/Functions/TidyVersion';
addpath(genpath(scal_path))

% path to SSC code
ssc_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Algorithm/SSC_ADMM';
addpath(genpath(ssc_path))

clear scal_path ssc_path

format short g


%% generate 2-D data 
P = 3;
q = 2;
Nk = 20;
K = 3;
noi = 0.1;
[X Truth] = GenSubDat(P, q, Nk, K, noi);

% R = RotMatrix(degtorad(70),[1 1 1]); % 30, 45, 120 degrees 
% R = RotMatrix(degtorad(45)); % 30, 45, 120 degrees 
% [X Truth] = GenSubDatR(P,q,Nk,K,noi,R);

clear Nk noi 


%% set the parameters
N = size(X,1);
pct = 0.8;


%% plot the data in 3-D
scatter3(X(1:200,1),X(1:200,2),X(1:200,3))
hold on
scatter3(X(201:400,1),X(201:400,2),X(201:400,3))
hold on
scatter3(X(401:600,1),X(401:600,2),X(401:600,3))
hold off


%%
r = 0; affine = false; outlier = true; rho = 1; alpha = 800;
[~,mem,C] = SSC(X',r,affine,alpha,outlier,rho,Truth);
cluster_performance(mem,Truth)

clear r affine outlier rho alpha


%% initialise with the best KSC result
NumCores = 4;
parfor (i=1:50, NumCores)
    % rng(i);
    init = datasample(1:K,N,'Replace',true);
    [mem, tot_re] = KSCq(X, K, 50, q, init, NumCores);
    
    re_cand(i) = min(tot_re)
    mem_cand{i} = mem;
end

[val ind] = min(re_cand);
mem = mem_cand{ind};
cluster_performance(mem,Truth)

clear val ind re_cand mem_cand 


%% parallelising KSCAL
strategy = {@query0_max, @query0_max, @query0_min, @query0_min, @query0_max, @RandomSampling};
influence = {@InfBoth,  @maxResid,  @minMargin, @InfAdd,    @InfDel,    @maxResid};
res = zeros(6,T);
NumCores = 4;

parfor(i=1:6, NumCores)
    [~, ~, res(i,:)] = KSCAL(X, K, q, mem, T, b, Truth, strategy{i}, influence{i}, @LabUpdateHun, NumCores);
end

%%
nmi_both = res(1,:);
nmi_resid = res(2,:);
nmi_margin = res(3,:);
nmi_add = res(4,:);
nmi_del = res(5,:);
nmi_rs = res(6,:);


%%
[sum((nmi_both<=0.999))/T sum((nmi_add<=0.999))/T sum((nmi_del<=0.999))/T sum((nmi_resid<=0.999))/T sum((nmi_margin<=0.999))/T sum((nmi_rs<=0.999))/T]


%%
[sum(nmi_both)/N sum(nmi_add)/N sum(nmi_del)/N sum(nmi_resid)/N sum(nmi_margin)/N sum(nmi_rs)/N]


%%
for i = 1:floor(T)
    
    Nques(i) = i*b;
    
end

%
% plot(Nques./N,nmi_bothp)
% hold on
plot(Nques./N,nmi_both)
hold on
plot(Nques./N,nmi_add)
hold on
plot(Nques./N,nmi_del)
hold on
plot(Nques./N,nmi_resid)
hold on
plot(Nques./N,nmi_margin)
hold on
plot(Nques./N,nmi_rs)
hold on
xlabel('Pct. of questions asked') 
ylabel('NMI')
% title('Faces $(K=3)$','Interpreter','latex')
%legend({'SCAL+','SCAL','SCAL-A','SCAL-D','MaxResid', 'MinMargin','Random'},'Location','southeast')
legend({'SCAL','SCAL-A','SCAL-D','MaxResid', 'MinMargin','Random'},'Location','southeast')
hold off
