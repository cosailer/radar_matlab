%% walking patten definition

% clear memory, figures, shell
clc;
clear;
close all;

load record_1.1.mat

load angle_lookup_table

% threshold = 1e3;
threshold = 1e2;

% threshold = 2e4;
% threshold = 4e5;

raw_image_1 = fft5_value_1;

angle_t = myCalAngle( angle_t );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

raw_image_1 = myRemClutter(raw_image_1);

raw_image_1 = myRemEnvNoise( raw_image_1, 20, 2 );

% raw_image_1 = myNormSNR( raw_image_1 );
% raw_image_2 = myNormSNR( raw_image_2 );

% apply RCS threshold
% raw_image_1( raw_image_1 < threshold ) = NaN;
% raw_image_2( raw_image_2 < threshold ) = NaN;

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

% range = 1:64;
% doppler = 1:128;

raw_image_1(1:64,:,:) = [];
% raw_image_2(1:64,:,:) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


test_img_1 = squeeze(raw_image_1(:,:,372));
test_img_2 = squeeze(raw_image_1(:,:,416));
test_img_3 = squeeze(raw_image_1(:,:,477));
test_img_4 = squeeze(raw_image_1(:,:,538));

figure('Renderer', 'painters', 'Position', [10 10 800 600]);
subplot(2,2,1);
imagesc(test_img_1,'AlphaData',~isnan(test_img_1));
set(gca,'YDir','normal')
colormap(jet);colorbar;
title( '1, frame 372')
xlabel('doppler, 128 bin')
ylabel('range, 64 bin');
caxis([0 1e3]);
% xlim( [ 40 100 ] );
% ylim( [ 1 32 ] );

subplot(2,2,2);
imagesc(test_img_2,'AlphaData',~isnan(test_img_2));
set(gca,'YDir','normal')
colormap(jet);colorbar;
title( '2, frame 416')
xlabel('doppler, 128 bin')
ylabel('range, 64 bin');
caxis([0 1.5e3]);
% ylim( [ 1 32 ] );

subplot(2,2,3);
imagesc(test_img_3,'AlphaData',~isnan(test_img_3));
set(gca,'YDir','normal')
colormap(jet);colorbar;
title( '3, frame 477')
xlabel('doppler, 128 bin')
ylabel('range, 64 bin');
caxis([0 2e3]);
% ylim( [ 1 32 ] );

subplot(2,2,4);
imagesc(test_img_4,'AlphaData',~isnan(test_img_4));
set(gca,'YDir','normal')
colormap(jet);colorbar;
title( '4, frame 538')
xlabel('doppler, 128 bin')
ylabel('range, 64 bin');
caxis([0 3e3]);
% ylim( [ 1 32 ] );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_img_1 = squeeze(raw_image_1(:,:,582));
test_img_2 = squeeze(raw_image_1(:,:,587));


figure('Renderer', 'painters', 'Position', [10 10 800 600]);

subplot(2,1,1);
imagesc(test_img_1,'AlphaData',~isnan(test_img_1));
set(gca,'YDir','normal')
colormap(jet);
colormap(jet);colorbar;
title( '1, frame 582')
xlabel('doppler, 128 bin')
ylabel('range, 64 bin');
ylim( [ 1 32 ] );

subplot(2,1,2);
imagesc(test_img_2,'AlphaData',~isnan(test_img_2));
set(gca,'YDir','normal')
colormap(jet);
colormap(jet);colorbar;
title( '2, frame 587')
xlabel('doppler, 128 bin')
ylabel('range, 64 bin');
ylim( [ 1 32 ] );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure('Renderer', 'painters', 'Position', [10 10 800 400]);
% figure
test_img_1(test_img_1<8e2) = NaN;

imagesc(test_img_1,'AlphaData',~isnan(test_img_1)); grid on
set(gca,'YDir','normal')
colormap(jet);
colormap(jet);colorbar;
title( 'frame 582')
xlabel('doppler, 128 bin')
ylabel('range, 64 bin');
ylim( [ 1 40 ] );

