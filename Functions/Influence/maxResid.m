% This function finds the b most influential data objects given the current
% subspace structure.

function re_diff = maxResid(X,asmt,vec_all,val_all,Q,mu,NumCores)

K = length(unique(asmt));
N = size(X,1);
%[re,~] = re_calc_v2(X,K,mu,Q,vec_all);
parfor (kuse = 1:K,NumCores)
    
    Vuse = vec_all{kuse};
    quse = Q(kuse);
    Px{kuse} = (X-repmat(mu(kuse,:),N,1))*Vuse(:,1:quse)*Vuse(:,1:quse)' + repmat(mu(kuse,:),N,1);
    re(:,kuse) = sum((X-Px{kuse}).^2,2);
    
end

[re_diff,~] = min(re');

end