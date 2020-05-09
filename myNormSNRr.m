%% calculate normalized RCS signal by multiply with r
% RCS = Sigma = 4*pi*r^2*(Sr/St), 4*pi is omitted here
% the calculated value is not entirely RCS

function output = myNormSNRr( input_fft5_value )

output = input_fft5_value;

% for each frame
for t = 1:size(input_fft5_value, 3)
    
    % for the upper half of each frame
    for r = 1:64
        % devide signal strength by r^2
        output(r+64, :, t) = output(r+64, :, t)*r;
    end
end


