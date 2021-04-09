%% -------------------------------------------------------
%
%    reconstruct3DPolygons  - restores the 3D world equivalent of a
%                             polyshape im image space. Requires the
%                             camera's projection matrix & knowledge of
%                             which original face the polyshape belongs to.
%
%    Ver. 1.0
%
%    Created:           Jan Kost (20.20.2020)
%    Last modified:     Jan Kost (21.20.2020)
%
%    Institute of Biomedical Engineering
%    Karlsruhe Institute of Technology
%
%    http://www.ibt.kit.edu
%
%    Copyright 2020 - All rights reserved.
%
% ------------------------------------------------------
%    pgons3D = reconstruct3DPolygons(polyShape,camNo,projMatrix,face)
% 
%        input: 
%               polyShape: polyshape object in image space belonging to a
%                          certain face in the input mesh
%
%               camNo: current camera's identifying number
%
%               projMatrix:  current camera's 3x4 projection matrix
%
%               face: face data struct for the current         
%
%        output: 
%               pgons3D: Struct containing the reconstructed 3D vertices of
%                        every regionin the input polyshape, one per field.
%                        Each field also contains a 2D polyshape and 2D 
%                        image vertices of the respective region as well
%                        as the normal of the face it belongs to.
%
%%

function pgons3D = reconstruct3DPolygons(polyShape,camNo,projMatrix,face)
    %project the 2D Polygon back into 3D -> method: intersection point of
    %the ray back-projected from each vertex in image coordinates with the 
    %original face extended to a plane
    pgons2D = polyShape2FragStruct(polyShape);
    fields = fieldnames(pgons2D);
    pgons3D = struct();
    %for each of the polyshape regions
    for p = 1:numel(fields)
        currRestPoly = pgons2D.(fields{p});
        %preallocate
        numVertices = size(currRestPoly,1);
        tempPolyVertices = zeros(numVertices,3);
        tempPolyConnectList = zeros(numVertices,2);
        %reconstruct the world coordinates of the vertices and populate the
        %connectivity list
        for q = 1:numVertices
            [curr3Dvtx,ptExists] = reconstruct3Dpoint(currRestPoly(q,:),...
                                      projMatrix,face.originalVtcs(1,:),...
                                      face.originalNormal);
            if ptExists
                tempPolyVertices(q,:) = curr3Dvtx;
            else
                error(['No valid intersection point found during back-',...
                      ' projection to 3D after clipping in ',...
                      num2str(camNo),...
                      ', face: ',num2str(face.face_ID),'.'])           
            end 
            tempPolyConnectList(q,:) = q;
        end
        %generate polyshape object for current fragment
        tempPolyShape = polyshape(currRestPoly(:,1),currRestPoly(:,2));
        %build the rest polygon object for the current fragment
        tempPoly = struct(...
            'vertexList', tempPolyVertices, ...
            'vertexList2D', currRestPoly, ...
            'polyShape', tempPolyShape, ...
            'normal', face.originalNormal ...
        );
        pgons3D.(['poly',num2str(p)]) = tempPoly;                            
    end
end

