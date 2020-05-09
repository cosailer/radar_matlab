%% extract all range spread information from original radar image
% measurement method for causal online data stream
%  including NDS(negative doppler spread), PSS(positive doppler spread),
%  
%  parameters:
%  input_image( range, speed, frame_num ) : original rd data
%  angle_t( range, speed, frame_num ) : adjusted angle information

function [ core_cycle,   max_doppler_cycle, min_doppler_cycle, ...
           min_doppler_NDS, max_doppler_PDS, ...
           walk_mean_v,     walk_acceleration ] = myGetSSA( input_image, input_angle_t, C_Max, C_Min, flag )
       
% C_Max = 14;  %buffer length,  16,18,20
% C_Min = 4;   %minimal peak distance,  4,5

% % original input data
% raw_image_1(isnan(raw_image_1)) = 0;

% % 1, for each frame, calculate max_snr_points and save
% % 2, if max_snr_points start to increase, mark the minimum point
% % 3, mark the 4th minimum point to indicate a evaluation cycle
% % 4, calculate all parameters within this evaluation cycle

% parameters:
% 1, cycle interval
% 2, avrage walking speed
% 3, max/min hand swing speed
% 4, acceleration value
% 5, NDS/PDS/TSS
% 6, MAX SNR, MIN SNR, MEAN SNR

input_image(isnan(input_image)) = 0; %original input data

%max snr points variable
core_index  = [];    %max snr doppler index of all frames
core_buffer = [];   %length C_Max buffer of max_snr
core_peaks = [];    %max snr peaks of each frame
core_value = [];    %max snr values of each frame
core_angle = [];    %angle of each max snr point
core_peaks_count = 1;
core_count = 1;          %buffer count
core_last = 0;      
core_empty = 0;
core_cycle = [];
core_dir = 0;    % 1: up ramp, 2: down ramp

%max doppler points variable
max_doppler_index  = [];   %max doppler index of all frames
max_doppler_buffer = [];
max_doppler_snr_buffer = [];
max_doppler_angle_buffer = [];
max_doppler_peaks = [];
max_doppler_value = [];
max_doppler_angle = [];
max_doppler_peaks_count = 1;
max_doppler_PDS = [];
max_doppler_count = 1;
max_doppler_last = 0;   
max_doppler_empty = 0;
max_doppler_cycle = [];
max_doppler_dir = 0;    % 1: up ramp, 2: down ramp

%min doppler points variable
min_doppler_index  = [];   %min doppler index of all frames
min_doppler_buffer = [];
min_doppler_snr_buffer = [];
min_doppler_angle_buffer = [];
min_doppler_peaks = [];
min_doppler_value = [];
min_doppler_angle = [];
min_doppler_peaks_count = 1;
min_doppler_NDS = [];
min_doppler_count = 1;
min_doppler_last = 0;    
min_doppler_empty = 0;
min_doppler_cycle = [];
min_doppler_dir = 0;    % 1: up ramp, 2: down ramp

% all parameters:
walk_mean_v = [];
walk_count = 1;

current_sum = zeros(128, 1);         %sum of current frame

for f = 1:size(input_image,3)
    
    current_image = squeeze( input_image(:,:,f) );
    
    mask_image = current_image;
    mask_image(mask_image>0) = 1;
    
    current_angle = squeeze( input_angle_t(:,:,f) );
    current_angle(isnan(current_angle)) = 0;
    current_angle = mask_image.*current_angle;
    
    %sum up the doppler data
    for i =1:128
        current_sum(i) = sum( current_image(:,i) );
    end
    
    %get the max snr point as core
    core_index(f) = find(current_sum == max(current_sum), 1);    
    core_angle(f) = mean(current_angle(:,core_index(f)));
    
    %no max_snr_point found in frame
    if(current_sum(core_index(f))==0)
        continue;
    end
    
    tmp_min = 0;
    angle_min = 0;
    %find minimal doppler 
    for i =1:128
        if( current_sum(i) > 0 )
            tmp_min = i;
            
            %find angle of min doppeler
            angle_min = mean(current_angle(:,i));
            break;
        end
    end
    
    tmp_max = 0;
    angle_max = 0;
    %find maximal doppler 
    for i =128:-1:1
        if( current_sum(i) > 0 )
            tmp_max = i;
            
            %find angle of max doppeler
            angle_max = mean(current_angle(:,i));
            break;
        end
    end
    
    %if no data found in frame, use old data
    if(tmp_min == 0)&&( f > 1 )
        min_doppler_index(f) = min_doppler_index(f-1);
    else
        min_doppler_index(f) = tmp_min;
    end
    
    if(tmp_max == 0)&&( f > 1 )
        max_doppler_index(f) = max_doppler_index(f-1);
    else
        max_doppler_index(f) = tmp_max;
    end
     
