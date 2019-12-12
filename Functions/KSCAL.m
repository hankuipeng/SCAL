% This function is a variant of KSCALa. We remove the constraint that the 
% subspace dimensionality q is fixed and equal for all subspaces.

% Last updated: 10th Jun. 2019


function [perf labs nmi] = KSCAL(X, K, pct, mem, T, b, Truth, strategy, influence, LabUpdate, NumCores)


%% 
if (nargin < 11)
    NumCores = 4;
end

if (nargin < 10)
    LabUpdate = @LabUpdateHun;
end


%% initial parameters
N = size(X,1);
P = size(X,2);
Q = [];
nmi = [];
asmt = mem; % initial assignment 
iter = 1;
ksc_iter = 100;

% indicator vector of whether a point has been queried or not
queried_01 = zeros(N,1); 

% the indices of queried points
queried_id = [];

% the indices of unqueried points
unqueried_id = [1:N]';


%%
while iter <= T
    
    
    %% stop if all data have been queried
    if length(unqueried_id) == 0
        nmi(iter:T) = nmi(iter-1);
        iter = T+1;
        break
    end
    
    
    %% calculate the subspace bases
    for k = 1:K
        
        % obtain zero mean data
        mu(k,:) = mean(X(asmt==k,:));
        
        % eigen decomposition
        [eigvecs, eigvals_m] = eig(cov(X(asmt==k,:)));
        eigvals = diag(eigvals_m);
        
        % re-order the eigenvalues and eigenvectors in decreasing order
        ord = P:-1:1;
        val_all{k} = eigvals(ord);
        vec_all{k} = eigvecs(:,ord);
        
        % determine subspace dimensionality
        q = sum(cumsum(eigvals) <= pct*sum(eigvals))+1; 
            
        % safety catch
        if q >= P
           q = P-1;
        end
        
        Q(k) = q;
        
    end
    
    clear eigvals_m ord eigvals eigvecs
    
    
    %% find the point(s) to query
    re_diff = influence(X, asmt, vec_all, val_all, Q, mu, NumCores);
    [~, diff_id] = strategy(re_diff(unqueried_id), b, asmt(unqueried_id), K);
    
    querying_id = unqueried_id(diff_id);
    queried_id = [queried_id; querying_id];
    queried_01(querying_id) = 1;
    unqueried_id = find(queried_01==0);
    
    
    %% update the cluster assignments of queried points using KSCC
    tmp = KSCC(X, K, pct, ksc_iter, asmt, Truth, queried_id, LabUpdate, NumCores);
    asmt = tmp;
    
    clear tmp
    
    
    %% store the performance
    perf{iter} = cluster_performance(asmt,Truth);
    nmi(iter) = perf{iter}.NMI;
    labs(iter,:) = asmt;
    
    fprintf('Just finished iteration: %d \n', iter);
    
    % stop if perfection is reached
    if perf{iter}.NMI == 1
        nmi(iter:T) = 1;
        iter = T+1;
    end
    
    iter = iter + 1;
    
end

end
