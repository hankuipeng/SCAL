% A function that gives the reconstruction errors that correspond to 
% unqueried points and number of queried as input, outputs the b (or a < b) 
% most influential points and their positions

function [inf_val inf_pos] = query0_min(un_re_diff,b,asmt,K)


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
     [val ind] = sort(un_re_diff, 'ascend');
     inf_val = val(1:b);
     inf_pos = ind(1:b);
    %[inf_val inf_pos] = mink(un_re_diff,b);
end

end
