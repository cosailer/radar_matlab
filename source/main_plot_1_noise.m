% this script plots environmental noise graphs for main thesis

% clear memory, figures, shell
clc;
clear;
close all;

load record_1.1.mat

threshold = 1e3;

raw_image_1 = fft5_value_1;
angle_t = myCalAngle( angle_t );

% % remove main cluter
raw_image_1(68:128,63:65,:) = 0;
raw_image_1(67,62:66,:) = 0;
raw_image_1(66,56:72,:) = 0;
raw_image_1(65,53:75,:) = 0;

% remove mirrored image
raw_image_1(1:64,:,:) = 0;

% raw_image_1 = myRemClutter(raw_image_1);

% raw_image_1 = myRemEnvNoise( raw_image_1, 20, 2 );



% 1, define noise %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
noise_size = 20;

raw_noise = raw_image_1(:,:,(end-noise_size):end);
raw_noise_angle = angle_t(:,:,(end-noise_size):end);

% raw_noise = raw_image_1(:,:,1:noise_size);

noise_img = zeros(128, 128);
noise_angle = zeros(128, 128);

for t = 1:size(raw_noise, 3)
    noise_img = noise_img + raw_noise(:,:,t);
    noise_angle = noise_angle + raw_noise_angle(:,:,t);
end

noise_img = noise_img/size(raw_noise, 3);
noise_angle = noise_angle/size(raw_noise, 3);

figure;
imagesc(noise_img ,'AlphaData', ~isnan(noise_img));
set(gca,'YDir','normal')
caxis([0 1e3]);
colormap(jet);
c = colorbar;
c.Label.String = 'SNR';
title( 'mean environment noise');
xlabel('doppler, 128 bin')
ylabel('range, 128 bin');




% % remove main cluter

% noise_img = myRemClutter(noise_img);

noise_img(68:128,63:65,:) = 0;
noise_img(67,62:66,:) = 0;
noise_img(66,56:72,:) = 0;
noise_img(65,53:75,:) = 0;


noise_img_org = noise_img;

noise_img(1:64,:) = [];

figure;
imagesc(noise_img ,'AlphaData', ~isnan(noise_img));
set(gca,'YDir','normal')
caxis([0 1e3]);
colormap(jet);
c = colorbar;
c.Label.String = 'SNR';
title( 'mean environment noise');
xlabel('doppler, 128 bin')
ylabel('range, 64 bin');


%sum up the range data
for i =1:64
    current_sum(i) = sum( noise_img(i,:) );
end

current_sum = current_sum/64;


