% This function calculates the reconstruction error of allocating data in
% 'dat' to the label 'k'. E.g. 'dat' can be X(class{1},:), and 'k' can 
% be alloc(1)

function dist = ReAlloc(dat,k,vec_all,Q,mu)

n = size(dat,1); % number of data objects in dat
Vuse = vec_all{k};
quse = Q(k);
Px = (dat-repmat(mu(k,:),n,1))*Vuse(:,1:quse)*Vuse(:,1:quse)' + repmat(mu(k,:),n,1);
dist=sum(sum((dat-Px).^2,2));
