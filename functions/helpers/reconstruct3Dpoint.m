%% -------------------------------------------------------
%
%    reconstruct3Dpoint - Projects a 2D image point back into 3D world 
%                         space. Requires knowledge of the plane the point 
%                         used to be on before projection into image space.
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
% [point3Dcoords,exists] = reconstruct3Dpoint(ptImageCoords,projMatrix,...
%                                                       faceVtx,faceNormal)
% 
%        
% 
%        input: 
%           ptImageCoords: the point of interest in image coordinates
%
%           projMatrix:    the camera's projection matrix
%
%           faceVtx:       one of the original faces's vertices 
%
%           faceNormal:    the original faces's normal
%
%        output:
%
%           point3Dcoords: the point of interest in 3D world coordinates
%                          (NaN if the point does not exist)
%
%           exists:        bool, false if ray & plane do not intersect
%               
%%
function [point3Dcoords,exists] = reconstruct3Dpoint(ptImageCoords,...
                                             projMatrix,faceVtx,faceNormal)
% method: intersection point of a ray (point back-projected from image 
% space) with the plane in which the points face of origin lies. Note that 
%the point has to be known to lie on this face. The results will make no 
%sense otherwise.
                              
%Calculate the homogenous world coordinates of the image point 
%(i.e. a line in plücker coordinates)
plueckerWorldRay = imgPt2WorldRay(ptImageCoords,projMatrix);

%Find the only valid candinate for the point on the backprojected ray
[point3Dcoords,exists] = calcIntersectionPluecker(plueckerWorldRay,...
                                                  faceVtx,...
                                                  faceNormal...
                                            );
end