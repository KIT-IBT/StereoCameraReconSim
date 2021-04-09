%% -------------------------------------------------------
%
%    calcProjMtcs  - Calculates the projection Matrices for a set of 
%                   identical cameras at different positions using a
%                   common intrinsic matrix and the individual extrinsic 
%                   matrices 
%
%    Ver. 1.0
%
%    Created:           Jan Kost (18.10.2020)
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
%  matrices = calcProjMtcs(intr,exts)
%
%        matrices: 3x4xN matrix. Each 3x4 matrix therein is the projection
%                  matrix of one of the N cameras
%
%        intr:  3x4 commin intrinic matrix for all the cameras in the
%               simulation
%
%        exts:  4x4xN matrix. Each 4x4 matrix therein is the extrinsic
%               matrix of one of the N cameras
%
function matrices = calcProjMtcs(intr,exts)     
    camNum = size(exts,3);
    projectionMatrices = zeros(3,4,camNum);
    for i = 1:camNum
        projectionMatrices(:,:,i) = intr*exts(:,:,i);
    end
    matrices = projectionMatrices;
end