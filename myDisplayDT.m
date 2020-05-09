%% display doppler-t plot of the input radar data
% this function has no return value
% input_image(r,d,t)
% time_stamp(t)
% plot : 1:show image, others: not draw image

function output = myDisplayDT( input_image, time_stamp, plot )

% set axis
R = 76.8/2; % R max = 38.4m
V = 31.5; % V max = +-31.5kph

% range=linspace(0, R, 128);
speed=linspace(-V, V, 128);

input_image(isnan(input_image)) = 0;

doppler_t_img = zeros( size(input_image,3), 128 );

for r = 1:128
    radar_test = squeeze(input_image(r, :, :))';
    doppler_t_img = doppler_t_img + radar_test;
end

doppler_t_img = doppler_t_img/128;

output = doppler_t_img;

if( plot==1)
    figure( 'name', 'DT plot', 'NumberTitle', 'off' );
    doppler_t_img(doppler_t_img==0) = NaN;
    
    imagesc(time_stamp, speed, doppler_t_img','AlphaData',~isnan(doppler_t_img')); grid on
    colormap(jet);
    c = colorbar;
    c.Label.String = 'SNR';
    % caxis([0 1e5]);
    set(gca,'YDir','normal');
    title( 'doppler-t plot');
    xlabel( [ 'time (sec), '  num2str(size(input_image,3)) ' measurements' ]);
    ylabel('speed (km/h), 128 bin');
    
elseif(plot>1)
    figure( 'name', 'DT plot', 'NumberTitle', 'off' );
    doppler_t_img(doppler_t_img==0) = NaN;
    
    imagesc(doppler_t_img','AlphaData',~isnan(doppler_t_img')); grid on; hold on
    line([0,size(doppler_t_img,1)], [64,64], 'Color', 'r');
    
    colormap(jet);
    c = colorbar;
    c.Label.String = 'SNR';
    % caxis([0 1e5]);
    set(gca,'YDir','normal');
    title( 'doppler-t plot');
    xlabel( [ 'time (frame), '  num2str(size(input_image,3)) ' measurements' ]);
    ylabel('doppler, 128 bin');
    ylim([ 25 105 ]);
%     ylim([ 55 95 ]);
end
