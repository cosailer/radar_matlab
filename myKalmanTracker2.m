%% smart kalman tracker to track multiple targets
%  input_peak_image: input radar signal that contains local maxima
%  output_track(size, 7, id) : ouput track 3D-matrix output[ x, y, vx, vy, r, d, phi ]
%  gate: distance for track association
%  penalty: maximum allowed penalty
%  std_error: the maximum allowed std_error

% https://github.com/huanglianghua/mot-papers/blob/master/README.md

function [ output_track ] = myKalmanTracker2( input_peak_image, input_angle_t, gate, penalty, std_error)

MAX_VAL = 4096;

% define global variables for easy manipulations
% constants
global e  T  X0  P0  A  Ex  Ez  H;

e = 1e-2;
T = 59.3e-3;

X0 = [ 0  0  0  0  ]';   % states
                         % X(1,1):  x,  X(1,2):y, X(1,3):v_x,  X(1,4):v_y

P0 = [ 0  0  0  0  ;   % covariance matrix
       0  0  0  0  ;
       0  0  0  0  ;
       0  0  0  0 ];
   
% P0 = [ 0.0023  0      0.0052 0       ;  % updated covariance matrix
%        0       0.0023 0      0.0052  ;
%        0.0052  0      0.0248 0       ;
%        0       0.0052 0      0.0248 ];

% P0 = [ 0.0081  0       0.0121  0       ;
%        0       0.0081  0       0.0121  ;
%        0.0121  0       0.0379  0       ;
%        0       0.0121  0       0.0379 ];

A = [ 1  0  T  0  ;     % state transition matrix
      0  1  0  T  ;
      0  0  1  0  ;
      0  0  0  1 ];

Ex = [ T^4/4   0   T^3/2   0   ;     % covariance matrix transition matrix
         0   T^4/4   0   T^3/2 ;
       T^3/2   0    T^2    0   ;
         0   T^3/2   0    T^2 ];

Ez = [ e  0  ;        %observation noise
       0  e ];
   
H = [ 1  0  0  0  ;   %observation matrix, define what variabe to observe
      0  1  0  0 ];

% track information
global X X_p   P P_p   K   t;
global track_state   track_penalty   track_alive  track_std   error_mean   output;

% init first ouput track 3D-matrix output[ t, (x, y, v_x, v_y, r, d, phi), track]
output = zeros( size(input_peak_image,3), 7, 1 );

% init_input = [ 0 0 0 0 0 0 0 ];
% add_track( init_input, 1 );

track_state = zeros( 1, 1 );
track_penalty = zeros( 1, 1 );
track_std = zeros( 1, 1 );
track_alive = zeros( 1, 1 );

X(:,1) = X0;
X_p(:,1) = X0;
P(:,:,1) = P0;
P_p(:,:,1) = P0;
K(:,:,1) = zeros(4,2);

disp('> iteration begin');
% for each frame
for t = 2:size(input_peak_image,3)
% for t = 2:600
    
    % >> 1, find all detections at t, store them at track_input[:][7]
    
    % reset
    target_count = 1;
    track_input = [];
    cost = [];
    distance = [];
    
    %get current track count
    track_count = size(output, 3);
    track_list = 1:track_count;
    
    %do kalman predict for all tracks
    for f = 1:track_count
        % kalman predict
        X_p(:,f)   = A*X(:,f);
        P_p(:,:,f) = A*P(:,:,f)*A'+Ex;
          K(:,:,f) = P_p(:,:,f)*H' / (H*P_p(:,:,f)*H'+Ez);  
    end
    
    %for each frame input
    for r = 1:size(input_peak_image,1)
        for d = 1:size(input_peak_image,2)
            
            % skip nan
            if( isnan(input_peak_image(r,d,t)) )
                continue;
            end

            phi = myCalAngleAverage( r, d, input_angle_t(:, :, t) );
            
            polar = [r, d, phi,t];
            cartesian = myPolarToCartesianAll( polar, 1);
            
            if( isnan(cartesian(1)) )
                continue;
            end
            
%             cartesian(3:4) = 0;
            
            % compare cartesian(x,y,v_x,v_y) with X_p(1,:,f)
            % calculate distance array
            for f = 1:track_count
                % use the kalman prediction to calculate distance matrix
                distance(target_count,f) = ( cartesian(1)-X_p(1,f) )^2 + ( cartesian(2)-X_p(2,f) )^2;
                
%                 % state 1 target, apply weight
%                 if(track_state(f) == 1)
%                     distance(target_count,f) = distance(target_count,f)*0.5;
%                 end
            end
            
            %  store the detection point [ ID, x, y, v_x, v_y, r, d, angle ]
            track_input(target_count, :) = [ target_count cartesian(1:4) r d phi ];
            target_count = target_count + 1;
        end
    end
    
    % if no target detected
    if( ( isempty(track_input) ) )
       
        % all track penalty +1
        for f = 1:track_count
            
            % use track old position
