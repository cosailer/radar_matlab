%% this function find the minimum number of lines that covers the 0s in the matrix

function [ index_r,  index_c ] = myFind0CoverLine( input )

index_r = [];
index_r2 = [];
index_c = [];

[size_r, size_c ] = size(input);

% input = myMinuMin( input );

% input(input>0) = 1

% [ result, output ] = myCheckPermutation( input );
% 
% if(result == 1)
%     disp('permu found, script end');
%     return;
% end

% mark single 0s as -2 and normal 0s as -1, do a row-wise and column-wise
% may require several iteration
finish = 0;
while(finish == 0)
    
    % row-wise
    for i = 1:size_r
        % find all indices for 0s in one row, no need to check empty
        index_0_r = find(~input(i,:));

        % if there is only one single 0
        if(size( index_0_r, 2 ) == 1)
            %mark it as -2
            input(i,index_0_r) = -2;

            %find the same column, and mark all 0s in the same column as -1
            for j = 1:size_r
               if( input(j,index_0_r) == 0 )
                   input(j,index_0_r) = -1;
               end
            end
        end
    end

    % column-wise
    for j = 1:size_c
        % find all indices for 0s in one column
        index_0_c = find(~input(:,j));

        % skip if no 0s found
        if( isempty(index_0_c) )
            continue;
        end

        % if there is only one single 0
        if(size( index_0_c, 1 ) == 1)
            %mark it as -2
            input(index_0_c,j) = -2;

            %find the same row, and mark all 0s in the same row as -1
            for i = 1:size_c
               if( input(index_0_c,i) == 0 )
                   input(index_0_c,i) = -1;
               end
            end
        end
    end
    
    % if each row and column has no more 0s, then finish
    % otherwise continue iteration
    
    % find the first 0
    [ check_r, check_c ] = find(input == 0, 1);
    
    if( isempty(check_r) )
        finish = 1;
    else
        % count the number of remaining 0s
        [ num_0_r,  num_0_c ] = myCountMatrix0( input );

        % count how many has more than 2 0s
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
            
            %mark the first 0 back to 0 from -1
            input(check_r, check_c) = -2;
            
            %update coresponding row and column
            tmp_c = find( input(check_r, :) == 0);
            tmp_r = find( input(:, check_c) == 0);
            
            input(check_r, tmp_c) = -1;
            input(tmp_r, check_c) = -1;
            
        end
        
    end
    
end

% input

% start with row, find rows that does not contain -2(single 0s)
% there can only be at most one -2 each row/column
for i = 1:size_r
    index_r_tmp = find(input(i,:) == -2);
    
    if( isempty(index_r_tmp) )
        index_r = [ index_r i ];
    end
end


finish = 0;

while(finish == 0)
    
    % go through each row in index_r list
    for i = 1:size( index_r, 2 )
        % find the columns of each -1s, could be more than one -1
        index_c_tmp = find( input( index_r(i), : ) == -1);

        % skip if no -1 found
        if(isempty(index_c_tmp))
            continue;
        end
        
        % reset the -1s
        input( index_r(i), index_c_tmp ) = 0;
        
        % for each -1, find -2 in the same column, can be at most one
        % and add it to index_r
        for j = 1:size( index_c_tmp, 2 )

            index_r_tmp = find( input( :, index_c_tmp(j) ) == -2 );
            
            % skip if no -2 found, mark the column index for removal
            if(isempty(index_r_tmp))
                index_c_tmp(j) = -1;
                continue;
            end
            
            % reset the -2s
            input( index_r_tmp, index_c_tmp(j) ) = 0;
        
            index_r2 = [ index_r2 index_r_tmp ];
        end
        
        % remve unwanted index_c that has on -2
        index_c_tmp(index_c_tmp==-1) = [];
        
        % update index_c
        index_c = [ index_c index_c_tmp ];
        
    end
    
    % update index_r
    index_r = [ index_r index_r2 ];
    
    % remove duplications in index
    index_r = unique(index_r);
    index_c = unique(index_c);

    % check for -1, if all -1 are processed, then finish
    % otherwise continue iteration
    check = find(input(index_r,:) == -1);
    
    if(isempty(check))
        finish = 1;
    end
end

% remove duplications in index
index_r = unique(index_r);
index_c = unique(index_c);

% select all rows that are not marked
origin = 1:size_r;
origin(index_r) = [];
index_r = origin;

% i
% % remark
% for i = 1:size(index_r, 2)
% 
%     % find all -
%     index_r_tmp = find( input(index_r(i),:) < 0 );
% 
%     % reset to 0
%     input(index_r(i), index_r_tmp) = 7;
% end
% 
% % column-wise
% for j = 1:size(index_c, 2)
% 
%     % find all -
%     index_c_tmp = find( input( :, index_c(j) ) < 0 );
% 
%     % reset to 0
%     input( index_c_tmp, index_c(j) ) = 7;
% end
