%% -------------------------------------------------------
%
%    clipToFov - Clips a given mesh face against the camera's FOV in image
%                coordinates. Keeps the part of the face that is inside
%                the FOV.
%
%    Ver. 1.0
%
%    Created:           Jan Kost (20.10.2020)
%    Last modified:     Jan Kost (23.10.2020)
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
%  returnFace = clipToFov(face,fovPoly,cam,projMatrix)
% 
%        input: 
%               face: struct containing all the data regarding the current
%                     subject face
%
%				fovPoly: polyshape object of the FOV rectangle in image
%                        coordinates
%
%				cam: identifying number of the current camera
%
%				projMatrix: 3x4 projection matrix of the current camera
%
%        output: 
%               returnFace: original face struct, expanded by fields
%                           containing representations of the clipping
%                           remains in 2D & 3D
%

function returnFace = clipToFov(face,fovPoly,cam,projMatrix)
    %% clip to the FOV
    facePoly = face.originalPoly.polyShape;
    restPoly = intersect(facePoly,fovPoly);
    %Build the 3D of the part of the face that survived clipping
    remains3D = reconstruct3DPolygons(restPoly,cam,projMatrix,face);
    %done
    face.remainingPolyShape = restPoly;
    face.remainingPolyFragments2D = polyShape2FragStruct(restPoly);
    face.remainingPolyFragments3D = remains3D;
    face.alreadyClipped = true;
    face.fullyVisible = false;
    returnFace = face;
end
