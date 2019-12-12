% This function finds the b most influential data objects given the current
% subspace structure.

function re_diff = minMargin(X,asmt,vec_all,val_all,Q,mu,NumCores)

K = length(unique(asmt));
N = size(X,1);


%%
%[re,tmp] = re_calc_v2(X,K,mu,Q,vec_all);
parfor (kuse = 1:K,NumCores)
    
    Vuse = vec_all{kuse};
    quse = Q(kuse);
    Px{kuse} = (X-repmat(mu(kuse,:),N,1))*Vuse(:,1:quse)*Vuse(:,1:quse)' + repmat(mu(kuse,:),N,1);
    re(:,kuse) = sum((X-Px{kuse}).^2,2);
    
end
[~,tmp] = min(re');


%%
parfor (i=1:N,NumCores)
    
    min_re(i) = re(i,tmp(i)); % smallest re 
    tempo = sort(re(i,:));
    sm_re(i) = tempo(2); % second smallest re 
    
end

re_diff = 1-min_re./sm_re;

end
