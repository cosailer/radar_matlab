%% CA-CFAR algorithm 2D for peak evaluation

function output_image = myCFARPeak2D(input_peak_image, input_image, guard, train_w, train_h, Pfa)

[ image_w, image_h, image_f ] = size(input_image);
% cfar_image = zeros(image_w, image_h, image_f);
% cfar_image = input_peak_image;

output_image = zeros(image_w, image_h, image_f);
cfar_image = output_image;

train_num = ((train_w+guard)*2+1) * ((train_h+guard)*2+1) - (guard*2+1)^2;
x_w = guard + train_w;
y_h = guard + train_h;

alpha = train_num*(Pfa^(-1/train_num) - 1);

%for each frame
for f = 1:image_f
    
    %for each cell in the image
    for x_main = x_w + 1 : image_w - x_w
        for y_main =  y_h + 1 : image_h - y_h
            
            %for all peaks in input_peak_image
            if( isnan(input_peak_image(x_main, y_main, f)) )
                continue;
            end

            % sum up all surrunding cells
            for x_cell = x_main - x_w : x_main + x_w
                for y_cell = y_main - y_h : y_main + y_h

                    % if inside guard range, skip
                    if( x_cell >= x_main - guard)&&( x_cell <= x_main + guard)&&( y_cell >= y_main - guard)&&( y_cell <= y_main + guard)
                        continue;
                    else
                        cfar_image(x_main, y_main, f) = cfar_image(x_main, y_main, f) + input_image(x_cell, y_cell, f);
                    end
                end
            end

            % calculate noise power of training cells
            cfar_image(x_main, y_main, f) = alpha*cfar_image(x_main, y_main, f)/train_num;

            % make detection decision
            if( input_peak_image(x_main, y_main, f) > cfar_image(x_main, y_main, f) )
                output_image(x_main, y_main, f) = input_peak_image(x_main, y_main, f);
            end
        end
    end
    
end

output_image(output_image==0) = NaN;
