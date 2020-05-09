%% this script takes the tcpdump data file and process and save to m file


function myPADC( packets_file_name )
% %clear previous data
% clear;
tic
packets_raw = fread( fopen( packets_file_name ) );
[~,save_name] = fileparts(packets_file_name);

% first 24 bytes is global header
gheader_size = 24;

% header size
header_size = 16+42;
payload_size = 515;

% then 58 bytes UDP header + 515 bytes payload
record_size = header_size + payload_size;

% check packet type, make sure its ADC samples with header 0x2014
if( packets_raw(24+16+42+1) ~= 32 )||( packets_raw(24+16+42+2) ~= 20 )
    disp('>> Wrong Packet Type ! exiting...');
    return;
end

% get the total packet number
packet_num = ( size(packets_raw,1)-gheader_size )/record_size;

packet_num = round(packet_num);

% parse the packets
packets= zeros(packet_num, record_size);

for i = 1:packet_num
    for k = 1:record_size
        packets(i, k) = packets_raw( gheader_size + record_size*(i-1) + k );
    end
end

% extract payload, ignore udp header

% packets8 = uint8(packets(:,59:end));
packets8 = uint8(packets);

%  checks for sample loss within each frame
%  the actual acount of sample loss is not measured as its not important
%  the measurement/frame(per 128 chirps) count is measured

index = 0;
loss_occ = 0;
frame_num = 0;

% forward loop
for i = 1:packet_num
    if packets8(i,3+58) ~= index   % check current packet index
%         disp(['   packets loss at ' num2str(i)]);
        loss_occ = loss_occ + 1;
        
        % avoid skipping frame count later
        if packets8(i,3+58) < index
            frame_num = frame_num + 1;
        end
        
        index = packets8(i,3+58);
    end
    
    if(index == 127)
        index = 0;
        frame_num = frame_num + 1;
    else
        index = index + 1;
    end
end

% total frame count must - 1, since last loop add 1
frame_num = frame_num - 2;

fprintf( '\n> packet processing...\n' );
fprintf( '  input file : %s\n', packets_file_name );
fprintf( '  packet loss occurrence : %d\n', loss_occ );
fprintf( '  total frame number : %d\n', frame_num );

%  remove the extra unwanted packets at the beginning and at the end,
%  if there is any

% find the start and the end
index_start = 0;
index_end   = 0;

for i = 1:packet_num
    if packets8(i,3+58) == 0
        index_start = i;
        break
    end
end

for i = packet_num:-1:1
    if packets8(i,3+58) == 127
        index_end = i;
        break
    end
end

% remove packets
fprintf( '  total packets before removal : %d\n', packet_num );
packets8 = packets8(index_start:index_end,:);
packet_num = size(packets8,1);

time_stamp  = zeros(frame_num,1);

% extract time stamp for each chirp to a seperate array
chirp_num = 0;

for i = 1:frame_num
    if packets8( (i-1)*128+1+chirp_num,3+58) == chirp_num
        
        % first 4 byte is sec
        time_stamp(i) = typecast(packets8((i-1)*128+1+chirp_num,1:4), 'uint32');
        
        % then 4 bytes microsec
        time_stamp(i) = time_stamp(i) + 1e-6*double(typecast(packets8((i-1)*128+1+chirp_num,5:8), 'uint32'));
    end
end

% discard time stamp
packets8 = packets8(:,59:end);

fprintf( '  total packets after removal : %d\n', packet_num );

time_elapse = time_stamp(end) - time_stamp(1);
fprintf( '  total frame time elapsed : %0.2f s\n', time_elapse );

fm = frame_num / time_elapse;
fprintf( '  measurement frequency : %0.2f fps\n', fm );

fprintf('> packet extraction complete\n\n');

% packets8 = uint8(packets);

adc_samples   = zeros(128, 256);            % all adc samples
adc_ant_1 = zeros(128, 128, frame_num);     % adc sample for antenna 1
adc_ant_2 = zeros(128, 128, frame_num);     % adc sample for antenna 2