%     %max_snr correction goes here:
%     %max_snr max change limit = 3(frequency bin) per frame
%     if( f > 1 )
%         max_snr_diff = max_snr_index(f)-max_snr_index(f-1);
%         if( max_snr_diff > 3 )
%             max_snr_index(f) = max_snr_index(f-1)+2;
%         elseif( max_snr_diff < -3 )
%             max_snr_index(f) = max_snr_index(f-1)-2;
%         end
%     end
   
    
    %1, core peak detection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    core_buffer(core_count) = core_index(f);
    
    if( core_count >= C_Max)
        
        %find all the peaks/trough in tmp_points at least C_Min apart
        extreme_main = myFindExrtreme1DAuto(core_dir, core_buffer, C_Min);
        
        if(isempty(extreme_main))
            extreme_main = C_Max-2*C_Min-1;
            core_empty = core_empty + 1;
        else
            % save the peak
            % 1, cycle interval
            % 2, avrage walking speed
            % 4, acceleration value
            
            core_peaks(core_peaks_count) = extreme_main+core_last;
            core_value(core_peaks_count) = core_buffer( extreme_main );
            walk_mean_v(core_peaks_count) = mean( core_buffer(1:(extreme_main+C_Min)) );
            core_cycle(core_peaks_count) = (extreme_main+C_Min) + core_empty*(C_Max-2*C_Min-1);
            core_empty = 0;
            
            % calculate acceleration for each peak/trough
            % find the following trough for peak( peak for trough)
            for k = extreme_main:(C_Max-1)
                % for value below 65, find the following trough for peak
                if( core_buffer(k) < 65 )
                    %trends goes up, a trough found
                    if( core_buffer(k) <= core_buffer(k+1) )
                        walk_acceleration(core_peaks_count) = (core_buffer(extreme_main)-core_buffer(k))/(k-extreme_main);
                    end

                % for value above 65, find the following peak for trough
                else
                    %trends goes down, a peak found
                    if( core_buffer(k) >= core_buffer(k+1) )
                        walk_acceleration(core_peaks_count) = (core_buffer(k)-core_buffer(extreme_main))/(k-extreme_main);
                    end
                end
            end

            core_peaks_count = core_peaks_count + 1;   
        end
        
%         %check direction
%         if(core_buffer(extreme_main+C_Min) < core_buffer(extreme_main+C_Min+1) )
%             core_dir = 1;  % up ramp
%         elseif( core_buffer(extreme_main+C_Min) > core_buffer(extreme_main+C_Min+1) )
%             core_dir = 0;  % down ramp
%         end

        %adjust tmp data points and index
        core_buffer(1:(extreme_main+C_Min)) = [];
        core_count = core_count - (extreme_main+C_Min);
        core_last = core_last + (extreme_main+C_Min);
    end
    
    core_count = core_count + 1;
    
    %2, max doppler peak detection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    max_doppler_buffer(max_doppler_count) = max_doppler_index(f);
    max_doppler_snr_buffer(max_doppler_count) = core_index(f);
    max_doppler_angle_buffer(max_doppler_count) = angle_max;
    
    if( max_doppler_count >= C_Max)
        
        doppler_main = myFindPeakOne(max_doppler_dir, max_doppler_buffer, C_Min);
        