current_peaks = myFLMax1D(current_sum',7);
current_peaks(current_peaks == 0) = nan;


figure;
plot(current_sum,'k'); hold on;
plot(current_peaks,'*','HandleVisibility','off');

title( 'mean doppler bin SNR plot');
xlabel('range, 64 bin')
ylabel('mean SNR, Smean(r)');

data_x = 1:size(current_peaks,1);
data_x = data_x';
data_y = current_peaks;
str = num2str(data_x);

data_x = data_x + 2;
data_y = data_y + 2;
text(data_x, data_y, str);




%find Pr and pv
pr = [];
pv = [];

for i = 1:size(current_peaks,1)
    if(current_peaks(i) > 0)
        pr = [ pr i ];
        pv = [ pv current_peaks(i) ];
    end
end

% 
% %for each pr, from right to left, try to find the first trough
% 
% for i = 1:size(pr, 2)
%     
%     for r = pr(i):-1:1
%         if( current_sum(r) < current_sum(r+1) )&&( current_sum(r) < current_sum(r-1) )
%             
%             tr(i) = r;
%             tv(i) = current_sum(r);
%             break;
%         end
%     end
% end
% 
% %find the factor NR
% prnr = pv./tv;

noise_img15 = noise_img;
noise_img20 = noise_img;
% noise_img15(:,:) = 0;
% noise_img20 = noise_img15;

for i = 1:size(pr, 2)
    for r = -1:1
        noise_img15(pr(i)+r,:) = noise_img(pr(i)+r,:)*1.5;
        noise_img20(pr(i)+r,:) = noise_img(pr(i)+r,:)*2;
    end
end

% figure;
% surf(noise_img);
% colormap(jet);


%sum up the range data
for i =1:64
    current_sum2(i) = sum( noise_img15(i,:) );
end

current_sum2 = current_sum2/64;


% figure;
plot(current_sum2, 'r');
legend({'original', 'NR=1.5',},'Location','northeast');


% walking target, frame 400, reduced stationary clutter
test_img = squeeze(raw_image_1(:,:,400));
test_img = test_img(65:128,:);

figure;
imagesc(test_img);
set(gca,'YDir','normal')
caxis([0 1e3]);
colormap(jet);
c = colorbar;
c.Label.String = 'SNR';
title( 'walking target, frame 400');
xlabel('doppler, 128 bin')
ylabel('range, 64 bin');

% walking target, frame 400, original frame
test_img_ori = squeeze(fft5_value_1(:,:,400));
test_img_ori = test_img_ori(65:128,:);

figure;
imagesc(test_img_ori);
set(gca,'YDir','normal')
caxis([0 1e3]);
colormap(jet);
c = colorbar;
c.Label.String = 'SNR';
title( 'walking target, frame 400, original');
xlabel('doppler, 128 bin')
ylabel('range, 64 bin');

% walking target, frame 400, reduced all clutter
test_img_ori_clear = test_img - noise_img;

figure;
imagesc(test_img_ori_clear);
set(gca,'YDir','normal')
caxis([0 1e3]);
colormap(jet);
c = colorbar;
c.Label.String = 'SNR';
title( 'walking target, frame 400, cleared');
xlabel('doppler, 128 bin')
ylabel('range, 64 bin');



test_img15 = test_img - noise_img15;
test_img15(test_img15<0) = 0;

test_img20 = test_img - noise_img20;
test_img20(test_img20<0) = 0;





%sum up the range data
for i =1:64
    current_sum(i) = max( test_img(i,:) );
    current_sum15(i) = max( test_img15(i,:) );
    current_sum20(i) = max( test_img20(i,:) );
end

% current_sum = current_sum/64;
% current_sum15 = current_sum15/64;
% current_sum20 = current_sum20/64;

figure
plot(current_sum, 'k'); hold on
% plot(29,current_sum(29),'*','HandleVisibility','off');
% text(30,current_sum(29)+50, '29');

plot(current_sum15, 'r');
plot(current_sum20, 'b');
plot([29 29],[0 2500]);
text(30, 1000, 'r=29,actual target');
title( 'max doppler bin SNR plot, frame 400');
ylabel('max SNR, Smax(r)')
xlabel('range, 64 bin');

legend({'original', 'NR=1.5', 'NR=2'},'Location','northeast');




%% calculate normalized SNR signal by multiply with r^2
for r = 1:64
    % devide signal strength by r^2
    test_img20r(r, :) = test_img20(r, :)*r;
    test_img20rr(r, :) = test_img20(r, :)*r*r;
end

%sum up the range data
for i =1:64
    current_sum20r(i) = sum( test_img20r(i,:) );
    current_sum20rr(i) = sum( test_img20rr(i,:) );
end

current_sum20r = current_sum20r/64;
current_sum20rr = current_sum20rr/64;

current_sum20 = 10 * log(current_sum20);
current_sum20r = 10 * log(current_sum20r);
current_sum20rr = 10 * log(current_sum20rr);

figure;
plot(current_sum20, 'k'); hold on;
plot(current_sum20r, 'r');
plot(current_sum20rr, 'b');
plot([29 29],[30 130]);
text(30, 120, 'r=29, actual target');

title( 'mean doppler bin SNR plot');
xlabel('range, 64 bin')
ylabel('mean SNR, 10log10(Smean(r)), dB');
legend({'a(r,d)', 'k=1', 'k=2'},'Location','northwest');



% close all;
raw_noise(raw_noise<3e2)=0;
% myDisplayTarget( raw_noise_angle, raw_noise );
noise = myCartesianNoise( raw_noise_angle, raw_noise );
% noise =
%     0.1507    1.4948
%     1.3610    8.9346
%     3.6943   24.8294
%     6.3699   40.6022
%     8.6810   56.4047

% figure
% imagesc(noise_img);
% noise_img_org(noise_img_org<1e2)=0;
% myDisplayTarget( noise_angle, noise_img_org );

% raw_image_1(raw_image_1<5e2)=0;
% myDisplayTarget( angle_t, raw_image_1 );


