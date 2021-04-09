%% -------------------------------------------------------
%
%    findOcclusionRelationships - Finds the faces that are visible to each
%                                 of the cameras. 
%                                 Also determines which faces might occlude
%                                 each other in an individual camera's 
%                                 view. 
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
%  [camViews,fov] = findOcclusionRelationships(camData,surfData)
% 
%        input: 
%               camData: struct, contains intrinsic & extrinisic camera 
%                        parameters. See calcTransform() for details.
%
%				surfData: struct, contains input mesh data. See 
%                         readSurface() for details.
%
%        output: 
%               camViews: 3-level Struct, each camera has its own field 
%                         containg the face data structs (see line 169 for
%                         their format) of every face that is possbily
%                         visible to the individual camera
%
%               fov: struct containing a representations of the different
%                    camera's fields of view. See calcFOV() for more 
%                    details.
%


function [camViews,fov] = findOcclusionRelationships(camData,surfData)
    meshData = surfData.originalMesh;
    [cornerPoints,cornerImagePoints,fovPolyShapes] = calcFOV(camData);
    fov = struct('cornerPoints',cornerPoints,...
                 'cornerImagePoints',cornerImagePoints,...
                 'fovPolyShapes',fovPolyShapes...
             );
    camViews = findVisible_par(camData,meshData,fovPolyShapes);
