%% extract target location using kalman filter single target version

% clear memory, figures, shell
clc;
clear;
close all;

load record_1.1.mat

Th1 = 3e2;
Th2 = 8e4;
% Th2 = Th1^2;

raw_image_1 = fft5_value_1;

%% %%%%%%%%%%% 0, manually set time window %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% index = 500:550;
% % % % index = 1:200;
% % % % index = 120:450;
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
raw_image_1 = myRemEnvNoise( raw_image_1, 20, 2 );

%% %%%%%%%%%%% 3, apply threshold on raw_image %%%%%%%%%%%%%%%%%%%%%%%%%%%%

raw_image_2 = raw_image_1;
% raw_image_1 = myNormSNR( raw_image_1 );
raw_image_1( raw_image_1 < Th1 ) = NaN;

%% %%%%%%%%%%% 4, find local maxima 2D single target %%%%%%%%%%%%%%%%%%%%%%

peak_image_1 = myGetPeak2D(raw_image_1, 5);

% single_image_1 = myGetSingleTarget( peak_image_1, 7 );

peak_image_1 = myCFARPeak2D(peak_image_1, raw_image_2, 1, 5, 15, 1e-8);

% myDisplay3D( peak_image_1 );
% myDisplay3D( single_image_1 );
% myDisplay3D( single_image_2 );

%% %%%%%%%%%%% 5, my single target kalman tracker %%%%%%%%%%%%%%%%%%%%%%%%%

% extended kalman tracker, input polar, output polar
% output_track = myKalmanTracker1_EXT( single_image_1, angle_t );

output_track = myKalmanTracker1( peak_image_1, angle_t, 25 );

% myDisplayTarget( angle_t, peak_image_1 );

% display signal
% myDisplayTrack( peak_image_1,  output_track, angle_t);

%% %%%%%%%%%%% 6, extract target tracks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%get enhanced signal raw_image_2
raw_image_2 = myNormSNR( raw_image_2 );
raw_image_2( raw_image_2 < Th2 ) = NaN;

% raw_image_1 = myCLEAR(raw_image_1, 1, 1);

% use fixed location path
% track = zeros(576, 2);
% track(:,1) = 64;
% track(:,2) = 64;

% % extract speficied track
[ track_image_1, power1 ] = myExtractPattern( raw_image_2, angle_t, 5, 15, 3, output_track(:,5:6)' );

% figure;
% plot(power1);

%% %%%%%%%%%% 9, signal presentation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%set signal window
index = 500:550;
track_image_1 = track_image_1( :, :, index );
time_stamp   = time_stamp( index );

% track_image_1 = track_image_1(50:90,:,:);

% dispaly 3D rendering data
% myDisplay3D( raw_image_1 );
% myDisplay3D( track_image_1 );

% dispaly range-t plot
% myDisplayRT( track_image_1, time_stamp );

% dispaly doppler-t plot
myDisplayDT( track_image_1, time_stamp, 2 );

% radar signal playback of rd plot
% myDisplayRD( raw_image_1, 0 );

%% %%%%%%%%%% 9, extract SSA information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% myGetSSA( track_image_1, angle_t );

