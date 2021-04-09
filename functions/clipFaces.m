%% -------------------------------------------------------
%
%    clipFaces - Clips the potentially visible faces in each camera's view 
%                against the individual camera's FOV and against other 
%                occluding faces returns the camera views with faces either
%                marked fully visible, fully occluded, or partially 
%                occluded. In the latter case, the visible rest of the 
%                faces in question is included in the returned struct.
%                
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
%  clippedCameraViews = clipFaces(camViews,fovData,camData)
% 
%        input: 
%               camViews: struct containing the face data of all faces that
%                         are potentially visible to each individual camera
%
%				fovPolyShapes: FOV rectangle polyshape objects (in image
%                              coordinates)
%
%				projMtcs: 3x4xN matrix. The 3x4 matrices are the projection
%                         matrices of the Nth camera
%
%        output: 
%               clippedCameraViews: camViews with updated face data
%


function clippedCameraViews = clipFaces(camViews,fovPolyShapes,projMtcs)
    for i = 1:camViews.amount  %for each camera
        %grab potentially visible faces (frontfaces that are at least
        %partially within the FOV)
        currView = camViews.(['cam',num2str(i)]).nonCulledFaces;
        %prep
        currProjectionMatrix = projMtcs(:,:,i);
        faces = fieldnames(currView);
        %for potentially visible faces
        for j = 1:numel(faces)
            currFace = currView.(faces{j});
            %catch special cases
            if currFace.fullyVisible %if NOT flagged for FOV clipping
                                     %AND fully visible.
                continue;            %skip clipping completely
            elseif currFace.fullyOccluded
                %faces that have previously been determined to be fully 
                %occluded can be skipped
                continue;
            elseif currFace.fovClipFlag %IF face intersects FOV border 
                
                skipAfterFOV = currFace.fullyVisible;%AND is otherwise not
                %occluded: done after clipping to FOV, skip clipping ot
                %other faces
                currFace = clipToFov(currFace,...
                                     fovPolyShapes(i),...
                                     i,...
                                     currProjectionMatrix...    
                                 );
                %write results back into struct
                currView.(faces{j}) = currFace;
                if skipAfterFOV
                    continue;
                end
            end
            %clip face to its occluders previously listed by 
            %findOcclusionRelationships()
            occluders = currFace.knownOccluders;
            if(~isempty(occluders))
                [currFace,~] = clipToPoly(currFace,...
                                          i,...
                                          currView,...
                                          currProjectionMatrix...
                                      );
                %write results back into struct
                currView.(faces{j}) = currFace;
            end
        end
        %write results back into struct
        camViews.(['cam',num2str(i)]).nonCulledFaces = currView;
    end
    clippedCameraViews = camViews;
end




