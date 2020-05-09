%% range-doppler plot playback of the input radar data
% this function has no return value
% input_image(r,d,t)
% delay: delay seconds between each frame for optimal observations

function myDisplayRD( input_image, delay )

% set axis
R = 76.8/2; % R max = 38.4m
V = 31.5; % V max = +-31.5kph

range=linspace(0, R, 64);
speed=linspace(-V, V, 128);

input_image(input_image==0) = NaN;

% take only upper half of range_t_img
input_image = input_image(65:128, :, : );
    

figure( 'name', 'RD playback', 'NumberTitle', 'off' );

for t = 1:size(input_image,3)
    radar_test = input_image(:, :, t);
    imagesc(speed, range, radar_test,'AlphaData',~isnan(radar_test)); grid on
    colormap(jet);
    c = colorbar;
    c.Label.String = 'SNR';
    caxis([0 5e5]);
    set(gca,'YDir','normal')
    title( ['frame ' num2str(t) ] )
    xlabel('speed (km/h), 128 bin')
    ylabel('range (m), 64 bin')
    drawnow
    pause(delay);
end

title( ['frame ' num2str(t) ' [last frame]' ] )
drawnow