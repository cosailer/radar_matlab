%% helper function to calculate the angles


function angle_t = myCalAngle( input_angle_t )

% angle calculation
load angle_lookup_table lookup_x lookup_y

%replace all 0s to nan
% input_fft5_value(input_fft5_value==0) = NaN;

% angle_1_mask = input_fft5_value;
% angle_1_mask( ~isnan(angle_1_mask) ) = 1;

% convert to degree
angle_t = input_angle_t*180/pi;

% table lookup with degree
angle_t = interp1( lookup_x, lookup_y, angle_t );

% apply masks
% angle_t = angle_t.*angle_1_mask;
