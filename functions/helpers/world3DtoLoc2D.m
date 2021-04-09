%% -------------------------------------------------------
%
%    world3DtoLoc2D - Transforms a set of coplanar 3D points
%                     into a local 2d coordinate system. The
%                     result makes no sense if the points are 
%                     not coplanar.
%                     For the principle see: 
%                     https://stackoverflow.com/questions/26369618/getting-local-2d-coordinates-of-vertices-of-a-planar-polygon-in-3d-space
%
%    Ver. 1.0
%
%    Created:           Jan Kost (20.10.2020)
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
%  [points2D] = world3DtoLoc2D(points3D,coordVectors)
% 
%        input: 
%               points3D: Nx3 matrix, each row contains the
%                         cartesian coordinates of one point
%               
%               coordVectors: 3x3 matrix describing the local 2D coordinate
%                             system as calculated by 
%                             genWorld3DtoLoc2DTransform(). 
%                             Run that Function on the desired point set 
%                             (points3D) in order to generate the 
%                             appropriate 2D coordinate system.
%                             The rows are the origin and 
%                             coordinate axis vecors of the local 2D 
%                             coordinate system in the order: 
%                             origin, x-axis, y-axis 
%
%        output: 
%               points2D: Nx2 matrix, the rows are the local 2D 
%                         coordinates of the input points. (If the input
%                         points were not coplanar these coordinates can 
%                         be considered gibberish.)
%

function [points2D] = world3DtoLoc2D(points3D,coordVectors)
    %prep
    v0 = coordVectors(1,:);
    vx = coordVectors(2,:);
    vy = coordVectors(3,:);
    %Transform points
    tmpPoints = points3D-v0;
    points2D = [sum(tmpPoints'.*vx')',sum(tmpPoints'.*vy')'];
end