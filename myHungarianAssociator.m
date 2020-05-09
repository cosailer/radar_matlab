%% this function impelements the Hungarian Algorithm for assignment problem
%
% https://blog.csdn.net/u011837761/article/details/52058703
% https://www.cnblogs.com/YiXiaoZhou/p/5943775.html
% https://zhuanlan.zhihu.com/c_1102212337087401984
% http://csclab.murraystate.edu/~bob.pilgrim/445/munkres.html


function [cost, solutions, cost_matrix] = myHungarianAssociator( input )

[size_r, size_c ] = size(input);

size_r_origin = size_r;
size_c_origin = size_c;

% makes the cost matric into square matrix
if (size_r > size_c)
    input = [ input zeros( size_r, size_r-size_c ) ];
elseif (size_r < size_c)
    input = [ input; zeros( size_c-size_r, size_c ) ];
end

[size_r, size_c ] = size(input);

cost_matrix = input;

finish = 0;
result = 0;
cost = 0;

input = myMinusMin( input );

[ result, output ] = myCheckPermutation( input );

% if( result == 1 )
%     disp('permu matrix found');
% else
%     disp('not a permu matrix');
% end

% check for multi-solutions, if more than one solution exists, skip the
% following iterations

% if(result == 0)
%     [ result, output ] = myCheckMultiSolution( input );
% end

t  = 0;

% while a permu matrix is not found
while(result == 0)
    
    % step count
    t = t + 1;
    
    index_r = [];
    index_c = [];
    
    finish = 0;
    
    [ index_r,  index_c ] = myFind0CoverLine( input );
    
    % remove coresponding row (index_r and index_c) and column in matrix
    % to find the minimum cost
    cost_min = input;

    cost_min(index_r, :) = [];
    cost_min(:, index_c) = [];

    cost_min = min(min(cost_min));
    
    if(isempty(cost_min))
        cost_min = 0;
    end

    % update distance matrix, all non-0-line-covered elements - cost_min
    % all 0-line-covered intersections + cost_min
    for i = 1:size_r
        for j = 1:size_c

            % 0-line-covered intersections
            if( ismember(i, index_r)&&ismember(j, index_c) )
                input(i, j) = input(i, j) + cost_min;

            % non-0-line-covered elements
            elseif( (~ismember(i, index_r))&&(~ismember(j, index_c)) )
                input(i, j) = input(i, j) - cost_min;
            end
        end
    end
    
    %check if result is permu again
    [ result, output ] = myCheckPermutation( input );
    
end

% disp('calculation finished');

% output

%calculate results
solutions = zeros(1, size_c);

for j = 1:size_c
    solutions(j) = find( ~output(:,j) );
end

% calculate actual cost
for j = 1:size(solutions,2)
    cost = cost + cost_matrix( solutions(j), j);
end

% mark the unavailable targets as NaN
if (size_r_origin < size_c_origin)
    
    del = (size_r_origin+1):size_c_origin;
    
    for i = 1:size(solutions(:))
        if( ismember(solutions(i), del) )
            solutions(i) = nan;
        end
    end
end
