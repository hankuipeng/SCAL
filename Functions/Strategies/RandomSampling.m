%% function for random sampling
function [inf_val inf_pos] = RandomSampling(un_re_diff, b,asmt,K)

% make sure un_re_diff is a column vector
if size(un_re_diff,1) < size(un_re_diff,2)
    un_re_diff = un_re_diff';
end

% when no. of remaining unqueried points is less than b
if length(un_re_diff) < b
    inf_val = un_re_diff;
    inf_pos = 1:length(un_re_diff);
end

% when no.of remaining unrequeried points is greater than or equal to b
if length(un_re_diff) >= b
    [inf_val inf_pos] = datasample(un_re_diff,b,'Replace',false);
end

end