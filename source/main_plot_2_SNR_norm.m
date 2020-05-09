%% playback of radar data and 3d image representation

% clear memory, figures, shell
clc;
clear;
close all;

load record_1.1.mat

load angle_lookup_table

threshold = 1e3;
% threshold = 5e2;

% threshold = 2e4;
% threshold = 3e5;

raw_image_1 = fft5_value_1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

raw_image_1 = myRemClutter(raw_image_1);

raw_image_1 = myRemEnvNoise( raw_image_1, 20, 2 );

raw_image_2 = myNormSNRr( raw_image_1 );
raw_image_3 = myNormSNR( raw_image_1 );

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


%% % display signal

% dispaly 3D rendering data
% myDisplay3D( raw_image_1 );

% dispaly range-t plot
% myDisplayRT( raw_image_1, time_stamp );

% dispaly doppler-t plot
doppler_t_img1 = myDisplayDT( raw_image_1, time_stamp, 0 );
doppler_t_img2 = myDisplayDT( raw_image_2, time_stamp, 0 );
doppler_t_img3 = myDisplayDT( raw_image_3, time_stamp, 0 );

% radar signal playback of rd plot
% myDisplayRD( raw_image_1, 0 );

% figure;
% test = squeeze( raw_image_1(:,:,910) );
% imagesc(test);

doppler_t_img1(isnan(doppler_t_img1)) = 0;
doppler_t_img2(isnan(doppler_t_img2)) = 0;
doppler_t_img3(isnan(doppler_t_img3)) = 0;

%sum up the range data
for i =1:size(doppler_t_img1,1)
    current_sum1(i) = max( doppler_t_img1(i,:) );
    current_sum2(i) = max( doppler_t_img2(i,:) );
    current_sum3(i) = max( doppler_t_img3(i,:) );
end

% current_sum = current_sum/128;

% current_sum2 = myCFAR(current_sum, 1, 2, 0.2);
% current_sum2 = myAdvanceNorm(current_sum);
% current_sum2 = myAGC(current_sum, 10);
% current_sum3 = myAGC2(current_sum, 10);
% current_sum4 = current_sum*10;


current_sum1 = 10 * log(current_sum1);
current_sum2 = 10 * log(current_sum2);
current_sum3 = 10 * log(current_sum3);


figure
plot(current_sum1, 'k'); hold on;
plot(current_sum2, 'r');
plot(current_sum3, 'b');
% plot(current_sum4);

title( 'max doppler bin SNR plot');
xlabel( [ 'time, '  num2str(size(current_sum1,2)) ' measurements' ])
ylabel('max SNR, 10log10(Smax(r)), dB');
legend({'original', 'k=1', 'k=2'},'Location','southwest');


% N = 2;
% cmap = parula(N);
% L = line(ones(N),ones(N), 'LineWidth',2);
% set(L,{'color'},mat2cell(cmap,ones(1,N),3));
% legend({'aux','main'},'Location','southeast');




% 
% raw_image_1( raw_image_1 < 1e3 ) = 0;
% 
% peak_image_1 = myGetPeak2D(raw_image_1, 10);
% 
% cfar_img_peak = myCFARPeak2D(peak_image_1, raw_image_1, 1, 5, 10, 0.2);
% 
% % myDisplay3D( raw_image_1 );
% myDisplay3D( peak_image_1 );
% myDisplay3D( cfar_img_peak );











% raw_image_1( raw_image_1 < threshold ) ;= 0;
% 
% figure
% for f = 1:size(raw_image_1,3)
% test_img = squeeze(raw_image_1(:,:,f));
% 
% % figure
% % surf(test_img);
% 
% % figure
% % surf(cfar_img);
% 
% 
% % test_img(test_img<200) = 0;
% % cfar_img(cfar_img<100) = 0;
% 
% 
% test_img_peak = myGetPeak2D( test_img, 5 );
% cfar_img_peak = myCFARPeak2D(test_img_peak, test_img, 1, 2, 5, 1e-3);
% 
% 
% % test_img_peak(isnan(test_img_peak)) = 0;
% % 
% % figure
% % surf(test_img_peak);
% 
% % figure
% surf(cfar_img_peak);
% pause(0.1)
% f
% 
% end
