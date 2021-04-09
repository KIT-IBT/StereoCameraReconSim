%% -------------------------------------------------------
%
%    sortFaceData - steps through each field (i.e. face) in a given
%                   camera view struct, extracts the relevant face data &
%                   sorts it into output structs for use by collectAndPlot
%                   and findReconstructableArea
%
%    Ver. 1.0
%
%    Created:           Jan Kost (20.10.2020)
%    Last modified:     Jan Kost (23.10.2020)
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
%  [plotData2D,plotData3D,reconStruct] = sortFaceData(faces)
% 
%        input: 
%
%               camView: Struct containing the face data structs for all
%                        faces in a given camera's view 
%                        -> pass an entire clipped camera view
%
%        output: 
%
%               plotData2D: struct, contains 2D data collected from all 
%                           faces in the input struct, specifically for use
%                           by collectAndPlot
%
%               plotData3D: struct, contains 3D data collected from all 
%                           faces in the input struct, specifically for use
%                           by collectAndPlot
%
%               reconStruct: struct, contains face data sorted in a manner
%                            convenient for use in the last step in the sim
%                            pipeline: the determination of the
%                            reconstructable subset of the input mesh
%

function [plotData2D,plotData3D,reconStruct] = sortFaceData(camView)
    
    faces = fieldnames(camView);
    %% initialize things
    notOccludedFaces = []; %polyshape vector
    nof3D = []; %regular matrix
    NoOC_IDs = []; %regular vector
    
    clippedFaces = []; %polyshape vector
    clip3D = {}; %cell array
    clipPatch_IDs = []; %regular vector
    
    originalClippedFaces = []; %regular vector
    ocf3D = []; %regular matrix
    clip_IDs = []; %regular vector
    
    FOVleakedFaces = []; %regular vector
    flf3D = []; %regular matrix
    leak_IDs = []; %regular vector
    visible_IDs = []; %regular vector
    
    originalFaceStruct = struct();
    hiddenFaceStruct = struct();
    clippedFaceStruct = struct();
    visibleFaceStruct = struct();
    
    %% sort faces
    for i = 1:numel(faces)
        currFace = camView.(faces{i});
        notOccluded = currFace.fullyVisible;
        nothingLeft = currFace.fullyOccluded;
        clippedToFov = currFace.fovClipFlag;    
        
        if notOccluded
            originalFaceStruct.(faces{i}) = currFace;
            visibleFaceStruct.(faces{i}) = currFace;
            notOccludedFaces = [notOccludedFaces,...
                                           currFace.originalPoly.polyShape];
            nof3D = cat(3,nof3D,currFace.originalPoly.vertexList);
            NoOC_IDs = [NoOC_IDs;currFace.face_ID];
            visible_IDs = [visible_IDs;currFace.face_ID];
        elseif nothingLeft %face fully occluded
            hiddenFaceStruct.(faces{i}) = currFace;
            if clippedToFov 
                %FOV leak (early problem, this should NEVER occur
                	FOVleakedFaces = [FOVleakedFaces,...
                                          currFace.originalPoly.polyShape];
                    flf3D = cat(3,flf3D,currFace.originalPoly.vertexList);
                    leak_IDs = [leak_IDs;currFace.face_ID];
            end
        else %face partially occluded
            clippedFaceStruct.(faces{i}) = currFace;
            visibleFaceStruct.(faces{i}) = currFace;
            originalClippedFaces = [originalClippedFaces,...
                                          currFace.originalPoly.polyShape];
            ocf3D = cat(3,ocf3D,currFace.originalPoly.vertexList);
            clip_IDs = [clip_IDs;currFace.face_ID];
            visible_IDs = [visible_IDs;currFace.face_ID];
            %grab remaining poly fragments
            remainingPolygons = currFace.remainingPolyFragments3D;
            locFields = fieldnames(remainingPolygons);
            for j = 1:numel(locFields)
                currFragment = remainingPolygons.(locFields{j});
                clippedFaces = [clippedFaces,currFragment.polyShape];
                clip3D = [clip3D,{currFragment.vertexList}];
                clipPatch_IDs = [clipPatch_IDs;currFace.face_ID];
            end      
        end
        
    end
    plotData2D = struct(    'notOccludedFaces',notOccludedFaces,...
                            'NoOC_IDs',NoOC_IDs,...
                            'clippingRemains',clippedFaces,...
                            'remain_IDs',clipPatch_IDs,...
                            'originalClippedfaces',originalClippedFaces,...
                            'clip_IDs',clip_IDs,...
                            'FOVleakedFaces',FOVleakedFaces,...
                            'leak_IDs',leak_IDs...
                );
            
    plotData3D = struct(    'notOccludedFaces',nof3D,...
                            'clippingRemains',{clip3D},...
                            'originalClippedfaces',ocf3D,...
                            'FOVleakedFaces',flf3D...
                );
            
    reconStruct = struct(   'visibleIDs',visible_IDs,...
                            'visibleFaces',visibleFaceStruct,...
                            'nonClippedFaces',originalFaceStruct,...
                            'nonClippedIDs',NoOC_IDs,...
                            'fullyOccludedFaces',hiddenFaceStruct,...
                            'fullyOccludedIDs',NoOC_IDs,...
                            'clippedFaces',clippedFaceStruct,...
                            'clippedIDs',unique(clip_IDs)...
                );
end