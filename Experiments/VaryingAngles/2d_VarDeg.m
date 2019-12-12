%% add necessary paths

% path to SCAL code
scal_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Algorithm/SCAL/Functions/TidyVersion';
addpath(genpath(scal_path))

% path to SSC code
ssc_path = '/home/hankui/Dropbox/Clustering/WorkLog/By_Algorithm/SSC_ADMM';
addpath(genpath(ssc_path))

clear scal_path ssc_path

format short g


%%
u = [1 0 0]'; % needed when in 3-D
v = u; % needed in higher dimensions

R = RotMatrix(pi/4);

basis0 = [1,0]';
R*basis0 % move vector basis0 counter-clockwise for 45 degrees


% Experiments using 2-D data with K=3. We wish to investigate the effects
% of between-cluster principal angles on the rate of improvement. 


%% generate the data 
P = 2;
q = 1;
Nk = 200;
K = 3;
nvar = 0.1;
R = RotMatrix(degtorad(45)); % 30, 45, 120 degrees 
%R = RotMatrix(degtorad(10),[1 1 1]); % 30, 45, 120 degrees 

%[X truth] = genSubspaceData_v2(P,q,Nk,K,nvar);
[X truth] = genSubspaceData_v4(P,q,Nk,K,nvar,R);
%[X truth] = genSubspaceData_v5(P,q,Nk,K,nvar,R);
%X = norml2(X,1);


% KSCAL parameters
N = size(X,1);
b = 10;
T = N/b;

%
mem = datasample(1:K,N,'Replace',true);


%% plot the data 
scatter(X(Truth==1,1),X(Truth==1,2))
hold on
scatter(X(Truth==2,1),X(Truth==2,2))
hold on
scatter(X(Truth==3,1),X(Truth==3,2))
%set(gca,'visible','off')
hold off


%%
scatter3(X(1:200,1),X(1:200,2),X(1:200,3))
hold on
scatter3(X(201:400,1),X(201:400,2),X(201:400,3))
hold on
scatter3(X(401:600,1),X(401:600,2),X(401:600,3))
hold on
%set(gca,'visible','off')
%scatter3(X(601:800,1),X(601:800,2),X(601:800,3))
hold off 


%% separate the noise-free data from noise and outliers
parpool(2)
tic;
CMat = admmLasso_mat_func(X',false,5);
C = CMat;
CMat = admmOutlier_mat_func(X',false,5);
C = CMat(1:N,:);
toc
p = gcp;
delete(p);


%%
X_noi = X;
X = (X_noi'*C)';
X_free = X;


%% try out SSC
r = 0; affine = false; outlier = true; rho = 1;
[missrate mem C] = SSC(X',r,affine,100,outlier,rho,truth);
cluster_performance(mem,truth)


%% choose the best initialisation
ninit = 50;
for i=1:ninit
    init = datasample(1:K,N,'Replace',true);
    [asmt, re] = KSCq(X, K, 50, q, init);
    mem_iter(i,:) = asmt;
    tot_re(i) = sum(re);
    %perf = cluster_performance(asmt,truth);
    nmi(i) = perf.NMI;
end

[~,ind] = min(tot_re);
mem = mem_iter(ind,:);
cluster_performance(mem,truth)


%%
plot(tot_re)


%% run the algorithm with different strategies (update subspaces using only queried points)
tic;
[~,~,nmi_both] = KSCALq_v14(X,K,q,mem,T,b,truth,@query0_max,@InfBoth);
[~,~,nmi_add] = KSCALq_v14(X,K,q,mem,T,b,truth,@query0_min,@InfAdd);
[~,~,nmi_del] = KSCALq_v14(X,K,q,mem,T,b,truth,@query0_max,@InfDel);
[~,~,nmi_rs] = KSCALq_v14(X,K,q,mem,T,b,truth,@RandomSampling,@InfAdd);
[~,~,nmi_resid] = KSCALq_v14(X,K,q,mem,T,b,truth,@query0_max,@maxResid);
[~,~,nmi_margin] = KSCALq_v14(X,K,q,mem,T,b,truth,@query0_max,@minMargin);
toc


%% run the algorithm with different strategies (don't query every cluster every time)
tic;
[~,~,nmi_both] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_max,@InfBoth);
[~,~,nmi_add] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_min,@InfAdd);
[~,~,nmi_del] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_max,@InfDel);
[~,~,nmi_rs] = KSCALq_v12(X,K,q,mem,T,b,truth,@RandomSampling,@InfAdd);
[~,~,nmi_resid] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_max,@maxResid);
[~,~,nmi_margin] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_max,@minMargin);
%[~,~,nmi_bothp] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_min,@InfBothAdj1);
toc

% poolobj = gcp('nocreate');
% delete(poolobj);


%% run the algorithm with different strategies (query every cluster every time)
%parpool(2)
[~,~,nmi_add] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_min,@InfAdd);
[~,~,nmi_del] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_max,@InfDel);
[~,~,nmi_both] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_max,@InfBoth);
[~,~,nmi_rs] = KSCALq_v12(X,K,q,mem,T,b,truth,@RandomSampling,@InfAdd);
[~,~,nmi_resid] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_max,@maxResid);
[~,~,nmi_margin] = KSCALq_v12(X,K,q,mem,T,b,truth,@query0_max,@minMargin);
% poolobj = gcp('nocreate');
% delete(poolobj);


%%
plot(nmi_both)
hold on
plot(nmi_add)
hold on
plot(nmi_del)
hold on
%plot(nmi_bothp)
hold on
plot(nmi_rs)
hold on
plot(nmi_resid)
hold on
plot(nmi_margin)
hold on
xlabel('Number of questions asked') 
ylabel('NMI') 
legend({'SCAL','SCAL-A','SCAL-D','Random', 'MaxResid', 'MinMargin'},'Location','southeast')
hold off


%% plot against number of questions asked
for i = 1:T
    
    Nques(i) = i*b;
    perf_rs(i) = nmi_rs(i);
    perf_add(i) = nmi_add(i);
    perf_del(i) = nmi_del(i);
    perf_both(i) = nmi_both(i);
    perf_resid(i) = nmi_resid(i);
    perf_margin(i) = nmi_margin(i);
    %perf_bothp(i) = nmi_bothp(i);
    
end


%
%plot(Nques./N,perf_bothp)
hold on
plot(Nques./N,perf_both)
hold on
plot(Nques./N,perf_add)
hold on
plot(Nques./N,perf_del)
hold on
plot(Nques./N,perf_rs)
hold on
plot(Nques./N,perf_resid)
hold on
plot(Nques./N,perf_margin)
hold on
xlabel('Pct. of questions asked') 
ylabel('NMI') 
legend({'Both','Addition','Deletion','Random','MaxResid','MinMargin'},'Location','southeast')
hold off


%% plot with error bars
x = 1:1:T;
m_add=mean(nmi_add);
for t=1:T
    loc_min = min(nmi_add(:,t));
    loc_max = max(nmi_add(:,t));
    err_add(t) = loc_max-loc_min;
end
errorbar(x,m_add,err_add./2)