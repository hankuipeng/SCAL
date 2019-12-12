%% K-Subspace Clustering with Constraints (KSCC)
% 1. Eigen decomposition implementation.
% 2. We store reconstruction error instead of root mean squared error.
% 3. Developed based on previous code on PKM.
% 4. A variant of KSCCq, but here the subspace dimensionality q is not
% fixed, and not necessarily the same for all subspaces.

% Last updated: 10th Jun. 2019

function asmt = KSCC(X, K, pct, max_iter, mem, Truth, queried_id, LabUpdate, NumCores)

% Inputs:
% X: N by P data matrix
% K: number of clusters
% Q: it stores the dimensionalities of each subspace

% dimensionalities
N = size(X,1);
P = size(X,2);

% random initialisation of cluster assignment 
asmt = mem;

% initialization
re = repmat(inf,N,K);
tot_re = []; % a vector that contains the reconstruction error for every iteration
mu = []; % a matrix that stores the mean vector for each cluster
Q = [];
iter = 1;


%% iterative procedure
while iter <= max_iter
    
    
    %% update the subspace bases
    for k = 1:K
        
        % obtain zero mean data
        mu(k,:) = mean(X(asmt==k,:));
        
        % eigen decomposition
        [eigvecs, eigvals_m] = eig(cov(X(asmt==k,:)));
        eigvals = diag(eigvals_m);
        
        % re-order the eigenvalues and eigenvectors in decreasing order
        ord = P:-1:1;
        vals = eigvals(ord);
        vecs = eigvecs(:,ord);
        
        vec_all{k} = vecs;
        val_all{k} = vals;
        
        % determine subspace dimensionality
        q = sum(cumsum(vals) <= pct*sum(vals))+1; 
            
        % safety catch
        if q >= P
           q = P-1;
        end
        
        Q(k) = q;
        
        Px{k} = (X-repmat(mu(k,:),N,1))*vecs(:,1:q)*vecs(:,1:q)' +repmat(mu(k,:),N,1);
        re(:,k) = sum((X-Px{k}).^2,2);
        
    end
    [min_re, asmt] = min(re');
    
    
    %% satisfy the constraints
    asmt_new = LabUpdate(X, queried_id, Truth, asmt, vec_all, Q, mu, NumCores);
    asmt = asmt_new;
    
    
    %% calculate the total reconstruction error
    for k = 1:K
        
        % obtain zero mean data
        mu(k,:) = mean(X(asmt==k,:));
        q = Q(k);
        
        % eigen decomposition
        [eigvecs, eigvals_m] = eig(cov(X(asmt==k,:)));
        eigvals = diag(eigvals_m);
        
        % re-order the eigenvalues and eigenvectors in decreasing order
        ord = P:-1:1;
        vals = eigvals(ord);
        vecs = eigvecs(:,ord);
        
        vec_all{k} = vecs;
        val_all{k} = vals;
        
        Px{k} = (X-repmat(mu(k,:),N,1))*vecs(:,1:q)*vecs(:,1:q)' +repmat(mu(k,:),N,1);
        re(:,k) = sum((X-Px{k}).^2,2);
        
    end
    
    
    %% calcualte the total reconstruction error
    idx = sub2ind(size(re), 1:N, asmt);
    tot_re(iter) = sum(re(idx));
    
    
    %%
    if iter > 1
        if tot_re(iter) == tot_re(iter-1)
        tot_re(iter:max_iter) = tot_re(iter-1);
        iter = max_iter + 1;
        break
        end
    end
    iter = iter + 1;
    
    
end 
    
end
