
%% -------------------------------------------------------
%
%    mergeOccluders - Merges the original (non-clipped) polygons of all
%                     faces listed by ID in "occluderIDs".
%                     Uses the existing 2D polyshapes from the individual
%                     face structs in camView.
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
%   [mergedOccluder,nullPolygon] = mergeOccluders(occluderIDs,camView)
% 
%        input: 
%               occluderIDs: Face IDs of the known occluders of a subject 
%                            face
%               
%               camView:     struct containing data ofr each face that is 
%                            potentially visible to the current camera. 
%
%        output: 
%               mergedOccluder: resulting 2D polyshape of the merged 
%                               occluder polygon clipping a face against
%                               this polygon is equivalent to clipping the
%                               subject face against each of the potential 
%                               occluder faces individually
%
%               nullPolygon: true if degenerate polyshapes were encountered
%                            -> denotes error case!
%

function [mergedOccluder,nullPolygon] = mergeOccluders(occluderIDs,camView)
    nullPolygon = false;
    N = size(occluderIDs,1);
    polyVec = [];
    %grab polyshapes from each relevant face struct & concatenate in
    %polyshape vector
    for i = 1:N
        currOccluder = camView.(['face_',num2str(occluderIDs(i))]);
        currPolyShape = currOccluder.originalPoly.polyShape;
        polyVec = [polyVec,currPolyShape];
    end
    if isempty(polyVec)
        %broken occluder polygons -> mergeOccluder is only called if known
        %occluders exist. An empty polyshape here means that some of the
        %original face polyshapes are somehow degenerate.
        mergedOccluder = polyshape();
        nullPolygon = true;
        %break here, nothing else to do.
        return;
    end
    %merge all occluder polyshapes in vector
    mergedPoly = union(polyVec);
    %clean up list of vertices in the merged polyshape object. Some
    %vertices shared by two occluders are treated as different (hence 
    %preventing the merger) because of minute value differences due to
    %floating-point-imprecision
    currVtcs = mergedPoly.Vertices;
    for j = 1:size(currVtcs,1)
        currVtx = currVtcs(j,:);
        temp = currVtcs - currVtx;
        %find other vertices that are essentially the same as the current
        %vtx
        tempInd = le(abs(temp),globalEpsilon);
        ind = tempInd(:,1) & tempInd(:,2);
        %paste currVtx values. this eliminates the tiny differences caused 
        %by floating-point-precision which confuse "union" and lead to 
        %falsely separated regions
        n = numel(find(ind));
        paste = repmat(currVtx,n,1);
        currVtcs(ind,:) = paste;
    end
    %write cleaned-up vertex list back into polyshape object
    %NOTE: this has undocumented behavior. Regions are automatically merged
    %upon the assigment & the vertex list is cleaned up automatically.
    %This must have been implemented in the "polyshape" class. No need to
    %call "simplify"!
    mergedPoly.Vertices = currVtcs;
    mergedOccluder = mergedPoly;
end

