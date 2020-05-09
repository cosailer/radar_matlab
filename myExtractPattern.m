%% extract the target track specified by track
%   
%   input_image_enhanced: raw signal data, usually enhanced
%   input_angle_t: input angle frame
%   extracted_image: output image
%   track(2, frame_num): r_data, d_data
%   guard_r: max allowed number of r cell: guard_r = 2
%                                          5 bin = 3m
%  
%   guard_d: max allowed number of d cell: guard_d = 20
%                                average human walking speed = 5kph = 10bin
%                                
%   guard_a: max allowed angle range, degree

function [ extracted_image, power ] = myExtractPattern( input_image_enhanced, input_angle_t, pattern_r, pattern_d, pattern_a, track )

%prepare outputs
extracted_image = input_image_enhanced;
extracted_image(:,:,:) = NaN;

%remove all 0s from input
track(track==0) = NaN;

%calculate average power of each pattern
power = zeros(size(input_image_enhanced, 3), 1);
size_power = (2* pattern_r+1)*(2* pattern_d+1);

% for each frame
for t = 1:size(input_image_enhanced, 3)
    
    % find coordinates and angle of target
    r_data = round(track(1,t));
    d_data = round(track(2,t));
    
    %skip nan
    if((isnan(r_data))||(isnan(d_data)))
        continue;
    end
    
    phi = input_angle_t(r_data, d_data, t);
    
    %for all points within the pattern range
    for r = (r_data-pattern_r):(r_data+pattern_r)
        for d = (d_data-pattern_d):(d_data+pattern_d)
            
            if( (r<1)||(r>128) )
                continue;
            end
            
            if( (d<1)||(d>128) )
                continue;
            end
            
            %find angle difference between target and point to be checked
            phi_check = input_angle_t(r, d, t);
            phi_diff = abs(phi-phi_check);
            
            %only take points with similar angle
            if( phi_diff < pattern_a )
                extracted_image(r,d,t) = input_image_enhanced(r,d,t);
                power(t) = power(t) + input_image_enhanced(r,d,t);
            end
        end 
    end
    
    %calculate the average power of walking patten
    power(t) = power(t)/size_power;
   
end
