%% playback of radar data and 3d image representation

% clear memory, figures, shell
clc;
clear;
close all;

load record_1.1.mat

load angle_lookup_table

Th1 = 1e2;
% Th2 = Th1^2;

Th2 = 3e5;

raw_image_1 = fft5_value_1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% raw_image_1 = myRemClutter(raw_image_1);

% raw_image_1 = myRemEnvNoise( raw_image_1, 20, 2 );

% raw_image_1( raw_image_1 < Th1 ) = 0;

% raw_image_1 = myNormSNR( raw_image_1 );
% raw_image_1( raw_image_1 < Th2 ) = 0;

% raw_image_1 = myCFAR2D(raw_image_1, 1, 2, 5, 1e-2);



% apply RCS threshold


% raw_image_1( raw_image_1 < 5e2 ) = 0;
% raw_image_2( raw_image_2 < 1e5 ) = 0;
% raw_image_3( raw_image_3 < 1e3 ) = 0;

% raw_image_3 = myCLEAR(raw_image_3, 2, 3);


% myDisplay3D( raw_image_1 );
% myDisplay3D( raw_image_2 );
% myDisplay3D( raw_image_3 );

% peak_image_1 = myGetPeak2D(raw_image_1, 15);
% peak_image_2 = myGetPeak2D(raw_image_2, 15);
% peak_image_3 = myGetPeak2D(raw_image_3, 15);


% myDisplay3D( peak_image_1 );
% myDisplay3D( peak_image_2 );
% myDisplay3D( peak_image_3 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % manually set time window

% index = 40:615;
% % index = 40:380;
% % index = 100:1160;
% raw_image_1 = raw_image_1( :, :, index );
% angle_t = angle_t( :, :, index );
% time_stamp   = time_stamp( index );
% frame_num = size(raw_image_1, 3);

% % normalize time
time_stamp = time_stamp - time_stamp(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% % display signal

% dispaly 3D rendering data
myDisplay3D( raw_image_1 );

% dispaly range-t plot
myDisplayRT( raw_image_1, time_stamp, 1);

% dispaly doppler-t plot
doppler_t_img = myDisplayDT( raw_image_1, time_stamp, 1 );

% radar signal playback of rd plot
% myDisplayRD( raw_image_1, 0 );


% test_img = mean(raw_image_1, 1, 'omitnan');
% test_img = squeeze(test_img);
% 
% figure
% imagesc(test_img);


