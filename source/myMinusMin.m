%% this function minus the minimum for each row and column

function output = myMinusMin( input )

[size_r, size_c ] = size(input);

% minus the minial for each row
for i = 1:size_r
    min_r = min(input(i,:));
    input(i,:) = input(i,:) - min_r;
end

% minus the minial for each column
for j = 1:size_c
    min_c = min(input(:,j));
    input(:,j) = input(:,j) - min_c;
end

output = input;