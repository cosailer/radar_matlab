%% this function checks if the matrix can form a permutation matrix out of all its 0s
% if multi-solution exits, it finds the first solution and return.

function [ result, output ] = myCheckPermutation( input )

% check for permutation matrix 
% each row/column has at least 1 zeros
% check method:
% for all rows that contains only one 0 (A):
%         remove all 0 that is in the same column as (A)
%         if some row has no 0, then that matrix is not permu

[size_r, size_c ] = size(input);
result = 1;
finish = 0;

while(finish == 0)
    
    % one iteration to remove reductant 0s
    % process each row
    for i = 1:size_r
     
        % get current row
        current_row = input(i,:);

        % get index for all 0s
        index_0 = find(~current_row);

        % if only one zero in the row
        if( size(index_0,2) == 1 )
            
            %mark it as -2
            input(i,index_0) = -2;
            
            % remove all zeros in the same column
            % not the current line
            for j = 1:size_r

                if( input(j,index_0) == 0 )
                    input(j,index_0) = -1;
                end
            end
        end
    end


    % process each column
    for j = 1:size_c

        % get current column
        current_column = input(:,j);

        % get index for all 0s
        index_0 = find(~current_column);

        % if only one zero in the column
        if( size(index_0,1) == 1 )
            
            %mark it as -2
            input(index_0,j) = -2;

            % remove all zeros in the same row
            % not the current line
            for i = 1:size_c

                if( input(index_0,i) == 0 )
                    input(index_0,i) = -1;
                end
            end
        end
    end
    
    % find the first 0
    [ check_r, check_c ] = find(input == 0, 1);
    
    % if each row and column has no more than one 0, then finish
    % otherwise continue iteration
    if( isempty(check_r) )
        finish = 1;
    else
        % here we check if we need to continue the iterations
        
        % count the number of remaining 0s
        [ num_0_r,  num_0_c ] = myCountMatrix0( input );

        % count how many has more than 1 0s
        check1 = num_0_r(num_0_r == 1);
        check2 = num_0_c(num_0_c == 1);
        
        % both check1 and check2 are non empty, means all rows and columns
        % have more than one 0s, then its no possible to iterate through 
        % all 0s therefore in this case, multiple solution exists
        % 
        % so count all remaining 0s of each row/column,
        % find the row/column that has least 0s,
        % then mark the first 0 to -2 and continue
        if( isempty(check1)&&isempty(check2) )
            
            % find the min count other than 0
            num_0_r_min = min( nonzeros(num_0_r) );
            num_0_c_min = min( nonzeros(num_0_c) );
            
            if( num_0_r_min <= num_0_c_min )
                
                % find the first row number of min_r
                check_r = find(num_0_r == num_0_r_min, 1);
                
                % get that column index
                check_c = find(input( check_r, : ) == 0, 1);
            else
                % find the first column number of min_c
                check_c = find(num_0_c == num_0_c_min, 1);
                
                % get that row index
                check_r = find(input( :, check_c ) == 0, 1);
            end
            
            %mark the 0 to -2
            input(check_r, check_c) = -2;
            
            %update coresponding row and column
            tmp_c = find( input(check_r, :) == 0);
            tmp_r = find( input(:, check_c) == 0);
            
            input(check_r, tmp_c) = -1;
            input(tmp_r, check_c) = -1;
            
        end
        
    end
end

% revert all -2s to 0s
input(input == -2) = 0;

% if there is only one 0 in each row, then its a permutation matrix
% otherwise it is not
for i = 1:size_r
    check = find( input(i,:) == 0 );
    
    if( size(check,2) == 1 )
        continue;
    else  % no 0 ore more than 1 0s means not permutation matrix
        result = 0;
        break;
    end
end
 
% if( result == 1 )
%     disp('permu matrix found');
% else
%     disp('not a permu matrix');
% end

input(input~=0) = 1;
output = input;

