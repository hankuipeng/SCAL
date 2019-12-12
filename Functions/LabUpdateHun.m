function asmt_new = LabUpdateHun(X, queried_id, Truth, asmt, vec_all, Q, mu, NumCores)

% Last updated: 16th May 2019

%%
asmt_new = asmt;
K = length(unique(Truth));


%% create the truth table
err_table = zeros(K);

for i=1:K
    
    % the true classes of queried points so far
    class{i} = queried_id(Truth(queried_id)==i);
    
    % the cost of allocating queried points from the i-th class to the 
    % cluster with the j-th cluster label
    for j=1:K
        err_table(i,j) = ReAlloc(X(class{i},:), j, vec_all, Q, mu);
    end
    
end

err_table(isnan(err_table)) = 0; % prevent NaNs from breaking things


%% updating cluster assignment  
[C,~]=hungarian(err_table');
for k=1:K
    
    asmt_new(class{k}) = C(k);
    
end


end
