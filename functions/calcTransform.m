    
%% -------------------------------------------------------
%
%    calcTransform  - Calculates the extrinsic and projection
%    matrices for each of the cameras
%    using the camera positions, the common focus point, and the
%    common intrinsic matrix specified by the user.
%
%    Ver. 1.0
%
%    Created:           Jan Kost (15.09.2017)
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
%  result = calcTransform(camParams,dispPlot) 
%
%        camParams: Camera intrinisc parameters and poses
%
%        dispPlot:  toggles figure visibiity
%
%        result:    Final structcontaining all camera matrices as well as 
%                   all the pose information needed on in the pipeline. 
%
function result = calcTransform(camParams,dispPlot) 
    %translate camera poses, calculate coordinate systems etc.
    %also generate a plot showing the camera positions and the individual
    %camera coordinate system axes
    [camInfo,camPosPlot] = calcCamPos(camParams,dispPlot);
    
    %calculate camera matrices 
    ints = camParams.intMatrix;
    exts = calcExtMtcs(camInfo.apertureInWorld,...
                       camInfo.viewDir,...
                       camInfo.upDir,...
                       camInfo.rightDir...
                    );

    %done
    camInfo.projMatrices = calcProjMtcs(ints,exts);
    camInfo.intMatrix = ints;
    camInfo.extMatrices = exts;
    camInfo.coordinateSystemsPlot = camPosPlot;
    result = camInfo;
end