%             output(t,:,f) = output(t-1,:,f);
            
            % use current prediction 
            output(t,1:4,f) = X_p(:,f);
            output(t, 5:7, f) =  output(t-1, 5:7);
            
            track_penalty(f) = track_penalty(f) + 1;
        end
        
        continue;
    end
    
    % >> 2, apply gate limit
    distance(distance > gate^2) = MAX_VAL;
    
    % >> 3, minimize the distance matrix, 
    %       if a track has all distance = 4096, mark for removal
    %       if a target has all distance = 4096, mark for removal
          
    %       find all points within the gate range and store them in
    %       cost_input[:][7]
    
    %make a track_list and a target_list from distance matrix
    
    target_count = size(distance, 1);
    target_list = 1:target_count;
    target_remain = 1:target_count;
    
    %for each target
    for i = 1:size(distance, 1)
        
        mark = 0;
        %check each track
        for j = 1:size(distance, 2)
            if(distance(i,j) ~= MAX_VAL)
                mark = 1;
                break;
            end
        end
        
        %distance values for this target is all MAX_VAL
        %then this target will not be in the assignment process
        if(mark == 0)
            target_list(i) = -1;
        end
    end
    
    %for each track
    for j = 1:size(distance, 2)
        
        mark = 0;
        %check each target
        for i = 1:size(distance, 1)
            if(distance(i,j) ~= MAX_VAL)
                mark = 1;
                break;
            end
        end
        
        %distance values for this target is all MAX_VAL
        %then this target will not be in the assignment process
        if(mark == 0)
            track_list(j) = -1;
        end
    end
    
    %extract the minimal cost matrix for assignments
    track_list(track_list == -1) = [];
    target_list(target_list == -1) = [];
    
    %form minimized cost matrix
    cost = distance(:, track_list);
    cost = cost(target_list, :);
    
    % >> 4, Hungarian assignment
    % if cost is not square matrix, the solutions may contain NaN
    [ path_cost, solutions, cost_updated ] = myHungarianAssociator(cost);
    
%     
%     track_list(i) : track assignment for distance 
%     target_list(solutions(i)) : target assignment for distance 
    
%    check each cost, only focus on the cost < MAX_VAL
%    here use size(cost,2) to ignore extra solution if targets_num >
%                                                      track_num
    for i = 1:size(cost,2)
        
        %mark track_list and target_list for removal, no assignment
        if(  isnan(solutions(i))||( cost(solutions(i), i) >= MAX_VAL))
            track_list(i) = -1;
            solutions(i) = -1;
        end
    end
    
    %remove all 0s
    track_list(track_list == -1) = [];
    solutions(solutions == -1) = [];

    %remove targets from original target list
    %find the remaining target list that is not associated with any track
    for i = 1:size(target_list,2)
        target_remain(target_remain==target_list(i)) = [];
    end
    
    % >> 5, Kalman update for assigned track here for each frame.
    for f = 1:size(track_state,2)
        
        input_cartesian = zeros(8, 1);
        
        index = find(track_list == f);
        
        % if current track has no input update
        if( isempty(index) )
            
            % increase penalty and skip kalman update
            track_penalty(f) = track_penalty(f) + 1;
            
            % use track old position
            output(t,:,f) = output(t-1,:,f);
            
            % use current prediction
