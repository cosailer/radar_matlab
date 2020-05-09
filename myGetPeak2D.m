%% this function get the local maxima of a 2D image
% gap : the minimal horizontal or vertical distance between each peak

function [ output_image ] = myGetPeak2D( input_image, gap )

output_image = input_image;

% for each frame
for t = 1:size(input_image,3)
    
    % for each point x in the image
    for r = 1:size(input_image,1)
        for d = 1:size(input_image,2)
            
            % [ check input_image for peaks !!! ]
            %if a target detection found, check gap cells around it 
            if( isnan(input_image(r,d,t)) )
                continue;
            end
            
            peak_mark = 1;
            
            % check the surrounding cell
            for rr = r-gap:r+gap
                for dd = d-gap:d+gap
                    
                    % check boundary
                    if(rr<1)||(rr>128)
                        continue;
                    end
                    
                    if(dd<1)||(dd>128)
                        continue;
                    end
                    
                    % skip if (rr,dd,t) is not a valid detection
                    if( isnan(input_image(rr,dd,t)) )
                        continue;
                    end
                    
                    % compare the x with all surrounding cells
                    if( input_image(rr,dd,t) > input_image(r,d,t) )
                        peak_mark = 0;
                        break;
                    end
                    
                end
            end
            
            % [ only modify output_image !!! ]
            % if peak_mark = 1, then current cell is a peak
            % save the peak in output_image
            % clear the surrounding cells in output_image
            if(peak_mark == 1)
                
                %for all surrounding
                for rr = r-gap:r+gap
                    for dd = d-gap:d+gap

                        % check boundary
                        if(rr<1)||(rr>128)
                            continue;
                        end

                        if(dd<1)||(dd>128)
                            continue;
                        end

                        % skip if (rr,dd,t) is not a valid detection
                        if( isnan(output_image(rr,dd,t)) )
                            continue;
                        end
                        
                        %skip current (r,d) point
                        if((rr==r)&&(dd==d))
                            continue;
                        end
                        
                        output_image(rr,dd,t) = NaN;
                    end
                end
                
            % peak_mark = 0, then (r,d,t) is not a peak    
            else
                output_image(r,d,t) = NaN;
            end
            
            
        end
    end
    
end

