%% -------------------------------------------------------
%
%    readSurface  -  Reads a mesh from a binary .STL file. Adds a plot for 
%                    visualization and verification purposes. Also provides
%                    the face centroid points for further use.
%
%    Ver. 1.0
%
%    Created:           Jan Kost (15.09.2017)
%    Last modified:     Jan Kost (23.10.2020)
%
%    Institute of Biomedical Engineering
%    Karlsruhe Institute of Technology
%
%    http://www.ibt.kit.edu
%
%    Copyright 2020 - All rights reserved.
% ------------------------------------------------------
%
%  meshData = readSurface(file,dispPlots,showNormals,showIDs) 
% 
%        input: 
%               file: string, filename including extension (.stl)
%
%				dispPlots: bool, toggles figure visibiity
%
%				showNormals: bool, toggles displying normals in the surface
%                            plot
%
%				showIDs: bool, toggles displying face ID in the surface
%                        plot
%
%        output: 
%               meshData: struct, contains all mesh data, along with the
%                         surface plot
%                

function meshData = readSurface(file,dispPlots,showNormals,showIDs) 
    [F,V,N] = stlread(file); 
    %Clean up the mesh. Remove duplicate vertices,
    %make sure vertexIDs are unique.
    [F,V] = simplifyTriMesh(F,V);
    %generate a plot of the mesh
    [plot,C] = patchPlotFaces(F,V,'Patchplot of unedited stl File',...
                                  'green',dispPlots,showNormals,N,showIDs);
    %Calculate the area for each face in the mesh
    faceNum = size(F,1);
    areas = zeros(faceNum,1);
    totalArea = 0;
    for k = 1:faceNum
        %V(F(k,:),:) gets the actual vertex coordinates using the face IDs
        tmpArea = calcTriArea(V(F(k,:),:));
        totalArea = totalArea + tmpArea;
        areas(k) = tmpArea;
    end
    %done
    mesh = struct(    'faces',F,...
                      'centroids',C,...
                      'vertices',V,...
                      'faceNormals',N,...
                      'faceAreas',areas,...
                      'totalArea',totalArea...
                );
    meshData = struct('numFaces',size(F,1),...
                      'originalMesh',mesh,...
                      'patchPlot',plot...
              );
end