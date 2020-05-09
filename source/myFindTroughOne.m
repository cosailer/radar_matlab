%% find local trough with ramp direction
%  input_data: 1d data array
%  C_Min: minimum distance between each extreme point

function [ trough_main ] = myFindTroughOne(direction, input_data, cmin)

trough_main = [];

[ r, d ] = size(input_data);

if( r > d )
    length = r;
else
    length = d;
end

%find all the peaks/trough in tmp_points at least C_Min apart
for x = 1:(length-cmin-1)
    
    if(direction==1)

        if(input_data(x)<input_data(x+1))
            direction = 1;
        elseif(input_data(x)>=input_data(x+1))
            direction = 0;
        end

        continue;
    end
    
    %if a target detection found, check cmin cells ahead
    if( input_data(x) > 0 )
        mark = 1;
        
        for i = 1:cmin
            % find trough
            if( input_data(x+i) < input_data(x) )
                mark = 0;
                break;
            end
        end
        
        %get the first peak and return
        if(mark == 1)
            trough_main = x;
            break;
        end
    end
end
% 
% if(isempty(trough_main))
%     return
% end
% 
% %if there are many trough have the same value
% %pick the middle trough
% trough_end = trough_main;
% 
% for x = trough_main:(length-cmin)
%     
%     if(input_data(x) == input_data(x+1))
%         trough_end = x+1;
%     else
%         break;
%     end
% end
% 
% %take the mean value
% trough_main = round(mean(trough_main:trough_end));
% 
% if(trough_main>=(length-cmin))
%     trough_main = [];
% end
