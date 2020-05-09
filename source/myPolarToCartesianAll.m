%% get polar coordinates of these global max rcs targets
% and convert them to Cartesian coordinates with v_x and v_y
% these coordinates are not scaled into actual measurements
%
% input_polar :
%         (r,d,phi,t)
%           r:     1 < r < 128
%           d:     1 < d < 128
%         phi: -pi/2 < phi < pi/2
%
% output_cartesian :
%         (x,y,v_x, v_y, t)
%           x: -64 < x < 64
%           y:   0 < y < 64
%         v_x: -64 < v_x < 64
%         v_y: -64 < v_y < 64
%           r:   1 < r < 128
%           d:   1 < d < 128
%           t:   1 < t < size(non_nan)

function output_cartesian = myPolarToCartesianAll( input_polar, flag )

%hardcoded cartesian noise points, threshold = 3e2
%obtained using myCartesianNoise function
noise =[ 0.1507    1.4948;
         1.3610    8.9346;
         3.6943   24.8294;
         6.3699   40.6022;
         8.6810   56.4047 ];
%the distance array between input and noise point
% noise_distance = zeros(1,5);

% input (r,d,phi)
input_r_data = input_polar(:,1);
input_d_data = input_polar(:,2);
input_angle_t = input_polar(:,3);

% phi_data = zeros(1, size(input_r_data,2));

% output (x,y,v_x,v_y)
  x_data = zeros(1, size(input_polar,1));
  y_data = zeros(1, size(input_polar,1));
v_x_data = zeros(1, size(input_polar,1));
v_y_data = zeros(1, size(input_polar,1));
  t_data = zeros(1, size(input_polar,1));
  

for t = 1:size(input_polar,1)
%     phi_data(t) = input_angle_t(input_r_data(t), input_d_data(t), t);
    
    x_data(t) = (input_r_data(t)-64)*sind( input_angle_t(t) );
    y_data(t) = (input_r_data(t)-64)*cosd( input_angle_t(t) );
    
%     v_x_data(t) = (input_d_data(t)-64)*sind( input_angle_t(t) );
%     v_y_data(t) = (input_d_data(t)-64)*cosd( input_angle_t(t) );
    
    v_x_data(t) = 0;
    v_y_data(t) = 0;
    
    t_data(t) = input_polar(t,4);
    
    % if the cartesian coordinates is close to point in noise, then ignore the point
    % calculate noise_disance
    if(flag==1)
        for i = 1:size(noise,1)
            noise_distance = (x_data(t)-noise(i,1))^2 + (y_data(t)-noise(i,2))^2;

            if( noise_distance < 2 )
                x_data(t) = NaN;
                y_data(t) = NaN;
                v_x_data(t) = NaN;
                v_y_data(t) = NaN;
                break;
            end
        end
    end
    
end

% t_data = input_polar(:,4);

output_cartesian = [ x_data; y_data; v_x_data; v_y_data; input_r_data'; input_d_data'; t_data ]';


