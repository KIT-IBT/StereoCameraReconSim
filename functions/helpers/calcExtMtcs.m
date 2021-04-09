%% -------------------------------------------------------
%
%    calcExtMtcs  - calculates world coordinate to camera coordinate 
%                 transformation matrices (i.e. the extrinsic matrices) for
%                 a given set of cameras. 
%
%    Ver. 1.0
%
%    Created:           Jan Kost (18.10.2020)
%    Last modified:     Jan Kost (18.10.2020)
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
%  matrices = calcExtMtcs(apertures,looks,ups,rights)  
%
%        matrices: 4x4xN matrix each 4x4 matrix therein is the extrinsic 
%                  matrix of one of the N cameras
%
%        apertures: Nx3 matrix. each row contains the cartesian coordinates
%                   of the corresponding camera's aperture.
%
%        looks:     Nx3 matrix. each row contains the "look" axis vector
%                   for the corresponding camera's coordinate system.
%
%        ups:       Nx3 matrix. each row contains the "up" axis vector
%                   for the corresponding camera's coordinate system.
%
%        rights:    Nx3 matrix. each row contains the "right" axis vector
%                   for the corresponding camera's coordinate system.
%
%%  Uses the openGL "look-at" parametrization approach and variable names 
%  as described here: 
%  http://ksimek.github.io/2012/08/22/extrinsic/
function matrices = calcExtMtcs(apertures,looks,ups,rights)     
    c = apertures;
    camNum = size(c,1);
    L = looks;
    L_1 = -1*L;
    u = ups; % u is already normalized and orthogonal to the 
                    %other vectors, the last cross product u' in some
                    %publications is thus not nescessary
    s = rights;
    lookatMatrices = zeros(4,4,camNum);
    for i = 1:camNum
        R = [s(i,:);u(i,:);L_1(i,:)];
        t = -R*c(i,:)';
        
        lookatMatrices(:,:,i) = [R(1,:),t(1);
                                R(2,:),t(2);
                                R(3,:),t(3);
                                0,0,0,1];
    end
    matrices = lookatMatrices;
end