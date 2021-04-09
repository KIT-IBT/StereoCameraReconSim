%% -------------------------------------------------------
%
%    getCamParams - translates user input from "camSetup.m" into camera 
%                   parameters and a camera pose description for use in 
%                   the simulation
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
% paramStruct = getCamParams
% 
%        paramStruct: struct containing the calcualted camera parameters
%                     and poses
%
%        camNum: Number of cameras (this is specified in "camSetup.m" &
%                hence might seem to be missing here.)

function [paramStruct,camNum] = getCamParams
    %load user settings script
    camSetup;
    
    % collect user setting from camSetup and calculate intrinsic camera 
    %parameters
        %sensor dimensions in mm'
        sensorSizeMetric = [L_x,L_y]';
        %sensor dimensions in pixels
        sensorSizePx = [N_x,N_y]';
        %translate focal lengths from mm into pixels using the sphere radius 
        %r (= focal lenth in mm)
        c_x = N_x/L_x;
        c_y = N_y/L_y;
        f_x = r*c_x;
        f_y = r*c_y; %The sensor skew
        convFactors = [c_x,c_y]';
        %principal point offset in pixels
        principalPointOffset = [o_x,o_y]';
        intMatrix = [-f_x,0,o_x,0; 0,-f_y,o_y,0; 0,0,1,0];
        
    %return 
    paramStruct = struct(...   
                            'center',center,...
                            'positions',positions,...
                            'angle_increment',angle_increment,...
                            'intMatrix',intMatrix,...
                            'focalLengthMetric',r,...
                            'sensorSizeMetric',sensorSizeMetric,...
                            'sensorSizePx',sensorSizePx,...
                            'convFactors',convFactors,...
                            'principalPointOffset',principalPointOffset...
                    );
end