fft5_value_1 = zeros(128, 128, frame_num);  % final fft data for antenna 1
fft5_value_2 = zeros(128, 128, frame_num);  % final fft data for antenna 1
% cfar_image_1 = zeros(128, 128, frame_num);  % cfar data for antenna 1
% cfar_image_2 = zeros(128, 128, frame_num);  % cfar data for antenna 1

phase_diff = zeros(128, 128, frame_num);  % raw phase difference between antenna 1 and 2
angle_t    = zeros(128, 128, frame_num);  % calculate angle between antenna 1 and 2, non-calibrated


% setup window matrix
window = hanning(128);
window = window( :, ones(128,1) );

%% radar data processing
%
fprintf('> post data processing...\n  progress:  ');
back=0;

% for each frame
for r = 1:frame_num
    for i = 1:128
        %convert to int16
        for k = 1:256
            adc_samples(i, k) = typecast( [ packets8(i+128*(r-1),2*k+3) packets8(i+128*(r-1),2*k+2) ], 'uint16');
        end
  
        adc_ant_1(i, :, r) = adc_samples(i, 1:128);
        adc_ant_2(i, :, r) = adc_samples(i, 129:256);
    end
  
    % get adc value
    fft0_value_1 = adc_ant_1(:, :, r);
    fft0_value_2 = adc_ant_2(:, :, r);
    
    % 1st fft - row wise
    fft1_value_1 = fft(window'.*fft0_value_1, [], 2);
    fft1_value_2 = fft(window'.*fft0_value_2, [], 2);
    
    % 2nd fft - colum wise and fft shift
    fft3_value_1 = fftshift(fft(window.*fft1_value_1, [], 1));
    fft3_value_2 = fftshift(fft(window.*fft1_value_2, [], 1));
    
    % rotate image to change x and y axis
    fft3_value_1 = rot90(fft3_value_1, 3);
    fft3_value_2 = rot90(fft3_value_2, 3);
    
    % get magnitude
    fft4_value_1 = abs(fft3_value_1);
    fft4_value_2 = abs(fft3_value_2);
    
    % get raw phase difference
    phase_diff_tmp = angle(fft3_value_1.*conj(fft3_value_2));
    phase_diff(:, :, r) = phase_diff_tmp;
    
    % angle calculation
    phase_diff_tmp = phase_diff_tmp + pi*sin(18/180*pi);
    
    for i = 1:numel(phase_diff_tmp)
        if( phase_diff_tmp(i) > pi)
            phase_diff_tmp(i) = phase_diff_tmp(i) - 2*pi;
        end
        if( phase_diff_tmp(i) < -pi)
            phase_diff_tmp(i) = phase_diff_tmp(i) + 2*pi;
        end
    end
        %left being -, right being +, radian
    angle_t(:, :, r) = asin(phase_diff_tmp/pi);
    
    % fft5 : raw doppler data
    fft5_value_1(:, :, r) = fft4_value_1;
    fft5_value_2(:, :, r) = fft4_value_2;
    
    % ca-cfar calculation
%     cfar_image_1(:, :, r) = myCFAR2D( fft4_value_1 , 1, 2, 2, 2e-1 );
%     cfar_image_2(:, :, r) = myCFAR2D( fft4_value_2 , 1, 2, 2, 2e-1 );
    
    fprintf(repmat('\b',1,back));
    back = fprintf( '%0.2f %%', r*100/frame_num);
end

fprintf('\n  remove unuseful variables  ...\n');

clear adc_ant_1 adc_ant_2 adc_samples;
clear fft0_value_1 fft0_value_2;
clear fft1_value_1 fft1_value_2;
clear fft2_value_1 fft2_value_2;
clear fft3_value_1 fft3_value_2;
clear fft4_value_1 fft4_value_2;
clear packets packets8 packets_raw packet_num loss_occ;
clear phase_diff phase_diff_tmp window;
clear back gheader_size header_size payload_size record_size;
clear k r i index index_start index_end base;

fprintf('\n  saving file : %s.mat  ...\n', save_name);
save( [ save_name '.mat' ] );
fprintf('> done\n');
toc

