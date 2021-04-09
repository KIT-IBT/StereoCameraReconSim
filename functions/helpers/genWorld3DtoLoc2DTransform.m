%% -------------------------------------------------------
%
%    genWorld3DtoLoc2DTransform - calculates a local 2D coordinate system
%                                 for a set of coplanar 3D points. The 
%                                 result makes no sense if the points are 
%                                 not coplanar. At least 3 such points are
%                                 required. They must also not be colinear.
%                                 For the principle see: 
%                                 https://stackoverflow.com/questions/26369618/getting-local-2d-coordinates-of-vertices-of-a-planar-polygon-in-3d-space
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
%  coordVectors = genWorld3DtoLoc2DTransform(points3D)
% 
%        input: 
%               points3D: Nx3 matrix (at least 3x3), each row contains the
%                         cartesian coordinates of one point
%
%        output: 
%               coordVectors: 3x3 matrix, the rows are the origin and 
%                             coordinate axis vecors of the local 2D 
%                             coordinate system in the order: 
%                             origin, x-axis, y-axis 
%


function coordVectors = genWorld3DtoLoc2DTransform(points3D)

    p0 = points3D(1,:);
    p1 = points3D(2,:);
    p2 = points3D(3,:);
    %calculate local 2D coordinate system
    v0 = p0; %local origin
    vx = p1 - p0;
    n = cross(vx,(p2-p0));
    vy = cross(n,vx);
    %normalize x & y coord vectors
    vx = vx/norm(vx);
    vy = vy/norm(vy);
    
    coordVectors = [v0;vx;vy];
end