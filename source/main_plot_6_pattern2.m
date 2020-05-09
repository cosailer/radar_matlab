%% walking patten definition

% clear memory, figures, shell
clc;
clear;
close all;

load record_1.1.mat

load angle_lookup_table

Th1 = 1e3;
Th2 = 4e5;

% threshold = 2e4;
% threshold = 3e5;

raw_image_1 = fft5_value_1;

angle_t = myCalAngle( angle_t );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

raw_image_1 = myRemClutter(raw_image_1);

raw_image_1 = myRemEnvNoise( raw_image_1, 20, 2 );

% raw_image_1 = myNormSNR( raw_image_1 );
% raw_image_2 = myNormSNR( raw_image_2 );

% apply RCS threshold
raw_image_1( raw_image_1 < Th1 ) = NaN;
% raw_image_2( raw_image_2 < threshold ) = NaN;

% raw_image_1 = myCLEAR(raw_image_1, 2, 3);
% raw_image_1 = myRemBadFrame(raw_image_1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % manually set time window

index = 50:600;
raw_image_1 = raw_image_1( :, :, index );
angle_t = angle_t( :, :, index );
time_stamp   = time_stamp( index );
frame_num = size(raw_image_1, 3);

% % normalize time
time_stamp = time_stamp - time_stamp(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% raw_image_1(100:128,:,:) = NaN;

% myDisplay3D( raw_image_1 );


[ TSS, NSS, MSS, PSS, RSS, TAS ] = mySplitSSA( raw_image_1, angle_t );


figure
plot(TSS); grid on
title('pattern\_d, Th1=1e3');
xlabel('time, samples')
ylabel('bin size');

figure
plot(RSS); grid on
title('pattern\_r, Th1=1e3');
xlabel('time, samples')
ylabel('bin size');
ylim([ 1 20 ]);


