%% dispaly 3D rendering data of the input radar cartesian coordinates
%  and the provided target track information
% this function has no return value
% intput_polar : all original detection points
% input_track : tracks found in input_polar
% input_angle_t : angle information for ploar to cartesian transform

function myDisplayTrack( input_polar, input_track, input_angle_t)

% polar to cartesian
[ polar_local] = myGetPolar( input_polar, input_angle_t );
input_cartesian = myPolarToCartesianAll( polar_local, 1 );

% get the input variable name
s = inputname(1);

x   = input_cartesian(:,1);
y   = input_cartesian(:,2);
v_x = input_cartesian(:,3);
v_y = input_cartesian(:,4);
t   = input_cartesian(:,7);

figure( 'name', s, 'NumberTitle', 'off' );

% draw base targets
plot3( t, x, y, '.' ); grid on; hold on

% figure(2)
% draw target tracks
for t = 1:size( input_track, 3)
    plot3( 1:size(input_track, 1), input_track(:, 1, t), input_track(:, 2, t), '-','LineWidth',2 ); grid on; hold on
end


title( 'movement trajectory')
% ylim([-10 10])
% zlim([0 30])
xlabel('time')
ylabel('x')
zlabel('y')
% legend({'original', 'T1', 'T2'},'Location','northeast');


