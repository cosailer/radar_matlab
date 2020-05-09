%% get the rcs value of specified points from the raw data

function [ output_angle ] = myGetAngle( input_r_data, input_d_data, input_angle_t )

% for each frame
for t = 1:size(input_angle_t,3)
    output_angle(t) = input_angle_t(input_r_data(t), input_d_data(t), t);
end