%         max_doppler_buffer
%         doppler_main
%         max_doppler_empty
        
        if(isempty(doppler_main)||isnan(doppler_main))
            doppler_main = C_Max-2*C_Min-1;
            max_doppler_empty = max_doppler_empty + 1;
        else
            % save the peak & calculate PSS
            max_doppler_peaks(max_doppler_peaks_count) = doppler_main+max_doppler_last;
            max_doppler_value(max_doppler_peaks_count) = max_doppler_buffer( doppler_main );
            max_doppler_angle(max_doppler_peaks_count) = max_doppler_angle_buffer( doppler_main );
            max_doppler_PDS(max_doppler_peaks_count) = max_doppler_buffer(doppler_main) - max_doppler_snr_buffer(doppler_main);
            max_doppler_cycle(max_doppler_peaks_count) = doppler_main+C_Min + max_doppler_empty*(C_Max-2*C_Min-1);
            max_doppler_empty = 0;

            max_doppler_peaks_count = max_doppler_peaks_count + 1;
        end
        
        %check direction
        if( max_doppler_buffer(doppler_main+C_Min)<max_doppler_buffer(doppler_main+C_Min+1) )
            max_doppler_dir = 1;  % up ramp
        elseif( max_doppler_buffer(doppler_main+C_Min)>max_doppler_buffer(doppler_main+C_Min+1) )
            max_doppler_dir = 0;  % down ramp
        end

        %adjust tmp data points and index
        max_doppler_buffer(1:(doppler_main+C_Min)) = [];
        max_doppler_snr_buffer(1:(doppler_main+C_Min)) = [];
        max_doppler_angle_buffer(1:(doppler_main+C_Min)) = [];
        
        max_doppler_count = max_doppler_count - (doppler_main+C_Min);
        max_doppler_last = max_doppler_last + (doppler_main+C_Min);
    end
    
    max_doppler_count = max_doppler_count + 1;
    
    %3, min doppler trough detection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    min_doppler_buffer(min_doppler_count) = min_doppler_index(f);
    min_doppler_snr_buffer(min_doppler_count) = core_index(f);
    min_doppler_angle_buffer(min_doppler_count) = angle_min;
    
    if( min_doppler_count >= C_Max)
        
        doppler_main = myFindTroughOne(min_doppler_dir, min_doppler_buffer, C_Min);
        
        if(isempty(doppler_main)||isnan(doppler_main))
            doppler_main = C_Max-2*C_Min-1; %C_Max-C_Min-1;
            min_doppler_empty = min_doppler_empty + 1;
        else
            % save the peak & calculate NSS
            min_doppler_peaks(min_doppler_peaks_count) = doppler_main+min_doppler_last;
            min_doppler_value(min_doppler_peaks_count) = min_doppler_buffer( doppler_main );
            min_doppler_angle(max_doppler_peaks_count) = min_doppler_angle_buffer( doppler_main );
            min_doppler_NDS(min_doppler_peaks_count) = min_doppler_snr_buffer(doppler_main) - min_doppler_buffer(doppler_main);
            min_doppler_cycle(min_doppler_peaks_count) = doppler_main+C_Min + min_doppler_empty*(C_Max-2*C_Min-1);
            min_doppler_empty = 0;

            min_doppler_peaks_count = min_doppler_peaks_count + 1;
        end
        
        %check direction
        if( min_doppler_buffer(doppler_main+C_Min)<min_doppler_buffer(doppler_main+C_Min+1) )
            min_doppler_dir = 1;  % up ramp
        elseif( min_doppler_buffer(doppler_main+C_Min)>min_doppler_buffer(doppler_main+C_Min+1) )
            min_doppler_dir = 0;  % down ramp
        end
        
        %adjust tmp data points and index
        min_doppler_buffer(1:(doppler_main+C_Min)) = [];
        min_doppler_snr_buffer(1:(doppler_main+C_Min)) = [];
        min_doppler_angle_buffer(1:(doppler_main+C_Min)) = [];
        
        min_doppler_count = min_doppler_count - (doppler_main+C_Min);
        min_doppler_last = min_doppler_last + (doppler_main+C_Min);
    end
    
    min_doppler_count = min_doppler_count + 1;
    
end

% remove blank frames
core_index(core_index<10) = [];
max_doppler_index(max_doppler_index<10) = [];
min_doppler_index(min_doppler_index<10) = [];

%%%%%%%%%%%%%%%%% peak analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(flag==1)
    figure
    plot(core_index); hold on
    plot(core_peaks, core_value, '*');
    % tabulate(max_snr_cycle)

    plot(max_doppler_index); hold on
    plot(max_doppler_peaks, max_doppler_value, '*');
    % tabulate(max_doppler_cycle)

    plot(min_doppler_index); hold on
    plot(min_doppler_peaks, min_doppler_value, '*');
    % tabulate(min_doppler_cycle)
    xlabel( 'time (frame), measurements' );
    ylabel('doppler, 128 bin');
    title( 'extreme point analysis');
    % xlim([500 550]);
    % ylim([55 95]);
