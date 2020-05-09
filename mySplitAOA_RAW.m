%% split original input signal into 2 parts, -AoA, 0, and +AoA (left, middle and right)
%  input_fft5_value( range, speed, frame_num)
%  split_aoa: split angle

function [ output_left, output_middle, output_right ] = mySplitAOA_RAW( input_image, input_angle_t, split_aoa  )

%remove all 0s
input_angle_t(input_angle_t==0) = NaN;

%prepare outputs
output_left   = NaN( size(input_image,1), size(input_image,2), size(input_image,3) );
output_middle = output_left;
output_right  = output_left;

% for each frame
for f = 1:size(input_angle_t, 3)
    
%     if( split_aoa(f) == 0 )
%         continue;
%     end
    
    for r = 1:size(input_angle_t, 1)
        for d = 1:size(input_angle_t, 2)
            
            if( input_angle_t(r, d, f) >= split_aoa(f)  )
                output_right(r, d, f) = input_image(r, d, f);
            else
                output_left(r, d, f) = input_image(r, d, f);
            end
            
        end
    end
end

