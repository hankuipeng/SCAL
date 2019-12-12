% A function that gives the reconstruction errors that correspond to 
% unqueried points and number of queried as input, outputs the b (or a < b) 
% most influential points and their positions

function [inf_val inf_pos] = query_min(un_re_diff,b,asmt_short,K)

inf_val = [];
inf_pos = [];

%% make sure un_re_diff is a column vector
if size(un_re_diff,1) < size(un_re_diff,2)
    un_re_diff = un_re_diff';
end


%% when no. of remaining unqueried points is less than b
if size(un_re_diff,1) < b
    inf_val = un_re_diff;
    inf_pos = 1:size(un_re_diff,1);
end


%% when no.of remaining unrequeried points is greater than or equal to b
if size(un_re_diff,1) >= b
    
    for k = 1:K
        ind_k = find(asmt_short==k);
        [val pos] = mink(un_re_diff(ind_k),b);
        pos_k = ind_k(pos);
        val_k = un_re_diff(pos_k);
        
        inf_pos = [inf_pos(:);pos_k(:)];
        inf_val = [inf_val(:);val_k(:)];
    end
    
end

end