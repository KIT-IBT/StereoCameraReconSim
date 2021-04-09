%% -------------------------------------------------------
%
%    triCircumCirc - Computes the a triangle's circumcirle radius and center
%
%    Ver. 1.0
%
%    Created:           Jan Kost (20.10.2020)
%    Last modified:     Jan Kost (21.10.2020)
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
%  [radius,center]=triCircumCirc(coords)
% 
%        input: 
%               coords: 2x3 or 3x2 matrix containing coordinates of the
%                       triangle's vertices in 2D (image space)
%
%        output: 
%               radius: radius of the circumcircle 
%
%               center: center of the circumcircle
%


function [radius,center]=triCircumCirc(coords)
    %transpose points if necessary
    coordDim = size(coords);
    if  all(coordDim == [3,2])
        coords = coords';
    end
    %catch sliver triangles that make no sense
    area = polyarea(coords(1,:),coords(2,:));
    if (area<globalEpsilon)  
        error('Degenerate triangle:',...
                                ' The three points are almost collinear.');
    end
    %compute the length of sides (AB, BC and CA) of the triangle
    c=norm(coords(:,1)-coords(:,2));
    a=norm(coords(:,2)-coords(:,3));
    b=norm(coords(:,1)-coords(:,3));
    %use formula: R=abc/(4*area) to compute the circum radius
    radius=a*b*c/(4*area);
    %compute the barycentric coordinates of the circum center
    bary=[a^2*(-a^2+b^2+c^2),b^2*(a^2-b^2+c^2),c^2*(a^2+b^2-c^2)];
    %convert to regular coordinates
    tmpCn=bary(1)*coords(:,1)+bary(2)*coords(:,2)+bary(3)*coords(:,3);
    center=(tmpCn/sum(bary))';
end

