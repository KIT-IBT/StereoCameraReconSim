%% -------------------------------------------------------
%
%    constructFullPrimalPlueckerCoordMatrix  - populates a primal pluecker
%    coordinate matrix used for the calculation of intersection points in
%    homogenous space. Such a matrix is merely a different representation 
%    of the pluecker coordinates of a line.
%
%    Ver. 1.0
%
%    Created:           Jan Kost
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
%    matrix = constructFullPrimalPlueckerCoordMatrix(plueckerLine)
%
%    For more info on what this Matrix is, the notation used here etc, see:
%    https://en.wikipedia.org/wiki/Pl%C3%BCcker_coordinates#Primal_coordinates
%
%        input: plueckerLine - 1x6 pluecker coordinates of a line of 
%                              interest
%
%        output: fullMatrix - 4x4 matrix: primal matrix representation of 
%                             the same line
%
%%

function matrix = constructFullPrimalPlueckerCoordMatrix(plueckerLine)
    % readability exercise, could be kept more consise. 
    p_01 = plueckerLine(1);
        p_10 = -p_01;
    p_02 = plueckerLine(2);
        p_20 = -p_02;
    p_03 = plueckerLine(3);
        p_30 = -p_03;
    p_23 = plueckerLine(4);
        p_32 = -p_23;
    p_31 = plueckerLine(5);
        p_13 = -p_31;
    p_12 = plueckerLine(6);
        p_21 = -p_12;
    p_00 = 0;
    p_11 = 0;
    p_22 = 0;
    p_33 = 0;
    matrix = [p_00,p_01,p_02,p_03;...
                  p_10,p_11,p_12,p_13;...
                  p_20,p_21,p_22,p_23;...
                  p_30,p_31,p_32,p_33];
end