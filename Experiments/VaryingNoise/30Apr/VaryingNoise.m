%% add necessary paths

% path to SCAL code
scal_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Algorithm/SCAL/Functions/TidyVersion';
addpath(genpath(scal_path))

% path to SpectralAL code
SpectralAL = '/home/hankui/Dropbox/Clustering/WorkLog/By_Algorithm/SpectralAL/Functions';
addpath(genpath(SpectralAL))

% path to SSC code
ssc_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Algorithm/SSC_ADMM';
addpath(genpath(ssc_path))

clear scal_path ssc_path SpectralAL

format short g


%% generate 2-D data 
P = 3;
q = 2;
Nk = 200;
K = 3;
noi = 0.1;
R = RotMatrix(degtorad(45),[1 1 1]); % 30, 45, 120 degrees 
%R = RotMatrix(degtorad(45)); % 30, 45, 120 degrees 

[X Truth] = GenSubDatR(P,q,Nk,K,noi,R);

clear Nk noi R


% set the parameters for AL
N = size(X,1);
b = 10;
T = N/b;
mem = datasample(1:K,N,'Replace',true);


%% plot the data 
scatter3(X(1:200,1),X(1:200,2),X(1:200,3))
hold on
scatter3(X(201:400,1),X(201:400,2),X(201:400,3))
hold on
scatter3(X(401:600,1),X(401:600,2),X(401:600,3))
hold off


%%
r = 0; affine = false; outlier = true; rho = 1; alpha = 20;
[~,mem,C] = SSC(X',r,affine,alpha,outlier,rho,Truth);
cluster_performance(mem,Truth)

clear r affine outlier rho 


%%
if length(find(C<0)) > 0
    C(:) = abs(C(:));
end

if length(find(C>1)) > 0
    C(:) = C(:)/max(C(:));
end

C = C + eye(N);


%% Using truth table update, comparing various AL strategies 
% mem = datasample(1:K,N,'Replace',true)
%[~, ~, nmi_bothp]  = KSCALa(X,K,q,mem,T,b,Truth,@query0_min,@InfBothplus,@LabUpdateHun);
[~, ~, nmi_both]   = KSCALa(X,K,q,mem,T,b,Truth,@query0_max,@InfBoth,@LabUpdateHun);
[~, ~, nmi_add]    = KSCALa(X,K,q,mem,T,b,Truth,@query0_min,@InfAdd,@LabUpdateHun);
[~, ~, nmi_del]    = KSCALa(X,K,q,mem,T,b,Truth,@query0_max,@InfDel,@LabUpdateHun);
[~, ~, nmi_rs]     = KSCALa(X,K,q,mem,T,b,Truth,@RandomSampling,@InfAdd,@LabUpdateHun);
[~, ~, nmi_resid]  = KSCALa(X,K,q,mem,T,b,Truth,@query0_max,@maxResid,@LabUpdateHun);
[~, ~, nmi_margin] = KSCALa(X,K,q,mem,T,b,Truth,@query0_min,@minMargin,@LabUpdateHun);


%%
NumCores   = 4;  

nmi_both   = SpectralAL(X, K, q, C, mem, T, b, Truth, @query0_max, @SpecBoth, NumCores);
nmi_add    = SpectralAL(X, K, q, C, mem, T, b, Truth, @query0_min, @SpecAdd, NumCores);
nmi_del    = SpectralAL(X, K, q, C, mem, T, b, Truth, @query0_max, @SpecDel, NumCores);
nmi_resid  = SpectralAL(X, K, q, C, mem, T, b, Truth, @query0_max, @SpecResid, NumCores);
nmi_margin = SpectralAL(X, K, q, C, mem, T, b, Truth, @query0_min, @SpecMargin, NumCores);
nmi_rs     = SpectralAL(X, K, q, C, mem, T, b, Truth, @RandomSampling, @SpecAdd, NumCores);


%% parallelising SpectralAL
strategy = {@query0_max, @query0_max, @query0_min, @query0_min, @query0_max, @RandomSampling};
influence = {@SpecBoth,  @SpecResid,  @SpecMargin, @SpecAdd,    @SpecDel,    @SpecResid};
res = zeros(6,T);
NumCores = 4;

parfor(i=1:6, NumCores)
    res(i,:) = SpectralAL(X, K, q, C, mem, T, b, Truth, strategy{i}, influence{i}, @LabUpdateHun, NumCores);
end


%%
nmi_both = res(1,:);
nmi_resid = res(2,:);
nmi_margin = res(3,:);
nmi_add = res(4,:);
nmi_del = res(5,:);
nmi_rs = res(6,:);


%%
for i = 1:floor(T)
    
    Nques(i) = i*b;
    
end


%%
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


%%
save('noise5_perf.mat')