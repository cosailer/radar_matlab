%% this function count the number of 0s each row and column

function [ num_0_r,  num_0_c ] = myCountMatrix0( input )

[size_r, size_c ] = size(input);

num_0_r = zeros(size_r,1);
num_0_c = zeros(size_c,1);

for i = 1:size_r
    index_r = find( input(i,:) == 0 );
    num_0_r(i) = size(index_r,2);
end

for j = 1:size_c
    index_c = find( input(:,j) == 0 );
    num_0_c(j) = size(index_c,1);
end
