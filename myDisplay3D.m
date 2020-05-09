%% dispaly 3D rendering data of the input radar data
% this function has no return value
% input_image(r,d,t)

function myDisplay3D( input_image )

% replace 0 with NaN
input_image(input_image==0) = NaN;

% re-arrange index
% input_image = permute(input_image,[2 3 1]);

fprintf('> generating 3d doppler image...\n')

figure( 'name', '3D rdt image', 'NumberTitle', 'off' );
h = slice(input_image, 1:size(input_image,1), 1:size(input_image,2), 1:size(input_image,3) );
% h = slice(input_image, [], [], 1:size(input_image,3) );
set(h, 'EdgeColor','none','linestyle','none');
% alpha(.2)
colormap(jet);
% c = colorbar;
% c.Label.String = 'SNR';
title('3D doppler image');
xlabel('speed, 128 bin');
ylabel('range, 128 bin');
% xlim([ 40 75 ]);
% ylim([ 65 75 ]);
zlabel( [ 'time, '  num2str(size(input_image,3)) ' measurements' ] )

fprintf('> done\n')