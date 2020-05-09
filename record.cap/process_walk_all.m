% clear memory, figures, shell
clc;
clear;
close all;

% get all file with type *.cap
tcpdump_captures = dir('*.cap');
capture_list = { tcpdump_captures.name };

% process all adc data
len = size(capture_list,2);
for i = 1 : size(capture_list,2)
    fprintf( '\n> job %d out of %d... \n', i, len );
    myPADC( char( capture_list(i)) );
end

