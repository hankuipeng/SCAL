%% K-Subspace Clustering (KSC)
% 1. Eigen decomposition implementation
% 2. We store reconstruction error instead of root mean squared error
% 3. Developed based on previous code on PKM

% 15th May. 2019

function [asmt tot_re] = KSCq(X, K, max_iter, q, mem, NumCores)

% Inputs:
% X: N by P data matrix
% K: number of clusters
% pct: percentage of total variability in each subspace to capture
% Q: it stores the dimensionalities of each subspace

% dimensionalities
N = size(X,1);
P = size(X,2);

% random initialisation of cluster assignment 
asmt = mem;

% initialization
re = repmat(inf,N,K);
tot_re = []; % a vector that contains the reconstruction error for every iteration
Kseq = 1:K; % a sequence of cluster labels to be retrieved later
mu = []; % a matrix that stores the mean vector for each cluster
Q = []; % a vector of length K that stores subspace dimensionalities 
iter = 1;

%% iterative procedure
while iter <= max_iter
    
    % eigen decomposition on each cluster
    parfor (k = 1:K, NumCores)
        
        % obtain zero mean data
        mu(k,:) = mean(X(asmt==k,:));
        % Y = X(asmt==k,:) - mu(k,:);
        
        % eigen decomposition
        [eigvecs, eigvals_m] = eig(cov(X(asmt==k,:)));
        eigvals = diag(eigvals_m);
        
        % re-order the eigenvalues and eigenvectors in decreasing order
        ord = P:-1:1;
        vals = eigvals(ord);
        vecs = eigvecs(:,ord);
        
        % storing for later use
        vec_all{k} = vecs;
        val_all{k} = vals;
        
        % determine subspace dimensionality
        Q(k) = q;
        
    end
    
    
    % compute the squared reconstruction error for each data object to other subspaces
    for kuse = 1:K
       
        Vuse = vec_all{kuse};
        quse = Q(kuse);
        Px{kuse} = (X-repmat(mu(kuse,:),N,1))*Vuse(:,1:quse)*Vuse(:,1:quse)' + repmat(mu(kuse,:),N,1);
        re(:,kuse) = sum((X-Px{kuse}).^2,2);
        
    end
    
    
    %% Re-assigning the labels
    [tmp_re tmp_asmt(:,iter)] = min(re');
    tot_re(iter) = sum(tmp_re);
    
    
    %% stop if RE stopped decreasing
    if iter > 1
        if (tot_re(iter)-tot_re(iter-1)) == 0
            tot_re(iter:max_iter) = tot_re(iter-1);
            iter = max_iter+1;
            break
        end
    end
    
    
    %% store the total rms for each iteration
    asmt = tmp_asmt(:,iter);
    fprintf('Just finished iteration: %d \n', iter);
    iter = iter + 1;
    
    
end 
    
end
