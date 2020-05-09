%% get the single target with maximum snr, in a limited area
% input_image(r,d,t)
% range : search range

function [ output_image ] = myGetSingleTarget( input_image, range )

output_image = input_image;
output_image(:,:,:) = NaN;

% % find the r_max and d_max of the first image
snr_max = max(max(input_image(:,:,1)));
[ r_max, d_max ] = find( input_image(:,:,1) == snr_max );

% % set them to default 64(0,0) if not found
if( isempty(r_max) )
    r_max = 64;
    d_max = 64;
end

r_max_tmp = r_max;
d_max_tmp = d_max;

r_max_last = r_max;
d_max_last = d_max;

w=7;

%for each image
for f = 1:size( input_image, 3)
    
    snr_max = 0;
    
    %search around (r_max,d_max), find maximal SNR point,
    % and update (r_max,d_max)
    for r = r_max-range : r_max+range
        
        % check boundary
        if (r<1)||(r>128)
            continue;
        end
            
        for d = d_max-range : d_max+range
            
            if (d<1)||(d>128)
                continue;
            end
            
            % find the local max SNR point, with r and d
            if( input_image(r, d, f) > snr_max )
                snr_max = input_image(r, d, f);
                
                r_max_tmp = r;
                d_max_tmp = d;
            end
            
        end
    end
    
    % update
    r_max  = r_max_tmp;
    d_max  = d_max_tmp;
    
    
    
    
    
    
    
%     % only w cell between each time frame is allowed
%     if( abs(r_max_last - r_max) > w )
%         r_max = r_max_last;
%     else
%         r_max_last = r_max;
%     end
%     
%     if( abs(d_max_last - d_max) > w )
%         d_max = d_max_last;
%     else
%         d_max_last = d_max;
%     end
    
    % save (r_max,d_max) in output_image
    output_image(r_max,d_max,f) = input_image(r_max,d_max,f);
    
end
