%% calculate averaged angle

function output_angle = myCalAngleAverage( input_r_data, input_d_data, input_angle_image )

guard = 1;
output_angle = 0;
count = 0;

for r = input_r_data-guard:input_r_data+guard
    
    if( (r<1)||(r>128) )
        continue;
    end
    
    for d = input_d_data-guard:input_d_data+guard
    
        if( (d<1)||(d>128) )
            continue;
        end
        
        if( isnan(input_angle_image(r, d)) )
            continue;
        end
        
        output_angle = output_angle + input_angle_image(r, d);
        count = count + 1;
    end
end

output_angle = output_angle/count;

% if( isnan(output_angle) )
%     output_angle = input_angle_image(r, d);
% end

if( isnan(output_angle) )
    output_angle = 0;
end

