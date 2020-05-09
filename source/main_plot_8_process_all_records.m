%% process all record files and extract all features

% clear memory, figures, shell
clc;
clear;
close all;

idx = [ "1.1", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "1.10" ];

record_size = 10;
record = cell(record_size,1);
%thredshold
Th1 = 5e2;
% Th2 = 8e4;
Th2 = 1e5;
% Th2 = Th1^2;

%noise
NR = 2;
NLEN = 20;

%detector
g = 5;
pattern_w = 15;
pattern_h = 5;
pattern_a = 5;
pfa = 1e-8;

%tracker
gate = 5;

%features
C_Max = 14;
C_Min = 4;

for i = 1:record_size
    recordname = "record_" + idx(i) + ".mat";
    
    disp( 'processing ' + recordname );
    record{i} = load( recordname );
    
    record{i}.raw_image_1 = record{i}.fft5_value_1;

    record{i}.time_stamp = record{i}.time_stamp - record{i}.time_stamp(1);
    record{i}.time_stamp(record{i}.time_stamp<0)=0;

    record{i}.angle_t = myCalAngle( record{i}.angle_t );
    record{i}.raw_image_1 = myRemClutter(record{i}.raw_image_1);
    record{i}.raw_image_1 = myRemEnvNoise( record{i}.raw_image_1, NLEN, NR );

    % index = 30:620;
    % raw_image_1 = raw_image_1( :, :, index );
    % angle_t = angle_t( :, :, index );
    % time_stamp   = time_stamp( index );
    % frame_num = size(raw_image_1, 3);

    record{i}.raw_image_2 = record{i}.raw_image_1;
    record{i}.raw_image_1( record{i}.raw_image_1 < Th1 ) = NaN;
    record{i}.peak_image_1 = myGetPeak2D(record{i}.raw_image_1, g);
    record{i}.peak_image_1 = myCFARPeak2D(record{i}.peak_image_1, record{i}.raw_image_2, 1, pattern_h, pattern_w, pfa);
    record{i}.output_track = myKalmanTracker1( record{i}.peak_image_1, record{i}.angle_t, gate );

    record{i}.raw_image_2 = myNormSNR( record{i}.raw_image_2 );
    record{i}.raw_image_2( record{i}.raw_image_2 < Th2 ) = NaN;
    [ record{i}.track_image_1, record{i}.power1 ] = myExtractPattern( record{i}.raw_image_2, record{i}.angle_t, pattern_h, pattern_w, pattern_a, record{i}.output_track(:,5:6)' );
%     myDisplayTrack( S{i}.peak_image_1,  S{i}.output_track, S{i}.angle_t);

    [ record{i}.core_cycle,   record{i}.max_doppler_cycle, record{i}.min_doppler_cycle, ...
      record{i}.min_doppler_NDS, record{i}.max_doppler_PDS, ...
      record{i}.walk_mean_v,     record{i}.walk_acceleration ] = myGetSSA( record{i}.track_image_1, record{i}.angle_t, C_Max, C_Min, 0);
    
    record{i}.angle_t = [];
    record{i}.fft5_value_1 = [];
    record{i}.fft5_value_2 = [];
    record{i}.raw_image_1 = [];
    record{i}.raw_image_2 = [];
    record{i}.track_image_1 = [];
    
end

save ssa.mat


