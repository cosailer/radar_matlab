%% extract target location using kalman filter single target version

% clear memory, figures, shell
clc;
clear;
close all;

load record_1.1.mat

raw_image_1 = fft5_value_1;

%% %%%%%%%%%%% 0, settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%thredshold
Th1 = 5e2;
% Th2 = 8e4;
Th2 = 3e5;
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
gate = 7;

%features
C_Max = 14;
C_Min = 4;

%% %%%%%%%%%%% 1, angle calculation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

angle_t = myCalAngle( angle_t );

%% %%%%%%%%%%% 2, remove cluters and noise %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

raw_image_1 = myRemClutter(raw_image_1);
raw_image_1 = myRemEnvNoise( raw_image_1, NLEN, NR );

%% %%%%%%%%%%% 0, manually set time window %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

index = 40:610;  % 1.1
% index = 100:470; % 1.2
% index = 25:470; % 1.3
% index = 60:470; % 1.4
% index = 40:275; % 1.5
% index = 60:530; % 1.6
% index = 70:560; % 1.7
% index = 70:490; % 1.8
% index = 20:440; % 1.9
% index = 50:500; % 1.10
% 
% % index = 40:610;
raw_image_1 = raw_image_1( :, :, index );
angle_t = angle_t( :, :, index );
time_stamp   = time_stamp( index );
frame_num = size(raw_image_1, 3);

% % normalize time
time_stamp = time_stamp - time_stamp(1);
time_stamp(time_stamp<0)=0;


%% %%%%%%%%%%% 3, apply threshold on raw_image %%%%%%%%%%%%%%%%%%%%%%%%%%%%

raw_image_2 = raw_image_1;
% raw_image_1 = myNormSNR( raw_image_1 );
raw_image_1( raw_image_1 < Th1 ) = NaN;

%% %%%%%%%%%%% 4, find local maxima 2D single target %%%%%%%%%%%%%%%%%%%%%%

peak_image_1 = myGetPeak2D(raw_image_1, g);

% single_image_1 = myGetSingleTarget( peak_image_1, 7 );

% peak_image_1 = myCFARPeak2D(peak_image_1, raw_image_2, 1, pattern_h, pattern_w, pfa);

% myDisplay3D( peak_image_1 );
% myDisplay3D( single_image_1 );
% myDisplay3D( single_image_2 );

%% %%%%%%%%%%% 5, my single target kalman tracker %%%%%%%%%%%%%%%%%%%%%%%%%

% extended kalman tracker, input polar, output polar
% output_track = myKalmanTracker1_EXT( single_image_1, angle_t );

output_track = myKalmanTracker1( peak_image_1, angle_t, gate );

% myDisplayTarget( angle_t, peak_image_1 );

% display signal
myDisplayTrack( peak_image_1,  output_track, angle_t);

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
[ track_image_1, power1 ] = myExtractPattern( raw_image_2, angle_t, pattern_h, pattern_w, pattern_a, output_track(:,5:6)' );

% figure;
% plot(power1);

%% %%%%%%%%%% 9, signal presentation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% dispaly 3D rendering data
% myDisplay3D( raw_image_1 );
% myDisplay3D( track_image_1 );

% dispaly range-t plot
myDisplayRT( track_image_1, time_stamp, 2 );

% dispaly doppler-t plot
myDisplayDT( track_image_1, time_stamp, 2 );

% radar signal playback of rd plot
% myDisplayRD( raw_image_1, 0 );

%% %%%%%%%%%% 9, extract SSA information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

myGetSSA( track_image_1, angle_t, C_Max, C_Min, 1);

