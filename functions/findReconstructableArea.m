%% -------------------------------------------------------
%
%    findReconstructableArea - Finds the reconstructable subset of each
%                              face in the mesh, using the clipped & sorted
%                              camera views produced by the previous 
%                              elements of the pipeline.
%                              Calculates the total reconstructable area
%                              (in square length units) 
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
%  reconstruction = findReconstructableArea(threshold,surfData,...
%                                      sortedCamViews,excludeIds,dispPlots)
% 
%        input: 
%               threshold: minimal number of cameras that must see a point
%                          for it to be considered reconstructable 
%
%				surfData: struct containing all input mesh data, along 
%                         with a mesh surface plot (output of readSurface)
%
%				sortedCamViews: camera view struct, where the individual
%                               face data substructs are sorted by
%                               visibility/occlusion status
%
%               excludeIDs: vector containing IDs of faces that should not
%                           count totwards the total reconstructable area.
%                           (they will sill show up in plots and the
%                           reconstructed STL)
%    
%               dispPlots: bool, toggles figure visibility
%
%        output: 
%               reconstruction: struct, contains:
%                                1. reconstructable area 
%                                   (value in legth units^2) 
%                                2. Reconstructable subset of the mesh as
%                                   triangulation object 
%                                3. surface plot figures
%                                4. raw data produced by this function
%                                   along the way
%


function reconstruction = findReconstructableArea(threshold,surfData,...
                                       sortedCamViews,excludeIDs,dispPlots)
    %prep/init
    numFaces = surfData.numFaces;
    cams = fieldnames(sortedCamViews);
    faceIDs = (1:numFaces)';
    visibleCtr = zeros(size(faceIDs));
    %for each face count out how many cameras see at least a portion of it
    for i = 1:numel(cams)% for each camera
        %get the indices of all faces that are visible to camera i and
        %increment the values in the visibleCounter vector at these indices 
        tempVisList = zeros(size(faceIDs));
        camVisList = sortedCamViews.(cams{i}).reconData.visibleIDs;
        tempVisList(camVisList) = camVisList;
        temp = tempVisList == faceIDs;
        visibleCtr = visibleCtr + temp;
    end
    %collect the IDs of potentially reconstructable faces (faces visible to
    %least the minimum required amount of cameras set in simSettings)
    isReconstructable = visibleCtr >= threshold;
    reconIDs = faceIDs(isReconstructable);
    
    %For each potentially reconstructable ("parent") face: find any camera
    %that sees it & extract the face data structs from these cameras. 
    %Then place in new struct, sorted by "parent" face
    reconStruct = struct();
    for j = 1:numel(cams) % for each camera
        visFaces = sortedCamViews.(cams{j}).reconData.visibleFaces;
        for k = 1:numel(reconIDs)% for each pot. reconstructable face
            %check if current cam sees the face k at all
            currID = reconIDs(k);
            currField = ['face_',num2str(currID)];
            if isfield(visFaces,currField)
                %if so, append to new struct
                currFace = visFaces.(currField);
                reconStruct.(['f',num2str(currID)]).cams.(cams{j}) = ...
                                                                  currFace;
                reconStruct.(['f',num2str(currID)]).ID = currFace.face_ID;
                if isfield(reconStruct.(['f',num2str(currID)]),'visibleTo')
                    visTo = reconStruct.(['f',num2str(currID)]).visibleTo;
                    reconStruct.(['f',num2str(currID)]).visibleTo = ...
                                                           [visTo;cams(j)];
                else
                    reconStruct.(['f',num2str(currID)]).visibleTo = ...
                                                                   cams(j);
                end
            end
        end
    end
    %prep/init
    reconFaces = fieldnames(reconStruct);
    tmpTotalArea = 0;
    recMeshConnList = [];
    recMeshVtcs = [];
    %gather all info & do the reconstruction face by face.
    for m = 1:numel(reconFaces)%for each potentially reconstructable face
        %fins reconstructable subset of the face
        currFace = reconStruct.(reconFaces{m});
        [restArea,restPoly2D,mesh3D,emptyTri,~] = ...
                                  reconstructFace(currFace.cams,threshold);
        %write results back into the struct for the reconstructable faces
        reconStruct.(reconFaces{m}).restArea = restArea;
        if ~ismember(currFace.ID,excludeIDs)
            tmpTotalArea = tmpTotalArea + restArea;
            reconStruct.(reconFaces{m}).restPoly = restPoly2D;
            reconStruct.(reconFaces{m}).rest3D = mesh3D;
            %reconStruct.(reconFaces{m}).diag = diagnostics;
            if ~emptyTri
                %append triangulation of the rest polygon in 3D to a growing
                %mesh in Face/Vertex representation -> this will be exported as
                %STL by the main script
                numPrevVtcs = size(recMeshVtcs,1);
                recMeshConnList = [recMeshConnList;...
                                        mesh3D.ConnectivityList + numPrevVtcs];
                recMeshVtcs = [recMeshVtcs;mesh3D.Points];
            end
        end
    end
    %remove duplicate vertices from the grown mesh
    [faces,Vertices] = simplifyTriMesh(recMeshConnList,recMeshVtcs);
    %create triangulation object from the simplified mesh
    if ~isempty(faces)
        outputMesh = triangulation(faces,Vertices);
        %merge recostructable surface plot into the original mesh surface
        %figure
        set(0, 'CurrentFigure', surfData.patchPlot)
        hold on
        trimesh(outputMesh,'EdgeColor','k','FaceColor','r');
        fullSurfFig = gcf;
        %and generate a separate plot of the reconstructable surface only
        recSurfFig =  figure('Name','Reconstructable Surface',...
                             'NumberTitle','off','Visible',dispPlots);
        trimesh(outputMesh,'EdgeColor','k','FaceColor','g',...
                                                          'FaceAlpha',0.3);
    else
        reconstruction = struct('nothingWasReconstructable',true);
        warning(['Nothing was reconstructable at all from the given ',...
                'mesh using the specified camera setup.'])
        return
    end
    %remove full face structs from reconStruct.face.cams & replace with a
    %simple list of camera numbers -> fix for gigantic .mat output files
    %when using large meshes or many cameras
    for n = 1:numel(reconFaces)
        reconStruct.(reconFaces{n}) = rmfield(reconStruct.(reconFaces{n}),'cams');
    end
    reconstruction = struct('reconData',reconStruct,...
                            'totalArea',tmpTotalArea,...
                            'reconSurf',outputMesh,...
                            'fullSurfFig',fullSurfFig,...
                            'recSurfFig',recSurfFig);
