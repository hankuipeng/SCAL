function re_diff = InfAdd(X, asmt, vec_all, val_all, Q, mu, NumCores)

% Last edited: 16th May 2019

%%
N = size(X,1);
P = size(X,2);
re_diff = zeros(N,1);
K = length(unique(asmt));
q = Q(1);


%% 
parfor (k = 1:K, NumCores)
%for k = 1:K
    
    % calculate the covariance matrix for each cluster 
    cov_bf{k} = cov(X(asmt==k,:));
    
    % indices for data that lie in each cluster
    indk{k} = find(asmt==k);
    
    % number of points in each cluster 
    Nk(k) = length(indk{k});
    
    % find the potential cluster to assign to 
    Vuse = vec_all{k};
    Px{k} = (X-repmat(mu(k,:),N,1))*Vuse(:,1:q)*Vuse(:,1:q)' + repmat(mu(k,:),N,1);
    re(:,k) = sum((X-Px{k}).^2,2);
    
end

[~,ind]= sort(re,2);
asmt_next = ind(:,2); % index that corresponds to second smallest re


%%
parfor (i=1:N, NumCores)
    
    % the cluster that point i will be added to
    s = asmt_next(i); 
    
    % eigen-decomposition on X_bf
    vals0 = val_all{s};
    vecs0 = vec_all{s};
    re_bf = sum(vals0((q+1):P)); % the squared reconstruction error before
    
    % calculate inf_est
    mean_rm = X(i,:)-mu(s,:);
    
    diff = zeros(P,1);
    for p=(q+1):P
        diff(p) = ((mean_rm*vecs0(:,p))^2-vals0(p))/(Nk(s)+1);
    end
    re_diff(i) = sum(diff);
    
end