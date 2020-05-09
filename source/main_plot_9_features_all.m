%% feature analysis

% clear memory, figures, shell
clc;
clear;
close all;

load ssa.mat

index = [ 2 8 9 ];

%%%%%%%%%%%%%%%%%%% 1, mean walking v %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
for i = index
    txt = num2str(i);
    h1(i) = plot( record{i}.walk_mean_v, 'DisplayName', txt ); hold on
end
plot([0 60],[64 64],'HandleVisibility','off');
xlabel( 'cycle number' );
ylabel('doppler, 128 bin');
title( 'mean Doppler profile per cycle');
legend;

%%%%%%%%%%%%%%%%%%% 2, PDS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
for i = index
    txt = num2str(i);
    h2(i) = plot( record{i}.max_doppler_PDS, 'DisplayName', txt ); hold on
end
xlabel( 'cycle number' );
ylabel('doppler');
title( 'max Doppler PDS');
legend;

%%%%%%%%%%%%%%%%%% 3, NDS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
for i = index
    txt = num2str(i);
    h2(i) = plot( record{i}.min_doppler_NDS, 'DisplayName', txt ); hold on
end
xlabel( 'cycle number' );
ylabel('doppler');
title( 'min Doppler NDS');
legend;

%%%%%%%%%%%%%%%%%% 4, acceleration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
for i = index
    txt = num2str(i);
    h2(i) = plot( record{i}.walk_acceleration, 'DisplayName', txt ); hold on
end
xlabel( 'cycle number' );
ylabel('doppler');
title( 'acceleration');
legend;


%%%%%%%%%%%%%%%% 5, states %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% https://de.mathworks.com/help/stats/quality-of-life-in-u-s-cities.html

% core_cycle
% max_doppler_cycle
% min_doppler_cycle
% min_doppler_NDS
% max_doppler_PDS
% walk_mean_v
% walk_acceleration

data = [];

%make walk_mean_v and core_cycle the same length
for i = 1:10
    
    %find the min lenght of all 7 features
    min_size = size(record{i}.core_cycle,2);
    
    if( min_size > size(record{i}.max_doppler_cycle,2) )
        min_size = size(record{i}.max_doppler_cycle,2);
    end
    
    if( min_size > size(record{i}.min_doppler_cycle,2) )
        min_size = size(record{i}.min_doppler_cycle,2);
    end
    
    if( min_size > size(record{i}.max_doppler_PDS,2) )
        min_size = size(record{i}.max_doppler_PDS,2);
    end
    
    if( min_size > size(record{i}.min_doppler_NDS,2) )
        min_size = size(record{i}.min_doppler_NDS,2);
    end
    
    if( min_size > size(record{i}.walk_mean_v,2) )
        min_size = size(record{i}.walk_mean_v,2);
    end 
    
    if( min_size > size(record{i}.walk_acceleration,2) )
        min_size = size(record{i}.walk_acceleration,2);
    end
    
    min_size = round(min_size/2);
    
    record{i}.core_cycle = record{i}.core_cycle(1:min_size);
    record{i}.max_doppler_cycle = record{i}.max_doppler_cycle(1:min_size);
    record{i}.min_doppler_cycle = record{i}.min_doppler_cycle(1:min_size);
    record{i}.max_doppler_PDS = record{i}.max_doppler_PDS(1:min_size);
    record{i}.min_doppler_NDS = record{i}.min_doppler_NDS(1:min_size);
    record{i}.walk_mean_v = record{i}.walk_mean_v(1:min_size);
    record{i}.walk_acceleration = record{i}.walk_acceleration(1:min_size);

%     min_size = round(min_size/2);
% 
%     data_tmp = [];
%     data_tmp(1,:) = record{i}.core_cycle(1:min_size);
%     data_tmp(2,:) = record{i}.max_doppler_cycle(1:min_size);
%     data_tmp(3,:) = record{i}.min_doppler_cycle(1:min_size);
%     data_tmp(4,:) = record{i}.max_doppler_PDS(1:min_size);
%     data_tmp(5,:) = record{i}.min_doppler_NDS(1:min_size);
%     data_tmp(6,:) = record{i}.walk_mean_v(1:min_size);
%     data_tmp(7,:) = record{i}.walk_acceleration(1:min_size);
%     
%     
%     data =  [ data data_tmp ];

end



% index = [ 2 8 9 ];
% 
% 
% figure;
% for i = index
%     txt = num2str(i);
%     plot3( record{i}.walk_mean_v, record{i}.core_cycle , record{i}.max_doppler_PDS, '*', 'DisplayName', txt ); hold on; grid on
% end
% 
% legend;





