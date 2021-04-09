%% ------------------------------------------------------------------------
%   specify camera pose and parameters
%  ------------------------------------------------------------------------
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% camera setup parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %specify number of cameras
    camNum = 6;
    
    % Set the center of a sphere (use cartesian coordinates)
    % on which all camera views are oriented.
    % This center point will be the hypothetical "focal point" of the 
    % camera setup's objective lens. 
    center = [0,0,0];
 
    % Choose camera positions (use spherical coordinates)
    % must be specified in a matrix called "positions". Each row of this
    % matrix contains one camera's position in spherical coordinates, given
    % as [azimuth, elevation, radius]
    % NOTE: The number of positions must match the number of cameras
    % specified above! Failure to ensure this will crash the program.
    % (This example generates a set of equally spaced camera positions 
    % on a ring in space)
    
    %%%%%%%%%%
    % Parameters of the ring on which the cameras lie:
    %%%%%%%%%%
    
        % - hypothetical working distance L (between mesh and Cameras)
        L = 400;

        % - baseline (ring diameter for positioning the cameras)
        b = 30;

        %resulting radius
        r = sqrt(L^2+(b/2)^2); 
        %and elevation
        elev = pi/2-atan((b/2)/L);

        %Subdivide the ring into however many camera positions are desired   
        positions = repmat([0, elev, r],camNum,1);
        %calculate corresponding azimuths
        angle_increment = 2*pi/camNum;
        azimuth = angle_increment;
        for i = 1:camNum
            positions(i,1) = azimuth;
            azimuth = azimuth + angle_increment;
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% intrinsic camera parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %sensor dimensions in 'mm'
    %Example: Full frame DSLR format
    L_x = 36; %width
    L_y = 24; %height

    %sensor dimensions in 'pixels' 
    %Example: 7360px x 4912px
    N_x = 7360; 
    N_y = 4912;

    %principal point offset in 'pixels'
    o_x = 0;
    o_y = 0;