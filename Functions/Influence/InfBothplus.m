% This function finds the b most influential data objects given the current
% subspace structure.

function re_diff = InfBothplus(X,asmt,vec_all,val_all,Q,mu,NumCores)

re_del = InfDel(X,asmt,vec_all,val_all,Q,mu,NumCores);
re_add = InfAdd(X,asmt,vec_all,val_all,Q,mu,NumCores);

re_diff = (re_del + re_add)';

end