%             input_cartesian(2:8) = [ X_p(1:4,f) ; output(t-1,5:7,f)' ];
            
            continue;

        else
            % reset penalty
            track_penalty(f) = 0;
            track_alive(f) = track_alive(f) + 1;
            
            % use correct input
            input_cartesian = track_input(target_list(solutions(index)),:)';

            %use predicted vx and vy
            input_cartesian(4:5) = X_p(3:4,f);
        end
        
        % kalman update with track_input(solution(i),:)
        X(:,f) = X_p(:,f)+K(:,:,f)*( H*input_cartesian(2:5) - H*X_p(:,f) );  
        P(:,:,f) = (eye(4)-K(:,:,f)*H) * P_p(:,:,f);
        
        % update filtered track result
        % (r, d) and [ X(1,1,f), X(1,2,f) ]
        output(t,1:4,f) = X(:,f);
%         output(t,1:4,f) = input_cartesian(2:5);
        output(t,5:7,f) = input_cartesian(6:8);
        
        % calculate track error
        track_std(t,f) = sqrt( ( X(1,f)-input_cartesian(2) )^2 + ( X(2,f)-input_cartesian(3) )^2 );
    end
    
    % >> track management
    %    state  0: untracked
    %    state  1: tracked
    %    state -1: lost
    %
    %    if in state  0, track_alive > 20, state 0 -> state 1
    %    if in state  0, track_penalty > 10, state 0 -> state -1
    %    if in state  1, track_penalty > 50, state 1 -> state 0
    %    if in state  1, error_mean > 15, state 1 -> state 0
    %    if in state -1, track will be deleted
    
    rr = 1;
    remove_list = [];
    
    for f = 1:track_count
        
        %calculate mean error
        error_mean(f) = mean( nonzeros( track_std(:,f) ) );
        
        % state  0: untracked
        if( track_state(f) == 0)
            
            if( track_alive(f) >= 20 )
                track_state(f) = 1;
                track_penalty(f) = 0;
            end
            
            if( track_penalty(f) >= 10 )
                track_state(f) = -1;
            end
        
        % state  1: tracked
        elseif( track_state(f) == 1)
            
            if( track_penalty(f) >=  penalty )
                track_state(f) = 0;
                track_penalty(f) = 0;
                track_alive(f) = 0;
            end
            
            if( error_mean(f) > std_error )
                track_state(f) = 0;
                track_penalty(f) = 0;
                track_alive(f) = 0;
            end
            
        end
        
        % state -1: lost
        if(track_state(f) == -1)
            remove_list(rr) = f;
            rr=rr+1;
        end
    end
    
    remove_track(remove_list);
    
    track_count = size(output, 3);
    
    % new tracks for all remaining targets
    for i = 1:size(target_remain,2)
        track_count = track_count + 1;
        disp( [ '  t=' num2str(t) ', track added, Num=' num2str(track_count) ] );
        init_input = track_input( target_remain(i), 2:8 ); 
        add_track( init_input, track_count );
    end

end
    
% post processing for ouput tracks
output(output == 0) = nan;

% remove tracks that has less than 100 data points
% remove_track_less(50);
% remove_alive_less(30);
remove_state_0();
output_track = output;

disp('> done');

end


%% in-script function section
% this function add a new track to existing tracks
% modifying global variables
function add_track( init_input, track_count )
    %disp( [ 'new track added, case 1, t=' num2str(t) ', Num=' num2str(track_count) ] );
    global P0  A  Ex  Ez  H;
    global X X_p   P P_p   K   t;
    global track_state  track_penalty  track_alive  output  track_std  error_mean;

    % init new track
    output( t, :, track_count ) = init_input( : );

    X(:,track_count) = init_input(1:4)';
    P(:,:,track_count) = P0;

    % kalman prediction for new tracks
    X_p(:,track_count) = A*X(:,track_count);
    P_p(:,:,track_count) = A*P(:,:,track_count)*A'+Ex;
    K(:,:,track_count) = P_p(:,:,track_count)*H' / (H*P_p(:,:,track_count)*H'+Ez);  
    
    track_state(track_count) = 0;
    track_penalty(track_count) = 0;
    track_alive(track_count) = 0;
    track_std(:,track_count) = 0;
    error_mean(track_count) = 0;
end

% this function remove tracks marked in list from existing tracks
% modifying global variables
function remove_track(remove_list)

    global X X_p   P P_p   K   t;
    global track_state   track_penalty   track_alive track_std   error_mean   output;

    if( ~isempty(remove_list) )

        disp( ['  t=' num2str(t) ', tracks removed,     Num=' num2str(remove_list) ]);

        %remove tracks by index
          X(:,remove_list) = [];
        X_p(:,remove_list) = [];
          P(:,:,remove_list) = [];
        P_p(:,:,remove_list) = [];
          K(:,:,remove_list) = [];
        track_std(:,remove_list) = [];
        output(:,:,remove_list) = [];

        %update track_penalty at last
        track_state(remove_list) = [];
        track_penalty(remove_list) = [];
        track_alive(remove_list) = [];
        error_mean(remove_list) = [];
    end
end

% this function remove track that has less data
% limit : data limit, can be 100 or 200 
function remove_track_less( limit )

    global output;
    rr = 1;
    remove_list = [];

    for f = 1:size(output,3)

        data_size(f) = size(nonzeros(~isnan( output(:,3,f) )),1);
        data_size_unique = size(nonzeros(~isnan( unique(output(:,3,f) ))),1);

        if( data_size(f) < limit )||(data_size_unique < 20)

            remove_list(rr) = f;
            rr = rr + 1;
        end
    end
    
    remove_track(remove_list);
    data_size(remove_list) = [];
    
    disp('> final track info:');
    for f = 1:size(data_size,2)
        disp( ['  track ' num2str(f) ', size = ' num2str(data_size(f))] );
    end
end

% this function remove track that has less alive count compard to maximum
function remove_alive_less( limit )
    
    global track_alive;
    rr = 1;
    remove_list = [];
    
    max_live = max(track_alive);

    for f = 1:size(track_alive,2)
        
        if( track_alive(f) < (max_live - limit ) )
            
            %disp('removed dead track');
            %save the remove index
            remove_list(rr) = f;
            rr = rr + 1;
        end
    end
    
    remove_track(remove_list);
end

% this function remove track that in state 0
function remove_state_0()
    global track_state;
    rr = 1;
    remove_list = [];
    
    for f = 1:size(track_state,2)
        % state -1: lost
        if(track_state(f) == 0)
            remove_list(rr) = f;
            rr=rr+1;
        end
    end
    
    remove_track(remove_list);
end


