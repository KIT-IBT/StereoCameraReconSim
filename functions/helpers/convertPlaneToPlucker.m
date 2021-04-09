%% -------------------------------------------------------
%
%    convertPlaneToPlucker - Returns the pluecker representation of a plane
%                            previously defined by a normal and a point.
%
%    Ver. 1.0
%
%    Created:           Jan Kost (02.06.2018)
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
%       pluckerPlane = convertPlaneToPlucker(pointInPlane,normal)
% 
%        input: 
%               pointInPlane:   A Point in the plane, given in cartesian
%                               coordinates (1x3 vector)
%               normal:         The Normal vector to the plane, also in
%                               cartesian representation. (1x3 vector)
%
%        output: 
%               pluckerPlane:   Pluecker representation of the plane
%                               (E = [E_0,E_1,E_2,E_3]'). 
%    See: 
%    

function pluckerPlane = convertPlaneToPlucker(pointInPlane,normal)
    E_0 = normal(1);
    E_1 = normal(2);
    E_2 = normal(3);
    E_3 = -(pointInPlane(1)*E_0+pointInPlane(2)*E_1+pointInPlane(3)*E_2);
    pluckerPlane = [E_0,E_1,E_2,E_3]';
end
