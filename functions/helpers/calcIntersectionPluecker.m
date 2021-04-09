%% -------------------------------------------------------
%
%    calcIntersectionPluecker - Finds the intersection point between a ray 
%    in pluecker coordinates and a plane in 3D; can handle nonexistent 
%    intersection points.
%
%    Ver. 1.0
%
%    Created:           Jan Kost (19.05.2019)
%    Last modified:     Jan Kost (19.10.2020)
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
%   [intersectionPoint,exists] = ...
%                      calcIntersectionPluecker(ray,planePoint,planeNormal)
%
%    alternative implementation 
%    See:
%    https://math.stackexchange.com/questions/2433207/intersection-of-standard-line-and-plane
%    https://math.stackexchange.com/questions/400268/equation-for-a-line-through-a-plane-in-homogeneous-coordinates
%    
%    see: 
%    https://en.wikipedia.org/wiki/Pl%C3%BCcker_matrix#Intersection_with_a_plane
%    for the formula used in the function
% 
%        input: 
%               ray - 1x6 pluecker ray of interest, usually the viewing ray
%                     defined by the current camera's aperture and a 
%                     vertex of interest
%
%               planePoint - 1x3 vector, a point within the plane of 
%                            interest (cartesian coords)
%
%               planeNormal - 1x3 vector, the the plane of interest's 
%                             normal vector
%
%        output:
%               intersectionPoint - 1x3 vector, intersection point in 
%                                   cartesian coordinates if it exists, 
%                                   vector of NaNs otherwise.
%
%               exists - Bool, true if intersection exists, false 
%                        otherwise. Use this for your convenience, saves 
%                        having to check for NaN in the calling function.

function [intersectionPoint,exists] = calcIntersectionPluecker(...
                                                ray,planePoint,planeNormal)
    homPlane = convertPlaneToPlucker(planePoint,planeNormal);
    primalLineCoordMatrix = constructFullPrimalPlueckerCoordMatrix(ray);
    %intersection point of a line and a plane in primal pluecker 
    %coordinates:
    %https://en.wikipedia.org/wiki/Pl%C3%BCcker_coordinates#Plane-line_meet
    homIntersectionPoint = zeros(4,1);
    for i = 1:4
        tempSum = 0;
        for j = 1:4
            if i == j 
                continue
            else
                tempSum = tempSum + homPlane(j)*primalLineCoordMatrix(i,j);
            end
        end
        homIntersectionPoint(i) = tempSum;
    end
    %conversion from projective (homogenous) to euclidean 3-space
    %catch parallel case (would be division by 0)
    if abs(homIntersectionPoint(4)) < eps(max(homIntersectionPoint))
        intersectionPoint = NaN(1,3);
        exists = false;
        return;
    end
    intersectionPoint = (homIntersectionPoint(1:3)/...
                                                homIntersectionPoint(4))';
    exists = true;
end