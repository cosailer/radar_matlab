%% extract the target track specified by track
%   
%   input_fft5_value: raw signal data
%   track(2, frame_num): r_data, d_data
%   guard_r: max allowed number of r cell: guard_r = 2
%                                          5 bin = 3m
%  
%   guard_d: max allowed number of d cell: guard_d = 20
%                                average human walking speed = 5kph = 10bin
%                                

function [ output_signal ] = myExtractTrack( input_fft5_value, guard_r, guard_d, track )

%prepare outputs
output_signal = input_fft5_value;

% %remove all 0s from output
output_signal(output_signal==0) = NaN;

% for each frame
for t = 1:size(input_fft5_value, 3)
    
    % find coordinates of speficied target
    r_data = round(track(1,t));
    d_data = round(track(2,t));
    
%     r_data = round(track(t,5));
%     d_data = round(track(t,6));

    
    % init save flags
    save_mark_r = zeros(128,1);
    save_mark_d = zeros(128,1);
    
    % set the save flag within  r_data +-guard_r.

        for g = -guard_r : guard_r
            % check boundaries
            if( r_data + g < 64 )
                continue;
            end
        
            if( r_data + g > size(output_signal, 1) )
                continue;
            end
            
            save_mark_r( r_data + g ) = save_mark_r( r_data + g ) + 1;
        end
    
    
    % set the save flag within  d_max +-guard_d.
        for g = -guard_d : guard_d
            % check boundaries
            if( d_data + g < 1 )
                continue;
            end
        
            if( d_data + g > size(output_signal, 2) )
                continue;
            end
            
            save_mark_d( d_data + g ) = save_mark_d( d_data + g ) + 1;
        end
        
        
    
    % if save flag is not marked, clear the entire r row
    for r = 1:size(output_signal, 1)
        if (save_mark_r(r) == 0)
            output_signal(r,:,t) = NaN;
        end
    end
    
    
    % if save flag is not marked, clear the entire d column
    for d = 1:size(output_signal, 2)
        if (save_mark_d(d) == 0)
            output_signal(:,d,t) = NaN;
        end
    end
    
end
