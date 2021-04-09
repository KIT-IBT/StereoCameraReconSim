%% -------------------------------------------------------
%
%    clipToPoly - Clips a given mesh face against the all potential
%                 occluding faces in the current camera's view. Keeps the
%                 parts of the face that are not inside any of the
%                 occluders.
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
%[clippedFace,nothingLeft] = clipToPoly(face,camNo,camView,projMatrix)
%
%        input: 
%               face: struct containing all the data regarding the current
%                     subject face
%
%				camView: struct containing the face structs for all faces
%                        visible to the current camera
%
%				camNo: identifying number of the current camera
%
%				projMatrix: 3x4 projection matrix of the current camera
%
%        output: 
%               clippedFace: original face struct, expanded by fields
%                            containing representations of the clipping
%                            remains in 2D & 3D (if applicable)  
%                            Flags are set to mark whether the face was
%                            clipped, is fully hidden, and whether the
%                            clipping remains might be corrupted
%
%               nothingLeft: original face struct, expanded by fields
%                           containing representations of the clipping
%                           remains in 2D & 3D
%

function [clippedFace,nothingLeft] = clipToPoly(face,camNo,camView,...
                                                      projMatrix)
    %prepare & initialize, merge all occluders into one polyshape object
    occluders = face.knownOccluders;
    nothingLeft = false;
    nullOccluders = false;
    if ~isempty(occluders)
        [mergedOccluder,nullOccluders] = mergeOccluders(occluders,camView);
    else
        error('clipToPoly_25D: unexpected empty occluder list')
    end
    if nullOccluders
        error(['Encountered sliver occluders, treated as null by ',...
               'polyshape, in cam: ',num2str(camNo),', face: ',...
                    num2str(face.face_ID)])
    end
    %% Do the actual clipping
    currRestPoly = face.remainingPolyShape;
    clippingResult = subtract(currRestPoly,mergedOccluder);
    if ~issimplified(clippingResult)
        %clippingResult might have self-intersections, duplicate vertices 
        %and improperly nested regions -> even after simplification, the
        %clipping remains of this face may not be trusted.
        
        %notify, mark the face as untrustwothy,  simplify, then proceed 
        warning(['Degenerate clipping result polygon in cam: ',...
                          num2str(camNo),', face: ',num2str(face.face_ID)])
        face.remainingPolyWasDegenerate = true;
        face.degenerateRestPolyShape = clippingResult;
        clippingResult = simplify(clippingResult);
    end
    face.remainingPolyShape = clippingResult;
    if  clippingResult.NumRegions == 0 %if nothing is left of the face
        nothingLeft = true;
        face.fullyOccluded = true;
        face.fullyVisible = false;
        face.alreadyClipped = true;
        face.remainingPolyFragments2D = struct();
        face.remainingPolyFragments3D = struct();
    else
        face.alreadyClipped = true;
        if ~overlaps(currRestPoly,mergedOccluder)
            %no occlusion detected despite likely occlusion -> mark for 
            %easier troubleshooting if necessary
            face.noOverlapWithMergedOccluder = true;
        else
            face.fullyVisible = false;
        end
        if clippingResult.NumHoles ~= 0
            %given the manifold nature of the input mesh, this should never
            %happen.
            face.hasHoles = true;
            warning(['Clipping result polygon in cam: ',...
                     num2str(camNo),', face: ',num2str(face.face_ID),...
                     ', has holes. Is your input mesh a real manifold?'])
        end
        remains3D = reconstruct3DPolygons(clippingResult,camNo,...
                                                          projMatrix,face);
        face.remainingPolyFragments2D = polyShape2FragStruct(...
                                                           clippingResult);
        face.remainingPolyFragments3D = remains3D;
    end
    clippedFace = face;
end
