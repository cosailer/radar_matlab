%% extract target location using kalman filter multi-target version

% clear memory, figures, shell
clc;
clear;
close all;

load record_2.1.mat

raw_image_1 = fft5_value_1;

%% %%%%%%%%%%% 0, settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%thredshold
Th1 = 3e2;
Th2 = 8e4;
% Th2 = 2e5;
% Th2 = Th1^2;

%noise
NR = 2;
NLEN = 20;

%detector
g = 5;
pattern_w = 15;
pattern_h = 5;
pattern_a = 5;
pfa = 1e-8;

%tracker
gate = 5;
penalty = 50;
std_error = 5;

%features
C_Max = 14;
C_Min = 4;

%% %%%%%%%%%%%% 0, manually set time window %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% index = 1:500;
% raw_image_1 = raw_image_1( :, :, index );
% angle_t = angle_t( :, :, index );
% time_stamp   = time_stamp( index );
% frame_num = size(raw_image_1, 3);

% % normalize time
time_stamp = time_stamp - time_stamp(1);

%% %%%%%%%%%%% 1, angle calculation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

angle_t = myCalAngle( angle_t );


%% %%%%%%%%%%% 2, remove cluters and noise %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

raw_image_1 = myRemClutter(raw_image_1);
raw_image_1 = myRemEnvNoise( raw_image_1, NLEN, NR );

%% %%%%%%%%%% 3, apply threshold %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% raw_image_1 = myNormSNR( raw_image_1 );

raw_image_2 = raw_image_1;
raw_image_1( raw_image_1 < Th1 ) = NaN;

%% %%%%%%%%%% 6, apply angle mask %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% angle_mask = raw_image_1;
% angle_mask(~isnan(angle_mask)) = 1;
% angle_t = angle_t.*angle_mask;
% 
% output_angle = myGetSplitAoA( angle_t, 5 );
% % plot(output_angle);


%% %%%%%%%%%% 4, find local maxima 2D %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% angle separation
output_angle = zeros(1, size( angle_t, 3 ));

[ image_left, image_middle, image_right ] = mySplitAOA_RAW( raw_image_1, angle_t, output_angle );

% image_left2 = image_left;
% image_right2 = image_right;
% image_left( image_left < Th1 ) = NaN;
% image_right( image_right < Th1 ) = NaN;

% 2d local maxima detection
peak_image_left = myGetPeak2D(image_left, g);
peak_image_right = myGetPeak2D(image_right, g);

% %peak cfar evaluation
% image_left(isnan(image_left)) = 0;
% image_right(isnan(image_right)) = 0;
% 
% peak_image_left = myCFARPeak2D(peak_image_left, image_left2, 1, 5, 15, 1e-8);
% peak_image_right = myCFARPeak2D(peak_image_right, image_right2, 1, 5, 15, 1e-8);

%add left and right to combo
peak_image_left( isnan(peak_image_left) ) = 0;
peak_image_right( isnan(peak_image_right) ) = 0;
peak_image_combo = peak_image_left + peak_image_right;
peak_image_combo(peak_image_combo == 0 ) = nan;

peak_image_1 = peak_image_combo;

% peak_image_1 = myGetPeak2D(raw_image_1, 5);

%% %%%%%%%%%% 5, use cfar to evaluate each maxima detection %%%%%%%%%%%%%%%

%cfar evaluation
peak_image_1 = myCFARPeak2D(peak_image_1, raw_image_2, 1, pattern_h, pattern_w, pfa);
% peak_image_1 = myCFARPeak2D(peak_image_1, raw_image_2, 1, 3, 10, 1e-12);

raw_image_1( raw_image_1 == 0 ) = nan;
% raw_image_1( raw_image_1 < threshold ) = NaN;

% db_image_1 = myDBSCAN( raw_image_1, 2, 5, 10 );
% db_image_1( db_image_1 < threshold ) = NaN;

% myDisplay3D( peak_image_1 );
% myDisplay3D( peak_image_2 );

%% %%%%%%%%%% 9, signal presentation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [ polar_local_raw ] = myGetPolar( raw_image_1, angle_t );
% cartasian_local_raw = myPolarToCartesianAll( polar_local_raw );
% myDisplayTargetCartesian( cartasian_local_raw );
% 
% [ polar_local_peak ] = myGetPolar( peak_image_1, angle_t );
% cartasian_local_peak = myPolarToCartesianAll( polar_local_peak );
% myDisplayTargetCartesian( cartasian_local_peak );

% dispaly 3D rendering data
% myDisplay3D( raw_image_1 );
% 
% % dispaly range-t plot
% myDisplayRT( raw_image_1, time_stamp );
% 
% % dispaly doppler-t plot
% myDisplayDT( raw_image_1, time_stamp );

% radar signal playback of rd plot
% myDisplayRD( raw_image_1, 0 );

%% %%%%%%%%%% 6, my multi-target kalman tracker %%%%%%%%%%%%%%%%%%%%%%%%%%%

% output_track = myKalmanTracker2( peak_image_1, angle_t, 5, 80, 10);
output_track = myKalmanTracker2( peak_image_1, angle_t, gate, penalty, std_error);

%% %%%%%%%%%% 7, extract target tracks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% raw_image_2( raw_image_2 < 1e2 ) = NaN;
raw_image_2 = myNormSNR( raw_image_1 );
raw_image_2( raw_image_2 < Th2 ) = NaN;

myDisplayTrack( peak_image_1,  output_track, angle_t);

% myDisplay3D( raw_image_1);

raw_image_sum = raw_image_1;
raw_image_sum(:,:,:) = 0;

for f = 1:size(output_track,3)
    
    track = output_track(:,5:6,f)';
    [ track_image, power1 ] = myExtractPattern( raw_image_2, angle_t, pattern_h, pattern_w, pattern_a, track );
    
%     track_image(isnan(track_image)) = 0;
%     track_image( track_image > 0 ) = 2*f*1e3;
    
%     raw_image_sum = raw_image_sum + track_image;
    
%     myDisplay3D( track_image );
%     myDisplayRT( track_image, time_stamp );
%     myDisplayDT( track_image, time_stamp, 1 );
    
    myGetSSA( track_image, angle_t, C_Max, C_Min, 1);
end

% raw_image_sum(raw_image_sum == 0) = NaN;

% raw_image_sum(raw_image_sum == 3e3) = -3e3;

% myDisplay3D( raw_image_sum );


% % extract speficied track
% output_track(isnan(output_track)) = 0;
% 
% figure( 'name', '3D rdt image', 'NumberTitle', 'off' );
% fprintf('> generating 3d doppler image...\n')
% 
% for f = 1:size(output_track, 3)
%     
%     track = output_track(:,5:6,f)';
%     
%     %test_img = myExtractTrack( raw_image_2, 2, 10, track );
%     
%     test_img( test_img < 1e3 ) = NaN;
%     test_img( test_img >= 1e3 ) = f*10;
%     
%     input_image = test_img;
%     h = slice(input_image, 1:size(input_image,1), 1:size(input_image,2), 1:size(input_image,3) ); grid on; hold on
%     set(h, 'EdgeColor','none');
% end
% 
% colormap(jet);
% c = colorbar;
% c.Label.String = 'RCS';
% title('3D doppler image');
% xlabel('speed, 128 bin');
% ylabel('range, 128 bin');
% zlabel( [ 'time, '  num2str(size(input_image,3)) ' measurements' ] );
%     
