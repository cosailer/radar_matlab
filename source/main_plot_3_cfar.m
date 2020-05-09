%% cfar evaluation

% clear memory, figures, shell
clc;
clear;
close all;

load two_people_walk_2

load angle_lookup_table

% threshold = 1e3;
threshold = 5e2;

% threshold = 2e4;
% threshold = 3e5;

raw_image_1 = fft5_value_1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

raw_image_1 = myRemClutter(raw_image_1);

raw_image_1 = myRemEnvNoise( raw_image_1, 20, 2 );

% raw_image_1 = myNormSNR( raw_image_1 );

% apply RCS threshold
% raw_image_1( raw_image_1 < threshold ) = 0;

% raw_image_1 = myCLEAR(raw_image_1, 2, 3);
% raw_image_1 = myRemBadFrame(raw_image_1);


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


test_img = squeeze(raw_image_1(:,:,150));

range = 1:64;
doppler = 1:128;

% figure
% surf(test_img);


test_img_peak = myGetPeak2D( test_img, 5 );
cfar_img = myCFAR2D( test_img, 1, 3, 10, 1e-12);
cfar_img_peak = myCFARPeak2D(test_img_peak, test_img, 1, 3, 10, 1e-12);


test_img( test_img < threshold ) = NaN;
test_img_peak( test_img_peak < threshold ) = NaN;
cfar_img( cfar_img < threshold ) = NaN;
cfar_img_peak( cfar_img_peak < threshold ) = NaN;

test_img = test_img(65:128,:);
test_img_peak = test_img_peak(65:128,:);
cfar_img = cfar_img(65:128,:);
cfar_img_peak = cfar_img_peak(65:128,:);

figure('Renderer', 'painters', 'Position', [10 10 800 600]);
% suptitle('rd plot, frame 150');
subplot(2,2,1);
imagesc(test_img,'AlphaData',~isnan(test_img)); grid on
set(gca,'YDir','normal')
colormap(jet);
title( '1, original, threshold=5e2')
xlabel('doppler, 128 bin')
ylabel('range, 64 bin');
xlim( [ 35 85 ] );
ylim( [ 1 35 ] );
text(45, 3, 'A');
text(80, 17, 'B');
    
subplot(2,2,2);
imagesc(test_img_peak,'AlphaData',~isnan(test_img_peak)); grid on
set(gca,'YDir','normal')
colormap(jet);
title( '2, local maxima, g=5')
xlabel('doppler, 128 bin')
ylabel('range, 64 bin');
xlim( [ 35 85 ] );
ylim( [ 1 35 ] );
text(47, 5, 'A');
text(78, 13, 'B');

subplot(2,2,3);
imagesc(cfar_img,'AlphaData',~isnan(cfar_img)); grid on
set(gca,'YDir','normal')
colormap(jet);
title( '3, cfar, w=3, h=10, Pfa=1e-12')
xlabel('doppler, 128 bin')
ylabel('range, 64 bin');
xlim( [ 35 85 ] );
ylim( [ 1 35 ] );
text(45, 5, 'A');
text(80, 13, 'B');

subplot(2,2,4);
imagesc(cfar_img_peak,'AlphaData',~isnan(cfar_img_peak)); grid on
set(gca,'YDir','normal')
colormap(jet);
title( '4, local maxima with cfar')
xlabel('doppler, 128 bin')
ylabel('range, 64 bin');
xlim( [ 35 85 ] );
ylim( [ 1 35 ] );
text(47, 5, 'A');
text(78, 13, 'B');

