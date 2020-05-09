%% form the polar coordinates out of radar sigal data
% output_polar :
%         (r,d,phi,t)
%           r:     1 < r < 128
%           d:     1 < d < 128
%         phi: -pi/2 < phi < pi/2

function [ output_polar ] = myGetPolar( input_image, input_angle_t )

input_image( input_image <= 0 ) = NaN;

% the number of output polar coordinates varies, so no initialization
r_data = zeros(1, 1);
d_data = zeros(1, 1);
angle_data = zeros(1, 1);
t_data = zeros(1, 1);

% output counter
i = 1;

%for each frame
for t = 1:size(input_image,3)
    for r = 1:size(input_image,1)
        for d = 1:size(input_image,2)
            
            % for each non-nan in input_image
            if( ~isnan(input_image(r,d,t)) )
                r_data(i) = r;
                d_data(i) = d;
                angle_data(i) = input_angle_t( r, d, t );
                t_data(i) = t;
                i = i + 1;
            end
            
        end
    end
end

% structure the output polar coordinates
output_polar = [ r_data; d_data; angle_data; t_data]';

