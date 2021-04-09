%% -------------------------------------------------------
%
%    imgPt2WorldRay  - calculates the back projection of an image point into
%                    the world, returning the resulting line in pluecker 
%                    coorinates
%
%    Ver. 1.0
%
%    Created:           Jan Kost (11.12.2018)
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
%     [plueckerWorldRays] = imgPt2WorldRay(imgPoints,P)
% 
%        input: 
%               imgPoints - nx2 matrix, each row is a point in image 
%                           coordinate which is to be back-projected
%
%               P -         3x4 Projection Matrix of the camera 
%                           in question.        
%
%        output: 
%               plueckerWorldRays - nx6 Matrix where each row is a line 
%                                   in pluecker coordinates representing 
%               the n back-projected image points. These rays can be used 
%               to calculate the image point's 3D counterpart e.g. if the
%               3D point is known to lie within a certain plane
%
%%
function [plueckerWorldRays] = imgPt2WorldRay(imgPoints,P)
    %The method used for the calculation of the parametrized 3D world
    %coordinate points from a given image point and known prejection matrix
    %was taken from Hartley & Zisserman: 
    %"Multiple View Geometry in Computer Vision" (2nd editon), p. 161f
    %The notation used in the book has been used here where possible.
    %See stackexchange thread for further discussion: 
    %https://math.stackexchange.com/questions/2237994/back-projecting-pixel-to-3d-rays-in-world-coordinates-using-pseudoinverse-method

    %preparations
    numberOfPoints = size(imgPoints,1);
    tempPlueckerWorldRays = zeros(numberOfPoints,6);
    %decompose the projection matrix
    M = P(:,1:3);
    p_4 = P(:,4)';
    %choose values for the projection parameter mu to calculate two 
    %different explicit points on the ray
    mu_1 = 1;
    mu_2 = 2;
    for i = 1:numberOfPoints
        %append 1 to the current image point -> homogenous coordinates
        curr_x = [imgPoints(i,:),1];
        %calculate two points on the line and, from that, the pluecker line
        %representing the back-projected image point
        X_1 = [M\(mu_1*curr_x - p_4)';1];
        X_2 = [M\(mu_2*curr_x - p_4)';1];
        tempPlueckerWorldRays(i,:) = convertToPlucker(X_1,X_2);
    end
    plueckerWorldRays = tempPlueckerWorldRays;
end