%% find local maximum point
%  default gap = 1;

function output_data = myFLMax1D(input_data, gap)

image_w = size(input_data, 1);

output_data = input_data;

% check rows
for x = 1:(image_w-gap)
    %if a target detection found, check gap cells ahead 
    if( output_data(x) > 0 )
        for i = 1:gap
            if( output_data(x+i) > output_data(x) )
                output_data(x) = 0;
                break;
            else
                output_data(x+i) = 0;
            end
        end
    end
end

for x = (image_w-gap+1):image_w
    output_data(x) = 0;
end