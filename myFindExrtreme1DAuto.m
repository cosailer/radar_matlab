%% find local extream point according to the input signal
% if d_data < 65, return maximum points
% if d_data > 65, return minimum points

function [ extreme_main ] = myFindExrtreme1DAuto(direction, input_data, cmin)

extreme_main = [];

[ r, d ] = size(input_data);

if( r > d )
    length = r;
else
    length = d;
end

%find all the peaks/trough in tmp_points at least C_Min apart
for x = 1:(length-cmin)
    %if a target detection found, check C_Min cells ahead
    if( input_data(x) > 0 )
        mark = 1;
        
        %find min point for > 65
        if( input_data(x) > 65 )
            for i = 1:cmin
                if( input_data(x+i) < input_data(x) )
                    mark = 0;
                    break;
                end
            end
        end

        %find max point for < 65
        if( input_data(x) <= 65 )
            for i = 1:cmin
                if( input_data(x+i) > input_data(x) )
                    mark = 0;
                    break;
                end
            end
        end
        
        %get the first peak
        %if there are more than one elements with the same value as peak
        %set them to 0;
        if(mark == 1)
            extreme_main = x;
            break;
        end
        
    end
end

%if there are many peaks/trough have the same value
%pick the last peak/trough
extreme_end = extreme_main;

for x = extreme_main:(length-cmin)
    if(input_data(extreme_main) == input_data(x) )
        extreme_end = x;
    else
        break;
    end
end

extreme_main = extreme_end;

