%% split original fft5 signal into main RCS signal and auxiliary signal
%  
%  parameters:
%  input_fft5_value( range, speed, frame_num)
%  guard_r(number of allowed range neighbouring cells, max = 2 )
%  guard_d(number of allowed doppler neighbouring cells,
%          max could be more than 20, usually guard_d > guard_r)
%  rcs_level(allowed rcs threshold for main signal)

function [ main_signal, aux_signal] = mySplitRCS( input_fft5_value, guard_r, guard_d, rcs_level )

%remove place all 0s to nan
input_fft5_value(input_fft5_value==0) = NaN;

%prepare outputs
main_signal = NaN( size(input_fft5_value,1), size(input_fft5_value,2), size(input_fft5_value,3) );
aux_signal = input_fft5_value;

% for each frame
for t = 1:size(input_fft5_value, 3)
    %get the maximum rcs value
    input_value_max(t) = max(max(input_fft5_value(:,:,t)));
%     input_value_mean(t) = mean(mean(input_fft5_value(:,:,t), 'omitnan'), 'omitnan');
    
%     if( input_value_max(t) == 0)
%         continue;
%     end
    
    % find coordinates of max rcs value
    [ r_max, d_max ] = find( input_fft5_value(:,:,t) == input_value_max(t) );
    
    % if more than 1 max value found, use mean value.
    % only 1 max value is allowed
    r_max = mean(r_max);
    d_max = mean(d_max);
    
    % check boundaries
    if( r_max <= guard_r )
        continue;
    end
    
    if( d_max <= guard_d )
        continue;
    end
    
    if( r_max >= size(input_fft5_value,1) - guard_r)
        continue;
    end
    
    if( d_max >= size(input_fft5_value,2) - guard_d )
        continue;
    end
    
    if(isnan(r_max))
        continue;
    end
    
    % extract surroudings area( an ellipse with a=guard_d, b=guard_r)
    for r = r_max-guard_r : r_max+guard_r
        for d = d_max-guard_d : d_max+guard_d
            % for non-NaN value inside the ellipse
            if( (~isnan(input_fft5_value(r, d, t)))&&( ((r-r_max)/guard_r)^2 + ((d-d_max)/guard_d)^2 < 1 ) )
                % also consider the RCS thresold
                if( input_fft5_value(r, d, t) >= rcs_level*input_fft5_value(r_max, d_max, t) )
                    main_signal(r, d, t) = input_fft5_value(r, d, t);
                    aux_signal(r, d, t) = NaN;
                end
            end
        end
    end
end
