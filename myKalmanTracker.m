%% simple kalman filter to smooth target track

function [ output_track ] = myKalmanTracker( input_single_image )

output_track = zeros( size(input_single_image,3), 7 );

e = 1e-3;

X = [64 ; 64 ];   %states X(1,1):r,  X(1,2):d
P = [1 0; 0 1];   %covariance matrix
F = [1 1; 0 1];   %transfer matrix
Q = [e 0; 0 e];   %transfer matrix cov
H = [1 1];        %observation matrix
R = 1;            %observation noise
B = 0;            %control matrix

for t = 1:size(input_single_image,3)
    
    %find the detection
    image_tmp = input_single_image(:,:,t);
    image_tmp(isnan(image_tmp)) = 0;
    [ r_max, d_max ] = find( image_tmp );
    
    %update last detection
    if(isempty(r_max))
        r_max = r_max_last;
        d_max = d_max_last;
    else
        r_max_last = r_max;
        d_max_last = d_max;
    end
    
    input(1) = r_max;
    input(2) = d_max;
    
    %predict
    X_p = F*X;
    P_p = F*P*F'+Q;
  
    %update
    K = P_p*H'/(H*P_p*H'+R);  
    X = X_p+K*(input-H*X_p);  
    P = (eye(2)-K*H)*P_p;
    
    %set X bundary
    if(X(1,1) > 128)
        X(1,1) = 128;
    elseif(X(1,1) < 64)
        X(1,1) = 64;
    end
    
    if(X(1,2) > 128)
        X(1,2) = 128;
    elseif(X(1,2) < 1)
        X(1,2) = 1;
    end
    
    output_track(t, 5) = X(1,1);
    output_track(t, 6) = X(1,2);
    
end


