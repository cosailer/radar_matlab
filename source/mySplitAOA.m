%% split original fft5 signal into 3 parts, -AoA, 0, and +AoA (left, middle and right)
%  input_fft5_value( range, speed, frame_num)
%  aoa_guard( max allowed gap between left and right, in degree)

function [ angle_left, angle_middle, angle_right ] = mySplitAOA( input_angle_t, aoa_guard )

%remove all 0s
input_angle_t(input_angle_t==0) = NaN;

%prepare outputs
angle_left = NaN( size(input_angle_t,1), size(input_angle_t,2), size(input_angle_t,3) );
angle_middle = angle_left;
angle_right = angle_left;

% for each frame
for t = 1:size(input_angle_t, 3)
    
    % get mean angle for the current frame
    angle_t_mean(t) = mean(mean(input_angle_t(:,:,t), 'omitnan'), 'omitnan');
    
    for r = 1:size(input_angle_t, 1)
        for d = 1:size(input_angle_t, 2)
            
            if( input_angle_t(r, d, t) >= (angle_t_mean(t)+aoa_guard)  )
                angle_right(r, d, t) = input_angle_t(r, d, t);
            elseif( input_angle_t(r, d, t) >= (angle_t_mean(t)-aoa_guard) )
                angle_middle(r, d, t) = input_angle_t(r, d, t);
            elseif( input_angle_t(r, d, t) < (angle_t_mean(t)-aoa_guard) )
                angle_left(r, d, t) = input_angle_t(r, d, t);
            end
            
        end
    end
end

