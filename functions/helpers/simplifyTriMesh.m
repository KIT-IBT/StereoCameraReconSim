%% -------------------------------------------------------
%
%   simplifyTriMesh - Removes duplicate vertices from a given mesh in
%                     face-vertex representation
%
%    Ver. 1.0
%
%    Created:           Jan Kost (20.10.2020)
%    Last modified:     Jan Kost (20.10.2020)
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
%  [updatedFaces,uniqueVertices] = simplifyTriMesh(faces,vertices)
% 
%        input: 
%               faces: list of faces (Nx3, rows = vertex IDs)
%
%               vertices: list of vertices (Mx3, rows = cart. coordinates) 
%
%        output: 
%               updatedFaces: list of faces with updated vertex IDs
%
%               uniqueVertices: list of vertices without duplicates
%


function [updatedFaces,uniqueVertices] = simplifyTriMesh(faces,vertices)
    %remove duplicate vertices from the vertex list
    [uniqueVertices,~,mapOldToNew] = unique(vertices,'rows','stable');
    %update the vertex IDs in the faces (connectivity lists) to match the 
    %new vertex list (think of the vetrtex IDs as addresses. THis replaces 
    %the now invalid addresses with new, valid, ones)
    %Read the documentation for UNIQUE() for how this works, it's really
    %neat.
    updatedFaces = mapOldToNew(faces);
end

