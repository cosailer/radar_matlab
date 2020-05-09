%% display range-t plot of the input radar data
% this function has no return value
% input_image(r,d,t)
% time_stamp(t)

function myDisplayRT( input_image, time_stamp, plot )

% set axis
R = 76.8/2; % R max = 38.4m
V = 31.5; % V max = +-31.5kph

range=linspace(0, R, 64);
% speed=linspace(-V, V, 128);

input_image(isnan(input_image)) = 0;

range_t_img = zeros(128, size(input_image,3) );

for r = 1:128
    radar_test = squeeze(input_image(:, r, :));
    range_t_img = range_t_img + radar_test;
end

range_t_img = range_t_img/128;

% take only upper half of range_t_img
range_t_img = range_t_img(65:128, : );

if( plot==1)  
    figure( 'name', 'RT plot', 'NumberTitle', 'off' );
    range_t_img(range_t_img==0) = NaN;
    imagesc(time_stamp, range, range_t_img,'AlphaData',~isnan(range_t_img)); grid on
    % imagesc(time_stamp, range, range_t_img);
    colormap(jet);
    c = colorbar;
    c.Label.String = 'SNR';
    % caxis([0 1e5]);
    set(gca,'YDir','normal')
    title( 'range-t plot')
    xlabel( [ 'time (sec), '  num2str(size(input_image,3)) ' measurements' ])
    ylabel('range (m), 64 bin')
    % drawnow
    
elseif(plot>1)
    
    figure( 'name', 'RT plot', 'NumberTitle', 'off' );
    range_t_img(range_t_img==0) = NaN;
    imagesc(range_t_img,'AlphaData',~isnan(range_t_img)); grid on
    % imagesc(time_stamp, range, range_t_img);
    colormap(jet);
    c = colorbar;
    c.Label.String = 'SNR';
    % caxis([0 1e5]);
    set(gca,'YDir','normal')
    title( 'range-t plot')
    xlabel( [ 'time (frame), '  num2str(size(input_image,3)) ' measurements' ])
    ylabel('range, 64 bin')
    ylim([ 0 50 ]);
end
