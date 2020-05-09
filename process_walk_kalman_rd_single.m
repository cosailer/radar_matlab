%% simple kalman tracker for global maxima
%  polar coordinates, only (r,d) tracking is used

% clear memory, figures, shell
clc;
clear;
close all;


load record_1.1.mat

threshold = 1e5;
% threshold = 1e4;

raw_image_1 = fft5_value_1;
% raw_image_1 = cfar_image_1;

%% -------remove cluters--------------------------

% remove main cluter
raw_image_1(:,63:65,:) = 0;
raw_image_1(64:66,59:69,:) = 0;

% remove mirrored image
raw_image_1(1:65,:,:) = 0;

%% -------remove envionment noise-----------------------

raw_image_1 = myRemEnvNoise( raw_image_1, 40, 2 );


%% -------manually set time window------------------------

% index = 110:290;
% raw_image_1 = raw_image_1( :, :, index );
% angle_t = angle_t( :, :, index );
% time_stamp   = time_stamp( index );
% frame_num = size(raw_image_1, 3);
% 
% % normalize time
time_stamp = time_stamp - time_stamp(1);

%% ----------------------------------------------------

% apply threshold
% raw_image_1( raw_image_1 < threshold ) = NaN;
% raw_image_1 = myResetRange( raw_image_1, 3 );


%% angle calculation

%recalculate angle 
angle_t = myCalAngle( angle_t );


%% ----find global maxima before normalize RCS---------


% % get max rcs targets
% [ t_max, r_max, d_max ] = myGetMaxRCS( raw_image_1 );

single_image_1 = myGetSingleTarget( raw_image_1, 7 );

% % % get global max rcs targets
% [ t_max, r_max, d_max, rcs_max ] = myGetGlobalMaxRCS( raw_image_1, 7 );
% 
% input = [ r_max ; d_max ]';

output_track = myKalmanTracker( single_image_1 );



%% ---------extract target track------------------------

% normalize rcs value
raw_image_1 = myNormSNR( raw_image_1 );

% % extract speficied track
raw_image_1 = myExtractTrack( raw_image_1, 2, 20, output_track(:,5:6)' );

raw_image_1( raw_image_1 < threshold ) = NaN;


%% % display signal

% dispaly 3D rendering data
% myDisplay3D( raw_image_1 );

% dispaly range-t plot
myDisplayRT( raw_image_1, time_stamp, 1 );

% dispaly doppler-t plot
myDisplayDT( raw_image_1, time_stamp, 1 );

% radar signal playback of rd plot
% myDisplayRD( raw_image_1, 0 );
