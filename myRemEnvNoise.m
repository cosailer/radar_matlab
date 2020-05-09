%% remove envionment noise
% assume the last 20 or so image contains only noise
% minus the whole signal with the averaged noise
% input_image(r,d,t)
% noise_length: assumed length of the noise
% NR: noise ratio to remove

function output_image = myRemEnvNoise( input_image, noise_size, NR )

% typical
% size_noise = 20;
% NR = 1.5;

output_image = input_image;

output_image(isnan(output_image)) = 0;

% calculate average envionment noise from ending frames
% raw_noise = output_image(:,:,(end-noise_size):end);
raw_noise = output_image(:,:, 1:noise_size);

% calculate average envionment noise from begining frames
% raw_noise = output(:,:,1:noise_size);

noise_img = zeros(128, 128);

for t = 1:size(raw_noise, 3)
    noise_img = noise_img + raw_noise(:,:,t);
end

noise_img = noise_img/size(raw_noise, 3);


% %%find the main clutter and reduce

%sum up the range data
for i =1:128
    current_sum(i) = sum( noise_img(i,:) );
end

% current_sum = current_sum/64;

current_peaks = myFLMax1D(current_sum',7);
current_peaks(current_peaks == 0) = nan;

%find Pr
pr = [];

for i = 1:size(current_peaks,1)
    if(current_peaks(i) > 0)
        pr = [ pr i ];
    end
end

%enhance the noise_img
for i = 1:size(pr, 2)
    for r = -1:1
        noise_img(pr(i)+r,:) = noise_img(pr(i)+r,:)*NR;
    end
end


% remove the adjusted noise
output_image = output_image - noise_img;

% remove negative signal, if it exists
output_image(output_image<0) = 0;
