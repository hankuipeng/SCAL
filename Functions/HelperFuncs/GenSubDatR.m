function [X Truth] = GenSubDatR(P,q,Nk,K,noi,R)

% A function to generate data that lie in different subspaces, with a 
% specific rotation angle between subspaces 'R'.

% Inputs:
% P: full dimensionality of the data 
% q: subspace dimensionality 
% Nk: number of points per cluster 
% K: number of clusters 
% noi: level of noise 
% R: the P by P rotation matrix 


%% prepare dataset
X = [];
truth = [];


%% generate the first subspace basis and the data 
basis{1} = orth(randn(P,q)); % the first set of P by q bases matrix
X = basis{1}*randn(q,Nk);
Truth = ones(1,Nk);


%% generate the subspaces and the data for the remaining clusters
for k = 2:K
    
    basis{k} = R*basis{k-1};
    X = [X basis{k}*randn(q,Nk)];
	Truth = [Truth k*ones(1,Nk)];
    
end


%% add noise if asked for
X = X + normrnd(0, noi, size(X));
X=X';
Truth = Truth';


end