end

%%%%%%%%%%%%%%%%%% cycle analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

core_cycle(core_cycle > C_Max) = [];
max_doppler_cycle(max_doppler_cycle > C_Max) = [];
min_doppler_cycle(min_doppler_cycle > C_Max) = [];

core_cycle(core_cycle < C_Min) = [];
max_doppler_cycle(max_doppler_cycle < C_Min) = [];
min_doppler_cycle(min_doppler_cycle < C_Min) = [];

cycle = [ mean(core_cycle) mean(max_doppler_cycle) mean(min_doppler_cycle) ]

% disp();
% 
% %max_snr_cycle
% size_1 = size(max_snr_cycle,2);
% size_1 = floor(size_1/2)*2;
% 
% even_1 = max_snr_cycle(1:2:size_1);
% odd_1 = max_snr_cycle(2:2:size_1);
% 
% max_snr_cycle = even_1 + odd_1;
% 
% %max_doppler_cycle
% size_2 = size(max_doppler_cycle,2);
% size_2 = floor(size_2/2)*2;
% 
% even_2 = max_doppler_cycle(1:2:size_2);
% odd_2 = max_doppler_cycle(2:2:size_2);
% 
% max_doppler_cycle = even_2 + odd_2;
% 
% %max_doppler_cycle
% size_3 = size(max_doppler_cycle,2);
% size_3 = floor(size_3/2)*2;
% 
% even_3 = min_doppler_cycle(1:2:size_3);
% odd_3 = min_doppler_cycle(2:2:size_3);
% 
% min_doppler_cycle = even_3 + odd_3;


if(flag==1)
    % figure
    figure('Renderer', 'painters', 'Position', [10 10 900 400]);

    subplot(1,3,1);
    a = core_cycle;
    b = histc(a, unique(a));
    bar( unique(a), b);
    xlabel('cycle length');
    ylabel('count');
    title( 'core\_cycle');

    subplot(1,3,2);
    a = max_doppler_cycle;
    b = histc(a, unique(a));
    bar( unique(a), b);
    xlabel('cycle length');
    ylabel('count');
    title( 'maxDS\_cycle');

    subplot(1,3,3);
    a = min_doppler_cycle;
    b = histc(a, unique(a));
    bar( unique(a), b);
    xlabel('cycle length');
    ylabel('count');
    title( 'minDS\_cycle');

    
    % figure
    % plot(min_doppler_angle); hold on
    % plot(max_doppler_angle);
    % title( 'min/max doppler angle');


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     figure
%     plot(min_doppler_NDS); hold on
%     plot(max_doppler_PDS);
%     xlabel('cycle number');
%     ylabel('count');
%     title( 'NDS & PDS');
%     legend({'NDS', 'PDS'});
%     var_PDS = var(max_doppler_PDS)
%     var_NDS = var(min_doppler_NDS)
% 
    figure
    plot(walk_mean_v); hold on
%     plot([0 70],[64 64],'HandleVisibility','off');
    xlabel('cycle number');
    ylabel('doppler');
    title('walk\_mean\_v');


    % % figure
    % % plot(max_doppler_value); hold on
    % % plot(min_doppler_value);
    % % title('min,max\_doppler\_value');


%     figure
%     plot(walk_acceleration);
%     xlabel('cycle number');
%     ylabel('doppler/cycle');
%     title('walk\_acceleration');
%     var_acc = var(walk_acceleration)


    % max_snr_cycle(69:73) = 0;
    % min_doppler_cycle(67:73) = 0;
    % 
    % main = [ max_snr_cycle; max_doppler_cycle; min_doppler_cycle ]; 

    % figure;
    % plot(max_doppler_angle);
    % figure;
    % plot(min_doppler_angle);
end

% figure
% 
% subplot(1,2,1);
% a = core_cycle;
% b = histc(a, unique(a));
% bar( unique(a), b);
%     
% subplot(1,2,2);
% a = diff(core_peaks);
% b = histc(a, unique(a));
% bar( unique(a), b);