%% extract all range spread information from original fft5 signal
%  including TSS(total speed spread), NSS(negative swing spread),
%            MSS(main  speed spread), PSS(positive swing spread),
%            RSS(range swing spread), TAS(total angle spread)
%  
%  parameters:
%  input_fft5_value( range, speed, frame_num ) : original rd data
%  angle_t( range, speed, frame_num ) : adjusted angle information

function [ TSS, NSS, MSS, PSS, RSS, TAS ] = mySplitSSA( input_fft5_value, angle_t )

%replace all 0s to nan
input_fft5_value(input_fft5_value==0) = NaN;

%prepare outputs
TSS = zeros( size(input_fft5_value,3), 1 );
NSS = TSS;
MSS = TSS;
PSS = TSS;
RSS = TSS;
TAS = TSS;

% clear range spread
% output_signal = myResetRange( input_fft5_value, 2 );
output_signal = input_fft5_value;

% split main signal into main and aux signal
[main_signal, aux_signal] = mySplitRCS( output_signal, 2, 4, 0.05);

% replace nan to 0s for sorting
output_signal(isnan(output_signal)) = 0;
main_signal(isnan(main_signal)) = 0;
angle_t(isnan(angle_t)) = 0;

% for each frame
for f = 1:size(input_fft5_value,3)
    
    % find all non 0 values of one frame
    [Ro, Do] = find( output_signal(:, :, f) );
    [Rm, Dm] = find( main_signal(:, :, f) );
    
    % if not found, set them to 0
    if(isempty(Ro))
        Ro = 0;
    end
    
    if(isempty(Do))
        Do = 0;
    end
    
    if(isempty(Rm))
        Rm = 0;
    end
    
    if(isempty(Dm))
        Dm = 0;
    end
    
    TSS(f) = max(Do) - min(Do);
    MSS(f) = max(Dm) - min(Dm);
    RSS(f) = max(Ro) - min(Ro);
    NSS(f) = min(Dm) - min(Do);
    PSS(f) = max(Do) - max(Dm);
    TAS(f) = max(max(angle_t(:,:,f))) - min(min(angle_t(:,:,f)));
%     TAS(f) = abs( max(angle_t(min(Do), :, f)) - min(angle_t(max(Do), :, f)) );
    
end

