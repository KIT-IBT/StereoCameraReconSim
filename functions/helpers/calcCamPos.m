%% -------------------------------------------------------
%
%    calcCamPos  -  Converts camera Positions from spherical 
%                   to cartesian coordinates and builds the camera 
%                   coordinate system for each camera.
%     
%    Ver. 1.0
%
%    Created:           Jan Kost (15.09.2017)
%    Last modified:     Jan Kost (13.10.2020)
%
%    Institute of Biomedical Engineering
%    Karlsruhe Institute of Technology
%
%    http://www.ibt.kit.edu
%
%    Copyright 2020 - All rights reserved.
%
% ------------------------------------------------------
%
%  [camInfo,figHandle] = calcCamPos(posStruct,plot_do)
% 
%        posStruct: struct containing camera postitons in spherical 
%                   coordinates as well as the common focus point in 
%                   cartesian coordinates
%
%        dispPlot:  toggles plot visibiity (true to show figure window)
%        
%        output: 
%               camInfo:
%                   struct containing camera aperture positions, camera 
%                   coordinate system components and other camera 
%                   parameters for each camera.
%               figHandle:
%                   figure showing the positions of the cameras (and
%                   their coordinate systems) relative to the common focus
%                   point.
%                
function [camInfo,figHandle] = calcCamPos(posStruct,dispPlot)    
    %get camera aperture positions in spherical coords (relative to center
    %of sphere)
    azimuths = posStruct.positions(:,1); 
    elevations = posStruct.positions(:,2);
    radii = posStruct.positions(:,3);
    %preallocate
    numCams = size(posStruct.positions,1);
    apertures = zeros(numCams,3);
    %convert from spherical to cartesian (but still relative to sphere
    %center)
    for i = 1:numCams
        azimuth = wrapTo2Pi_custom(azimuths(i));
        elevation = wrapTo2Pi_custom(elevations(i));
        temp_radius = radii(i);      
        [x,y,z] = sph2cart(azimuth,elevation,temp_radius);
        %catch special cases in which the "UP" direction would otherwise
        %be ambiguous:
        if  elevation == 0 || elevation == 2*pi
            z = 0;    
        elseif elevation == pi/2
            z = temp_radius;
            x = 0;
            y = 0;
         elseif elevation == 3*pi/2
            z = -temp_radius;
            x = 0;
            y = 0;
        end      
       	apertures(i,:) = [x,y,z];
    end
    %prep
    tmp = zeros(size(apertures,1),3);
    UPs = tmp;
    rights = tmp;
    normals = tmp;
    upNorms = tmp;
    looks = tmp;
    %calculate camera coordinate system
    for i = 1:size(apertures,1)
        currAperture = apertures(i,:);
        if currAperture(3) == 0
            UP = [0,0,1];
        elseif currAperture(1) == 0 && currAperture(2) == 0
            UP = [1,0,0];
        else
            elev = wrapTo2Pi_custom(elevations(i));
            h = norm(currAperture)/sin(elev);
            point2 = [0,0,h];
            UP = point2 - currAperture;
        end
        normal = currAperture./norm(currAperture);
        look = (-1)*normal;
        upNorm = UP./norm(UP);
        right = cross(look,upNorm);
        right = right./norm(right);
        UPs(i,:) = UP;
        rights(i,:) = right;
        normals(i,:) = normal;
        upNorms(i,:) = upNorm;
        looks(i,:) = look;
    end
    %translate from camera aperture positions relative to the sphere's 
    %center to positons relative to the world coordinate system origin
    center = posStruct.center;
    aperturesInWorldCoords = [apertures(:,1)+center(1),...
                        apertures(:,2)+center(2),apertures(:,3)+center(3)];
    tmpCamInfo = struct(...
                        'amount',size(posStruct.positions,1),... 
                        'apertureOnSphere',apertures,...%relative to center
                        'apertureInWorld',aperturesInWorldCoords,...
                        'viewDir',looks,...%components of cam coord system
                        'upDir',upNorms,...
                        'rightDir',rights,...
                        'center',center,... %center of cam position sphere
                        'focalLengthMetric',posStruct.focalLengthMetric,...
                        'sensorSizeMetric',posStruct.sensorSizeMetric,...
                        'positions',posStruct.positions...
                    );
    camInfo = tmpCamInfo;
    % Plot camera positions & sphere 
    figHandle = plotSetupOverview('Camera setup in world coordinates.',...
                                  tmpCamInfo,...
                                  dispPlot...
                              );
end


