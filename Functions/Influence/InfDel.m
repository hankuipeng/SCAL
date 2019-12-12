% This function finds the b most influential data objects given the current
% subspace structure.

function re_diff = InfDel(X,asmt,vec_all,val_all,Q,mu,NumCores)


%%
re_diff = [];
N = size(X,1);
P = size(X,2);
q = Q(1);
K = length(unique(asmt));


%%
parfor (k=1:K, NumCores)
    
    val_pert0 = val_all{k};
    re_bf(k) = sum(val_pert0((q+1):P));
    Nk(k) = length(asmt==k);
    
end


%%
parfor (i=1:N, NumCores)
    
    s = asmt(i); % the cluster that point i is currently allocated to
    
    val_pert0 = val_all{s}; % the eigenvalues to be perturbed
    vec_pert0 = vec_all{s}; % the eigenvectors to be perturbed
    
    % calculate the perturbed eigenvalues val_pert1 = [alpha_{q+1}...alpha_{P}]
    % val_pert1 = zeros(P,1);
    diff = zeros(P,1);
    for k=(q+1):P
        alpha_ki = (X(i,:)-mu(s,:))*vec_pert0(:,k);
        % val_pert1(k) = (Nk(s)*val_pert0(k)-alpha_ki^2)/(Nk(s)-1);
        diff(k) = (alpha_ki^2-val_pert0(k))/(Nk(s)-1);
    end
    
    % the amount of decrease in reconstruction error
    % re_aft = sum(val_pert1((q+1):P));
    re_diff(i) = sum(diff); % in terms of absolute values
    
end

re_diff = abs(re_diff');


end
