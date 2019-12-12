% This function takes data and cluster assignments as input, and outputs
% the reconstruction error matrix, mean vector matrix, eigenvectors and
% eigenvalues of every cluster.

% Last updated: 16th May 2019

function [re vec_all val_all mu] = KSCCupdate(X, asmt, q, NumCores)

K = length(unique(asmt));
N = size(X,1);
P = size(X,2);

parfor (k = 1:K,NumCores)
    
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
    
    Px{k} = (X-repmat(mu(k,:),N,1))*vecs(:,1:q)*vecs(:,1:q)' +repmat(mu(k,:),N,1);
    re(:,k) = sum((X-Px{k}).^2,2);
    
end

end