end


%% Calulates the reconstructable subset of a single face
%  the rec. subset is the union of the intersections of all possible 
%  combinations of N rest polygons (where N is the reconstruction 
%  threshold set in simSettings)
function [restArea,restPoly2D,mesh3D,nothingLeft,diagnostics] = ...
                                      reconstructFace(face,threshold)
    %prep/init
    nothingLeft = false;
    cams = fieldnames(face);
    fullyVisibleCounter = 0;
    skipAggregation = false;
    restPolys3D = {};
    %extract actual 3D coords of all relevant face fragments
    for i = 1:numel(cams)
        currRest = face.(cams{i});
        if currRest.fullyVisible
           restPolys3D = [restPolys3D,{currRest.originalVtcs}];
           fullyVisibleCounter = fullyVisibleCounter + 1;
           if fullyVisibleCounter >= threshold
               %the face is fully visible to as many cameras as considered
               %required for 3D reconstruction. The face is therefore fully
               %reconstructable, no determination of the reconstrucable
               %subset is required
               skipAggregation = true;
               break;
           end
        else
            tempFrags = currRest.remainingPolyFragments3D;
            tmpFields = fieldnames(tempFrags);
            for j = 1:numel(tmpFields)
                tempFrag = tempFrags.(tmpFields{j});
                restPolys3D = [restPolys3D,{tempFrag.vertexList}];
            end
        end
    end
    %cell array containing the clipping fragment polygons from each camera
    fragCell = restPolys3D;
    %prep/init
    numRestPolys = numel(restPolys3D);
    origVtcs = face.(cams{1}).originalVtcs;
    %use the face's original vertices to calculate a transformation into a 
    %local 2D coordinate system in the plane that is coplanar to the face
    locCoordSys = genWorld3DtoLoc2DTransform(origVtcs);
    if skipAggregation %exit here if the full face is known to be
                       %reconstructable
        %return the full face
        fragCell = restPolys3D;
        orig2D = world3DtoLoc2D(origVtcs,locCoordSys);
        restPoly2D = polyshape(orig2D);
        restArea = area(restPoly2D);
        diagnostics = struct('fragCell',fragCell,...
                     'fragVec',restPoly2D,...
                     'short',skipAggregation);
        mesh3D = triangulation([1,2,3],origVtcs);
        return;
    end
    %otherwise:
    %transform each rest polygon into the local 2D coordinate system
    restPolys2D = cell(size(restPolys3D));
    for k = 1:numRestPolys
        restPolys2D{k} =  world3DtoLoc2D(restPolys3D{k},locCoordSys);
    end
    %convert the transformed rest polygons to polyshapes & place them in a 
    %polyhape vector
    polyShapes = repmat(polyshape,numRestPolys,1);
    for m = 1:numRestPolys
        polyShapes(m) = polyshape(restPolys2D{m});
    end
    %% find all patches shared by at least N rest patches
    %=> i.e. the union of the intersections of all possible combinations of
    %N rest polygons (where N is the reconstruction threshold, i.e. the
    %number of individual camera imges of a point considered required for
    %reconstruction)
    
    %find all possible combinations of N cameras
    combinations = nchoosek(1:numRestPolys,threshold);
    %prep/init
    tempRest = polyshape();
    %calculate the union of intersections of these combinations
    for n = 1:size(combinations,1)
        polyA = polyShapes(combinations(n,1));
        polyB = polyShapes(combinations(n,2));
        tempRest = union(tempRest,intersect(polyA,polyB));
    end
    %this union is the reconstructable rest polyshape
    restPoly2D = tempRest;
    %% output things 
    if restPoly2D.NumRegions == 0
        %empty rest polyshape, i.e. nothing is reconstructable
        mesh3D = [];
        restArea = 0;
        nothingLeft = true;
    else
        %Create a triangulation of the reconstructable rest of the face 
        %in 3d
        tri2D = triangulation(tempRest);
        vtcs3D = loc2DtoWorld3D(tri2D.Points,locCoordSys);
        mesh3D = triangulation(tri2D.ConnectivityList,vtcs3D);
        %calculate reconstructable rest area
        restArea = area(restPoly2D);
    end
    diagnostics = struct('fragCell',fragCell,...
                         'fragVec',polyShapes,...
                         'short',skipAggregation);
end