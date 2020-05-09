%% this function get the local maxima of a 1D array
% gap : the minimal distance between each peak

function [ output_data ] = myGetPeak1D( input_data, gap )

output_data = input_data;

[ r, d ] = size(input_data);

if(r > d)
    length = r;
else
    length = d;
end

% for each element
for i = 1:length
    
    %if a target detection found, check gap cells around it 
    if( isnan(input_data(i)) )
        continue;
    end
    
    peak_mark = 1;
    
    % [ check input_data for peaks !!! ]
    % check the surrounding cell
    for j = i-gap:i+gap
        
        % check boundary
        if(j<1)||(j>length)
            continue;
        end

        % skip if (rr,dd,t) is not a valid detection
        if( isnan(input_data(j)) )
            continue;
        end

        % compare the x with all surrounding cells
        if( input_data(j) > input_data(i) )
            peak_mark = 0;
            break;
        end
    end
    
    % [ only modify output_data !!! ]
    % if peak_mark = 1, then current cell is a peak
    % save the peak in output_data
    % clear the surrounding cells in output_data
    if(peak_mark == 1)

        %for all surrounding
        for j = i-gap:i+gap

            % check boundary
            if(j<1)||(j>length)
                continue;
            end

            % skip if (rr,dd,t) is not a valid detection
            if( isnan(input_data(j)) )
                continue;
            end


            %skip current (r,d) point
            if(j==i)
                continue;
            end

                output_data(j) = NaN;
        end
    % peak_mark = 0, then (i) is not a peak    
    else
        output_data(i) = NaN;
    end

    
end

