function [X Truth] = GenSubDat(P,q,Nk,K,noi)

%% prepare dataset
X = [];
Truth = [];


%% 
for in=1:K
    basis=orth(randn(P,q));
    X=[X basis*randn(q,Nk)];
	Truth=[Truth in*ones(1,Nk)];
end


%% add noise if asked for
X = X + normrnd(0, noi, size(X));
X=X';
Truth = Truth';

end