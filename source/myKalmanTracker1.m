%% simple kalman filter to smooth target track, only one track supported
%  input_single_image: input radar signal that contains local maxima

function [ output_track ] = myKalmanTracker1( input_peak_image, input_angle_t, gate )

output_track = zeros( size(input_peak_image,3), 7 );

e = 1e-2;
T = 59.3e-3;  

X =  [ 0  0  0  0 ]';  %states X(1,1):x,  X(1,2):y, X(1,3):v_x,  X(1,4):v_y
  
P = [ 0  0  0  0  ;    %covariance matrix
      0  0  0  0  ;
      0  0  0  0  ;
      0  0  0  0 ];

% P = [ 0.0023  0      0.0052 0       ;  % updated covariance matrix
%       0       0.0023 0      0.0052  ;
%       0.0052  0      0.0248 0       ;
%       0       0.0052 0      0.0248 ];
  
A = [ 1  0  T  0  ;    %state transition matrix
      0  1  0  T  ;
      0  0  1  0  ;
      0  0  0  1 ];

Ex = [ T^4/4   0   T^3/2   0   ;     % covariance matrix transition matrix
         0   T^4/4   0   T^3/2 ;
       T^3/2   0    T^2    0   ;
         0   T^3/2   0    T^2 ];


Ez = [ e  0  ;  %observation noise
       0  e ];

H = [ 1  0  0  0  ;    %observation matrix, define what variabe to observe
      0  1  0  0 ];

% %find maximum in the first frame
% first = squeeze(input_peak_image(:,:,1));
% 
% [r,d] = find(first == max(max(first)),1);
% phi = myCalAngleAverage( r, d, input_angle_t(:, :, 1) );
% polar = [r, d, phi, 1];
% cartesian = myPolarToCartesianAll( polar, 1);
% X(1)=cartesian(1);
% X(2)=cartesian(2);

% track_input=zeros(1,7);

%for each image
for t = 2:size(input_peak_image,3)
    
    target_count = 1;
    distance = [];
    track_input = [];
    
    %prediction for current track
    X_p = A*X;
    P_p = A*P*A' + Ex;
    
    %for all detection in current frame, find the distance
    %between prediction and all detection
    for r = 1:128
        for d = 1:128
            
            if( isnan(input_peak_image(r,d,t)) )
                continue;
            end
            
            phi = myCalAngleAverage( r, d, input_angle_t(:, :, t) );
            
            polar = [r, d, phi, t];
            cartesian = myPolarToCartesianAll( polar, 1);
            
            if( isnan(cartesian(1)) )
                continue;
            end
            
            distance(target_count) = ( cartesian(1)-X_p(1) )^2 + ( cartesian(2)-X_p(2) )^2;
            track_input(target_count, :) = [ cartesian(1:4) r d phi ];
            
            target_count = target_count + 1;
        end
    end
    
    % no update, use old track
    if( isempty(distance)|| isnan(distance(1)) )
         output_track(t, 1:4) = X_p';
         output_track(t, 5:7) =  output_track(t-1, 5:7);
         continue;
    end
    
    %find the smallest distance
    solution = find(distance == min(distance), 1);
    
    % if input is NaN, use prediction as input
    if( isnan(track_input(solution, 1)) )
        track_input(solution, 1:4) = X_p';
%         track_input(solution, 1:4) = output_track(t-1, 1:4);
        track_input(solution, 5:7) = output_track(t-1, 5:7);
    end
    
    % if input is too far away, use prediction as input
    if( distance(solution) > gate^2)
        track_input(solution, 1:4) = X_p';
%         track_input(solution, 1:4) = output_track(t-1, 1:4);
        track_input(solution, 5:7) = output_track(t-1, 5:7);
    end
    
    track_input(solution, 3:4) = X_p(3:4);
    
    %update
    K = P_p*H' / ( H*P_p*H' + Ez );  
    X = X_p + K * ( H*track_input(solution, 1:4)' - H*X_p );  
    P = ( eye(4) - K*H ) * P_p;
    
    output_track(t, 1:4) = X(:)';
%     r_original = track_input(solution,5);
%     r_estimate = round(sqrt(X(1)^2+X(2)^2))+64;
%     
% %     a = [ r_original r_estimate ]
%     
%     if( r_estimate < 64)
%         r_estimate = 64;
%     elseif( r_estimate > 128)
%         r_estimate = 128;
%     end
%     output_track(t, 5) = r_estimate;
%     output_track(t, 6:7) = track_input(solution,6:7);
    
    output_track(t, 5:7) = track_input(solution,5:7);
    
%     inputs(t,:) = track_input(solution,:);

end






% t

