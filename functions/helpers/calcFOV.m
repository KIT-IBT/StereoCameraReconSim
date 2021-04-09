%% -------------------------------------------------------
%
%    calcFOV - Calculates the FOV boundary box both in the focal plane in 
%              world coordinates and in image space. This is done for each
%              camera.
%
%    Ver. 1.0
%
%    Created:           Jan Kost (02.04.2018)
%    Last modified:     Jan Kost (20.10.2020)
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
%  [points,image_points,polyshapes] = calcFOV(camParams)
% 
%        input: 
%               camParams:  Output struct of the function "calcTransform"
%
%        output: 
%               points: 4x3xN matrix - where N is the number of cameras. 
%                       The rows of each of the n individual 4x3
%                       matrices correspond to the cartesian world 
%                       coordintaes of the corner points of the
%                       projection of the respective camera's sensor into 
%                       the focal plane 
%
%               image_points: 4x2xN matrix, where n is the number
%                             of cameras. The rows of each of the n 
%                             individual 4x2 matrices correspond to the 
%                             image coordinates of the FOV corners.
%
%               polyshapes:  1xN polyshape vector containing the polyshape
%                            objects representing the FOV boundary box in
%                            image space

function [points,imagePoints,polyshapes] = calcFOV(camParams)
    camNum = camParams.amount;
    apertures = camParams.apertureInWorld;
    %calculate FOV box corner points (in botch world and image)
    
    points = zeros(4,3,camNum);
    imagePoints = zeros(4,2,camNum);
    for i = 1:camNum
        aperture = apertures(i,:);
        projMatrix = camParams.projMatrices(:,:,i);
        lookDir =  camParams.viewDir(i,:);
        right = camParams.rightDir(i,:);
        up = camParams.upDir(i,:);
        sensorSz = camParams.sensorSizeMetric;
        centerPoint = aperture + camParams.focalLengthMetric * lookDir;
        delta_x = right * (sensorSz(1,1)/2);
        delta_y = up * (sensorSz(2,1)/2);

        pHiLeft = centerPoint - delta_x + delta_y;
        pLoLeft = centerPoint - delta_x - delta_y;
        pLoRight = centerPoint + delta_x - delta_y;
        pHiRight = centerPoint + delta_x + delta_y;
        
        corners = [pHiLeft;pLoLeft;pLoRight;pHiRight];
        points(:,:,i) = corners;
        imagePoints(:,:,i) = projectToImageCoords(corners,projMatrix);
    end
    
    %generate polyshape objects (only for the 2D image points)
    temp = [];
    for i = 1:size(imagePoints,3)
        coords = imagePoints(:,:,i);
        temp = [temp,polyshape(coords(:,1),coords(:,2))];
    end
    polyshapes = temp;
end