%% find local peak with ramp direction
%  input_data: 1d data array
%  C_Min: minimum distance between each extreme point

function [ peak_main ] = myFindPeakOne(direction, input_data, cmin)

peak_main = [];

[ r, d ] = size(input_data);

if( r > d )
    length = r;
else
    length = d;
end

%find all the peaks/trough in tmp_points at least C_Min apart
for x = 1:(length-cmin-1)
    
    if(direction==0)

        if(input_data(x)<=input_data(x+1))
            direction = 1;
        elseif(input_data(x)>input_data(x+1))
            direction = 0;
        end

        continue;
    end
    
    %if a target detection found, check cmin cells ahead
    if( input_data(x) > 0 )
        mark = 1;
        
        for i = 1:cmin
            % find peak
            if( input_data(x+i) > input_data(x) )
                mark = 0;
                break;
            end
        end
        
        %get the first peak and return
        if(mark == 1)
            peak_main = x;
            break;
        end
    end
end
% 
% if(isempty(peak_main))
%     return
% end
% 
% %if there are many peaks have the same value
% %pick the middle peak
% peak_end = peak_main;
% 
% %find the last peak
% for x = peak_main:(length-cmin)
%     
%     if(input_data(x) == input_data(x+1))
%         peak_end = x+1;
%     else
%         break;
%     end
% end
% 
% %take the mean value
% peak_main = round(mean(peak_main:peak_end));
% 
% if(peak_main>=(length-cmin))
%     peak_main = [];
% end
% 
