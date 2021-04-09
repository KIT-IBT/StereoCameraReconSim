    %% -------------------------------------------------------
%
%    projectToImageCoords - Projects a set of 3D points from world space to
%                           image space.
%
%    Ver. 1.0
%
%    Created:           Jan Kost (21.20.2020)
%    Last modified:     Jan Kost (21.20.2020)
%
%    Institute of Biomedical Engineering
%    Karlsruhe Institute of Technology
%
%    http://www.ibt.kit.edu
%
%    Copyright 2018 - All rights reserved.
%
% ------------------------------------------------------
%
%    [projPoints,imgX,imgY] = projectToImageCoords(points,projectionMatrix)
% 
%        input: 
%               points:  Nx3 matrix of 3D world points (each row contains
%                        cartesian coordinates of one point)
%
%               projectionMatrix:  Current camera's 3x4 projection matrix                     
%
%        output: 
%
%               projPoints: Nx2 matrix of 2D image points 
%                           (each row contains the cartesian image 
%                           coordinates of one point)                   
%
%               imgX: Nx1 vector containing the x-coordinates of the image
%                     points, purely for convenience.
%
%               imgY: Nx1 vector containing the y-coordinates of the image
%                     points, purely for convenience. 
%
%%
function [projPoints,imgX,imgY] = projectToImageCoords(points,projectionMatrix)
    numberOfPoints = size(points,1);
    picCoords = zeros(numberOfPoints,2);
    homogenousPoints = [points,ones(numberOfPoints,1)];
    for i = 1:numberOfPoints
        projected = (projectionMatrix*homogenousPoints(i,:)')';
        picCoords(i,:) = ([projected(1,1)/projected(1,3),projected(1,2)/projected(1,3)]);
    end
    imgX = picCoords(:,1);
    imgY = picCoords(:,2);
    projPoints = picCoords;
end