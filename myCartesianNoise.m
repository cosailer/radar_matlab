%% get noise points in cartesian space

function noise = myCartesianNoise( input_angle_t, input_polar )


% polar to cartesian
[ polar_local] = myGetPolar( input_polar, input_angle_t );
input_cartesian = myPolarToCartesianAll( polar_local, 0 );

% get the input variable name
s = inputname(1);

x   = input_cartesian(:,1);
y   = input_cartesian(:,2);
t   = input_cartesian(:,7);

%noise cluster 0
x0  = zeros(1,1);
y0  = zeros(1,1);
t0  = zeros(1,1);
count0 = 1;

%noise cluster 1
x1  = zeros(1,1);
y1  = zeros(1,1);
t1  = zeros(1,1);
count1 = 1;

%noise cluster 2
x2  = zeros(1,1);
y2  = zeros(1,1);
t2  = zeros(1,1);
count2 = 1;

%noise cluster 3
x3  = zeros(1,1);
y3  = zeros(1,1);
t3  = zeros(1,1);
count3 = 1;

%noise cluster 4
x4  = zeros(1,1);
y4  = zeros(1,1);
t4  = zeros(1,1);
count4 = 1;

%separate noise points into 5 sections
for i = 1:size(input_cartesian,1)
    
    if( ( y(i) >= 0 )&&( y(i) < 6 ) )
        x0(count0) = x(i);
        y0(count0) = y(i);
        t0(count0) = t(i);
        count0 = count0 + 1;
    elseif( ( y(i) >= 6 )&&( y(i) <= 10 ) )
        x1(count1) = x(i);
        y1(count1) = y(i);
        t1(count1) = t(i);
        count1 = count1 + 1;
    elseif( ( y(i) >= 22 )&&( y(i) <= 27 ) )
        x2(count2) = x(i);
        y2(count2) = y(i);
        t2(count2) = t(i);
        count2 = count2 + 1;
    elseif( ( y(i) >= 39 )&&( y(i) <= 44 ) )
        x3(count3) = x(i);
        y3(count3) = y(i);
        t3(count3) = t(i);
        count3 = count3 + 1;
    elseif( ( y(i) >= 55 )&&( y(i) <= 60 ) )
        x4(count4) = x(i);
        y4(count4) = y(i);
        t4(count4) = t(i);
        count4 = count4 + 1;
    end
    
end





% figure( 'name', s, 'NumberTitle', 'off' );

% draw base targets
% plot3( t, x, y, '.' ); grid on;

% title( 'movement trajectory')
% ylim([-50 50])
% % zlim([0 30])
% xlabel('time')
% ylabel('x')
% zlabel('y')

figure
plot3( t0, x0, y0, '.' ); grid on; hold on
plot3( t1, x1, y1, '.' );
plot3( t2, x2, y2, '.' );
plot3( t3, x3, y3, '.' );
plot3( t4, x4, y4, '.' );

title( 'noise points in cartesian system, threshold=3e2');
xlabel('t')
ylabel('x');
zlabel('y');
% legend({'a(r,d)', 'k=1', 'k=2'},'Location','northwest');



x0_mean = mean(x0);
y0_mean = mean(y0);

x1_mean = mean(x1);
y1_mean = mean(y1);

x2_mean = mean(x2);
y2_mean = mean(y2);

x3_mean = mean(x3);
y3_mean = mean(y3);

x4_mean = mean(x4);
y4_mean = mean(y4);

noise = zeros(5,2);

noise(1,:) = [ x0_mean, y0_mean ];
noise(2,:) = [ x1_mean, y1_mean ];
noise(3,:) = [ x2_mean, y2_mean ];
noise(4,:) = [ x3_mean, y3_mean ];
noise(5,:) = [ x4_mean, y4_mean ];
