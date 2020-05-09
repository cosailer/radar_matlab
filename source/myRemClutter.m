%% this function reduce the type A clutter noise
%  and also remove mirrored image

function input_image = myRemClutter(input_image)

% % remove main cluter
input_image(68:128,63:65,:) = 0;
input_image(67,62:66,:) = 0;
input_image(66,56:72,:) = 0;
input_image(65,53:75,:) = 0;

% remove mirrored image
input_image(1:64,:,:) = 0;

% input_image(:,62:66,:) = 0;