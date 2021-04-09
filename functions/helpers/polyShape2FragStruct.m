%% -------------------------------------------------------
%
%    polyShape2FragStruct - Extracts the regions of a polyshape object &
%                           writes their vertices into numbered fields of 
%                           a struct 
%
%    Ver. 1.0
%
%    Created:           Jan Kost (21.10.2020)
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
%  polygons2D = polyShape2FragStruct(polyShape)
% 
%        input: 
%               polyShape: polyshape object. Ususally contains clipped 
%                          remains of a mesh face in the context of the 
%                          reconstructability sim.
%
%        output: 
%               polyRegions2D: output struct containing numbered polyshape 
%                              region vertex lists (named poly1, poly2, 
%                              etc.). Vtx lists are Nx2 matrices.
%


function polyRegions2D = polyShape2FragStruct(polyShape)
    temp = struct();
    %extracts regions from polyshape object
    regionVec = regions(polyShape);
    %loop over these regions, reformat them and make consistently oriented,
    %then write into ouptput struct
    for i = 1:size(regionVec)
        currPolyObj = regionVec(i);
        tempVertices = currPolyObj.Vertices;
        
        %force clockwise orientation
        
        [tempX, tempY] = poly2cw_custom(tempVertices(:,1), tempVertices(:,2));
        
        polyVertices = [tempX, tempY];
        localBoundaryLoop = 1:1:size(polyVertices,1);
        temp.(['poly',num2str(i)]) = polyVertices;
    end
    polyRegions2D = temp;
end