end
%% Find out which cameras can see which face. Also determin which faces
%  might be occluded by other faces
function views = findVisible_par(cams,mesh,fovPolyShapes)
    %prep/initialize
    faceLim = size(mesh.faces,1);
    faces = mesh.faces;
    vertices = mesh.vertices;
    centroids = mesh.centroids;
    normals = mesh.faceNormals;
    camNum = cams.amount;
    camViews = struct('amount',camNum);
    camViewFields = cell(1,camNum);
    emptyViewCounter = 0;
    %start
    parfor i = 1:camNum %for each camera
        imgVtcs =  mesh.imageVertices(:,:,i);
        %set up struct for relevant faces
        facesOfinterest = struct();
        
        %get position of camera aperture
        currAperture = cams.apertureInWorld(i,:);
        
        %gen FOV boundary polyshape
        fovPoly = fovPolyShapes(i);
        
        %list of potentially visible faces; size not known a priori -> not
        %preallocated (n x 3 matrix) (n <= faceLim, n is [total amount of 
        %not culled faces])
        visibleFaces = [];
        visibleFacesID = []; %(n x 1)
        visiblePolyShapes = []; %(polyshape vector)
        %Data used for filtering out nonsensical face constellations
        %(->prevents falsely hidden vertices)
        corners = []; %(3nx3)
        vtxDepths = [];%(3nx1)
        %face circumcircle parameters
        centers = []; %(nx2)
        radii = []; %(nx1)

        %loop over _all_ faces: backface culling, preparation for loop 2
        %which lists occlusion relationships
        for j = 1:faceLim
            currFace = faces(j,:);
            currFaceNormal = normals(j,:);
            currCentroid = centroids(j,:);
            currCamViewDir = currCentroid - currAperture;
            
            %grab the vertices for the current face 
            tempVertices = vertices(currFace,:);
            
            %visibility culling:
            %Disregards current face if it is invisible.
            %Consists of backface culling , i.e.:
            %    (dot(normals(j,:),currCamView) >= 0,
            % as well as checking if the face is NOT in the FOV
            
            if dot(currFaceNormal,currCamViewDir) >= -globalEpsilon
                %backface -> cull current face
                continue;
            end
            
            %create face polyshape object
            tempImgVtcs = imgVtcs(currFace,:);
            currPolyShape = polyshape(tempImgVtcs(:,1),tempImgVtcs(:,2));
            
            [hit,fullyInside,whoIsHidden] = ...
                                    occlusionStatus(currPolyShape,fovPoly);
            fovClipFlag = false;
            if ~hit
                %completely outside FOV -> cull current face
                continue;
            else
                if ~fullyInside
                    %face partially obverlaps with FOV
                    fovClipFlag = true;
                else
                    switch whoIsHidden
                        case 1 %face is fully inside FOV
                            fovClipFlag = false;
                        case 2 %a single face covers the entire FOV
                               %this is nonsense and should not occur
                            error(['Face ',num2str(j),' fills the '...
                                   'entire FOV of camera ',num2str(i),...
                                   ' check your camera setup & params.' ])
                    end
                end
            end
         
            %the follwing steps are only performed on relevant faces that
            %have "survived" culling:
            
            %calculate circumcircle in 2D
            [radius,center] = triCircumCirc(tempImgVtcs);
            
            %write face into list of potentially visible faces
            visibleFaces = [visibleFaces;currFace];
            visiblePolyShapes = [visiblePolyShapes,currPolyShape];
            visibleFacesID = [visibleFacesID;j];

            %data used for occluder sorting
            corners = [corners;tempVertices];
            centers = [centers;center];
            radii = [radii;radius];
            %distance of the corner points from the camera aperture
            vtxDepths = [vtxDepths;...
                            [norm(tempVertices(1,:)-currAperture);...
                             norm(tempVertices(2,:)-currAperture);...
                             norm(tempVertices(3,:)-currAperture)]];

            %use this as the template for ANY polygon struct. Always
            %polulate new polygons (e.g. face fragments )with each of 
            %these fields.
            originalPolygon = struct(...
                'vertexList', tempVertices, ...
                'vertexList2D', tempImgVtcs, ...
                'polyShape', currPolyShape, ...
                'normal', currFaceNormal ...
            );
            %add current face & all its data to the cam view for the 
            %current camera
            %(faces are accessible by ID throughout the pipeline: 
            %facesOfInterest.face_<id>.attribute)
            facesOfinterest.(['face_',num2str(j)]) = struct( ...
                'face_ID', j, ...
                'alreadyClipped', false, ...
                'fovClipFlag', fovClipFlag, ...
                'fullyOccluded', false, ...
                'fullyVisible', ~fovClipFlag, ...
                'noOverlapWithMergedOccluder',false,...
                'hasHoles', false, ...
                'originalFace', currFace, ...
                'originalNormal', currFaceNormal, ...
                'originalVtcs', tempVertices, ...
                'originalCentroid', currCentroid, ...
                'knownOccluders', [], ...
                'originalPoly', originalPolygon, ...
                'remainingPolyShape', currPolyShape, ...
                'remainingPolyWasDegenerate',false,...
                'remainingPolyFragments2D', struct(), ...
                'remainingPolyFragments3D', struct(), ...
                'circumcircle',struct('center',center,'radius',radius) ...
            );
        end %done culling & initializing current camera view
        
        if isempty(visibleFacesID) %camera sees nothing at all
            %take note of this for later
            emptyViewCounter = emptyViewCounter + 1;
        end
        
        %prep/init
        v_faceLim = size(visibleFaces,1);
        growingOccluderList = [];
        fullyOccludedList = [];
        hasHoleList = [];
        
        %check for mutual occlusion between faces in the current camera's
        %view
        for k = 1:v_faceLim %for each visible face
            %find faces whose circumcircles overlap with the current face's
            %cricumcircle
            centerShift = centers - centers(k,:);
            centerDist = vecnorm(centerShift,2,2);
            sumRadii = radii + radii(k);
            cicumCircDist = centerDist - sumRadii;
            overlapInd = cicumCircDist <= globalEpsilon; %i.e. <= 0
            %indices (w.r.t visibleFaces) of faces with overlapping circles
            %these are the only potential occluders
            locFOI = find(overlapInd);          
            %remove self (face k)-> not doing this would lead to every face
            %"hiding" itself
            locFOI(locFOI == k) = [];
            %gather stuff
            lowLim_k = (k-1)*3+1;
            upLim_k = k*3;
            vtxDepths_k = vtxDepths(lowLim_k:upLim_k,1);
            k_ID = visibleFacesID(k);
            face_k = visiblePolyShapes(k);
            for o = 1:numel(locFOI)%iterate through potential occluders
                %get index w.r.t visibleFaces
                l = locFOI(o);
                %grab face data using index
                l_ID = visibleFacesID(l);
                face_l = visiblePolyShapes(l);
                %check whether (& how) faces k & l overlap
                [occlusion,fullyInside,whoIsHidden] = ...
                                            occlusionStatus(face_k,face_l);
                %list occlusion relationship if applicable
                if occlusion
                    lowLim_l = (l-1)*3+1;
                    upLim_l = l*3;
                    vtxDepths_l = vtxDepths(lowLim_l:upLim_l,1);
                    minDepth_k = min(vtxDepths_k);
                    minDepth_l = min(vtxDepths_l);
                    if  (minDepth_l > minDepth_k)%K occludes L
                        if fullyInside
                            switch whoIsHidden
                                case 1 %K
                                    % L is deeper & K is inside L in 2D =>
                                    % K cuts a hole in L
                                    growingOccluderList = ...
                                        [growingOccluderList;[l_ID,k_ID]];
                                case 2 %L
                                    % L is deeper & L is inside K in 2D =>
                                    % K fully occludes L
                                    fullyOccludedList = ...
                                        [fullyOccludedList;l_ID];
                            end
                            continue;
                        else
                            growingOccluderList = [growingOccluderList; ...
                                                              [l_ID,k_ID]];
                            continue;
                        end
                    else%L occludes K
                        if fullyInside
                            switch whoIsHidden
                                case 1 %K
                                    % K is deeper & K is inside L in 2D =>
                                    % L fully occludes K
                                    fullyOccludedList = ...
                                        [fullyOccludedList;k_ID];
                                case 2 %L
                                    % K is deeper & L is inside L in 2D =>
                                    % L cuts a hole in K
                                    growingOccluderList = ...
                                        [growingOccluderList;[k_ID,l_ID]];
                            end
                            continue; 
                        else
                            growingOccluderList = [growingOccluderList; ...
                                                              [k_ID,l_ID]];
                            continue;
                        end
                    end
                end
            end % faces l
        end % faces k

        %clean up occluder lists (remove duplicates & sort
        %by occluded face ID in ascending order)
        finalOccluderList = unique(growingOccluderList,'rows','sorted');
        finalFullyOccludedList = unique(fullyOccludedList,'rows','sorted');
        %save to return struct
        currCamView = struct(...
            'aperture',currAperture,...
            'nonCulledFaceIDs',visibleFacesID,... 
            'nonCulledFaces',facesOfinterest,...
            'DEBUG_facesThatMightHaveHoles',hasHoleList...
            );
        
        %mark fully occluded faces here already to avoid unduly clipping
        %them later in the pipline
        for m = 1:size(finalFullyOccludedList,1)
            currID = finalFullyOccludedList(m);
            currCamView.nonCulledFaces. ...
                (['face_',num2str(currID)]).fullyOccluded = true;
            currCamView.nonCulledFaces. ...
                (['face_',num2str(currID)]).fovClipFlag = false;
            currCamView.nonCulledFaces. ...
                (['face_',num2str(currID)]).fullyVisible = false;
        end
        
        %terate through the occluder list block by block of subject face 
        %IDs
        if (~isempty(finalOccluderList))
            n = 1;
            while n <= size(finalOccluderList,1)
                %get the next subject face ID and find all occurences
                %(these are consecutive due to the previous sorting of
                %each occluderlist)
                currID = finalOccluderList(n,1);
                indices = find(finalOccluderList(:,1) == currID);
                %get the occluder IDs (in column two of the rows whose IDs 
                %were returned by "find")
                currentOccluders = finalOccluderList(indices,2);
                currCamView.nonCulledFaces. ...
                    (['face_',num2str(currID)]).knownOccluders = ...
                    currentOccluders;
                %mark subject as not fully visible
                currCamView.nonCulledFaces. ...
                    (['face_',num2str(currID)]).fullyVisible = ...
                    false;
                %jump down the list to where the next subject ID starts
                n = max(indices)+1;
            end
        end
        camViewFields{i} = currCamView;
    end % cams i
    nonEmptyViews = camNum - emptyViewCounter;
    if nonEmptyViews <= 1
        %i.e. if at most one camera even sees anything
        %stop the program
        error(['Too few cameras see the mesh. Mesh faces are visible ',...
               'to ',num2str(nonEmptyViews),' cameras. Check Model '...
               'Position relative to camera setup focal point.'])
    end
    for m = 1:camNum
        camViews.(['cam',num2str(m)]) = camViewFields{m};
    end
    views = camViews;
end