
%% -------------------------------------------------------
%
%    calcTriArea - Finds the surface area of a triangle (e.g. a mesh face) 
%
%    Ver. 1.0
%
%    Created:           Jan Kost (02.04.2018)
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
%  area = calcTriArea(vertices)
% 
%        input: 
%               vertices:   3x3 Matrix, rows contain cartesian coordinates 
%                           of the vertices
%
%        output: 
%               area:       Surface area of the face

function area = calcTriArea(vertices)
    A = vertices(1,:);
    B = vertices(2,:);
    C = vertices(3,:);
    %set up for heron's formula------
        %side lengths
        AB = norm(A-B);
        AC = norm(A-C);
        BC = norm(B-C);
        %semiperimeter
        s = 0.5*(AB+AC+BC);
    %herons formula------------------
        area = sqrt(s*(s-AB)*(s-AC)*(s-BC));
end