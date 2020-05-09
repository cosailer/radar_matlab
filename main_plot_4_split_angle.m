%% playback of radar data to get location

% clear memory, figures, shell
clc;
clear;
close all;

load record_3.mat
load angle_lookup_table

threshold = 3e2;
% threshold = 2e5;

raw_image_1 = fft5_value_1;
% raw_image_1 = cfar_image_1;

raw_image_1 = myRemClutter(raw_image_1);

raw_image_1 = myRemEnvNoise( raw_image_1, 20, 2 );

% raw_image_1 = myNormSNR( raw_image_1 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% manually set time window

index = 120:460;
% index = 80:475;
raw_image_1 = raw_image_1( :, :, index );
angle_t = angle_t( :, :, index );
time_stamp   = time_stamp( index );
frame_num = size(raw_image_1, 3);

% normalize time
time_stamp = time_stamp - time_stamp(1);

% apply threshold
raw_image_1( raw_image_1 < threshold ) = NaN;

%% angle calculation

angle_t = myCalAngle( angle_t );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

angle_width = 64;

angle_image_1 = zeros( 2*angle_width+1, size( raw_image_1, 3 ) );
angle_power_1 = angle_image_1;

peak_image_1 = angle_image_1;
peak_image_2 = angle_image_1;

peak_count_1 = zeros(1, size( raw_image_1, 3 ));
peak_mean_1 = peak_count_1;
angle_count_1 = peak_count_1;

for f = 1:size( raw_image_1, 3 )
    test_image = squeeze(  raw_image_1(:,:,f) );
    test_angle = squeeze(  angle_t(:,:,f) );

    test_mask = test_image;
    test_mask(~isnan(test_mask)) = 1;

    test_angle = test_angle.*test_mask;
    test_angle = round(test_angle);
    
    %count angle distribution
    for r = 1:128
        for d = 1:128
            
            % skip NaN
            if( isnan(test_angle(r,d)) )
                continue;
            end
            
            index = test_angle(r,d)+angle_width;
            
            % valid detection
            angle_image_1( index, f ) = angle_image_1( index, f ) + 1;
            
        end
    end
    
    %1D peak finding
    peak_image_1(:,f) = myGetPeak1D( angle_image_1(:,f), 7 );
    
    %filter peak with less points
    for x = 1:(2*angle_width+1)
        if( peak_image_1(x,f) <= 1 )
%             peak_image_1(x,f) = NaN;
        end
    end
    
    %peak count for each frame
    peak_count_1(f) =  nnz(~isnan(peak_image_1(:,f)));
    
    % count the number of valid angle detections
    angle_count_1(f) = nnz(find(angle_image_1(:,f)));
    
    %if too much angle, drop frame
%     if( angle_count_1(f) > 50 )
%         angle_image_1(:,f) = 0;
%     end
end
%     angles = test_angle;
%     angles(angles == 0) = [];

%     figure
%     a = angles;
%     b = histc(a, unique(a));
%     % b(b==1) = 0;
%     bar( unique(a), b);


time_stamp = 1:size( raw_image_1, 3 );
angle_idx = -angle_width:angle_width;


angle_image_1( angle_image_1 == 0 ) = NaN;


figure
imagesc(time_stamp, angle_idx, angle_image_1,'AlphaData',~isnan(angle_image_1)); grid on
set(gca,'YDir','normal')
colormap(jet);
title( 'angle theta distribution over time, test 2.2')
xlabel( [ 'time, '  num2str(size(angle_image_1,2)) ' measurements' ])
ylabel('angle, (degree)');

figure
imagesc(time_stamp, angle_idx, peak_image_1,'AlphaData',~isnan(peak_image_1)); grid on
set(gca,'YDir','normal')
colormap(jet);
title( 'angle theta distribution peaks')
xlabel( [ 'time, '  num2str(size(peak_image_1,2)) ' measurements' ])
ylabel('angle, (degree)');


% figure
% plot( peak_cout_1 ); hold on
% mean(peak_cout_1)


figure
a = peak_count_1;
b = histc(a, unique(a))
bar( unique(a), b);

    
% figure
% plot( angle_count_1);

figure;
angle_tmp = angle_image_1(:,274);
angle_tmp(isnan(angle_tmp))=0;
plot(angle_idx,angle_tmp); hold on
plot([-1.5 -1.5],[1 11]);

title('angle distribution at frame 274');
xlabel('angle, (degree)');
ylabel('angle count');
ylim([ 1 11 ]);
text(0, 9, 'P_M = -1.5');
text(-11, 10, 'P_A (-12,10)');
text(9.5, 8, 'P_B (9,8)');
