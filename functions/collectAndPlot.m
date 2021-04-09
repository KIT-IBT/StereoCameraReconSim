%% -------------------------------------------------------
%
%    collectAndPlot - Collects the faces that aren't fully occluded or
%                     outside the FOV. These faces' 2D image & 3D world
%                     representations are are organized in the output 
%                     struct. This is done for each camera.
%                     If there are less than 10 cameras, or if the
%                     user explicitly calls for them, the camera images are
%                     plotted in 2D and 3D (3D being the surface made up of
%                     the fractions of each face that are visible to the
%                     camera in question.
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
%  results = collectAndPlot(camViews,Centroids3D,dispPlot,enforcePlot,...
%                                                                  showIDs)
% 
%        input: 
%               camViews: struct containing the face data of all faces that
%                         are potentially visible to each individual camera
%
%				Centroids3D: Nx3 matrix, rows are 3D coordinates of
%                            the centroids of each face in the input mesh
%
%				dispPlot: bool, toggles figure visibility
%
%				enforcePlot: bool, overrides automatic camera plot
%                            disabling if there are more than 10 cameras
%
%				showIDs: bool, toggles adding face IDs in the camera
%                        image plots
%
%        output: 
%               results: struct containing faces sorted by visibility 
%                        status, along with camera image figures if
%                        applicable
%               

function results = collectAndPlot(camViews,Centroids3D,dispPlot,...
                                                      enforcePlot,showIDs)
    %% Prep stuff
    results = struct();
    imgPlots = struct();
    surfPlots = struct();
    camNo = camViews.amount;
    %prevents generating, as well as potentially displaying and
    %saving, an inconvenient number of camera images.
    skipPlots = ((camNo > 6)&& ~enforcePlot);
    %generate argument sets for figure() 
    imgFigName = 'Projected Image: ';
    surfFigName = 'Visible Face Remains: ';
    if skipPlots
        imgArgs = struct('Name',['Cam image plots disabled: ',...
                  'too many cameras'],'NumberTitle','off','Visible','off');
        disp(['plots automatically disabled due to', ...
                                           ' large number of cameras']);
        surfArgs = imgArgs;
    else
        imgArgs = struct('NumberTitle','off','Visible',dispPlot);
        surfArgs = imgArgs;
    end
    %set colors for the image plots
    lineColors = [[0 0 0];... % black for non-clipped faces
                  [255 0 0]];... % red for clipped faces];
    fillColors = [[160 160 160];... % grey1 for non-clipped faces
                  [193 90 99];... % light red for clipped faces
                  [85 85 85]];% grey2 for clipped faces
    lineColors = lineColors/255;
    fillColors = fillColors/255;

    %% collect data & plot
    for i = 1:camNo %for each camera
        currCamView = camViews.(['cam',num2str(i)]);
        %collect data for faces that are still at least partially visible
        [s2D,s3D,reconStruct] = sortFaceData(currCamView.nonCulledFaces);
        results.data.(['cam',num2str(i)]) = struct(...
                                     'reconData',reconStruct,...
                                     'plotData2D',s2D,...
                                     'plot3D',s3D...
                                 );
        if ~skipPlots
            imgArgs.Name = [imgFigName,'Camera ',num2str(i),'.'];
            surfArgs.Name = [surfFigName,'Camera ',num2str(i),'.'];
            %% populate 2D cam view Plot
            hImg = figure(imgArgs);
            hold on
            %plot faces that weren't occluded at all
            nocFaces = s2D.notOccludedFaces;
            nocIDs = s2D.NoOC_IDs;
            faceColor = fillColors(1,:);
            edgeColor = lineColors(1,:);
            for j = 1:numel(nocFaces)
                currPoly = nocFaces(j);
                plot(currPoly,'EdgeColor',edgeColor,'FaceColor',...
                                                 faceColor,'FaceAlpha',0.3)
                if showIDs
                    [cx,cy] = centroid(currPoly);
                    text(cx,cy,num2str(nocIDs(j)))
                end
            end
            %plot remains of faces that were clipped
            clipRemains = s2D.clippingRemains;
            clipIDs = s2D.remain_IDs;
            faceColor = fillColors(3,:);
            edgeColor = lineColors(2,:);
            for j = 1:numel(clipRemains)
                currPoly = clipRemains(j);
                plot(currPoly,'EdgeColor',edgeColor,'FaceColor',...
                                                 faceColor,'FaceAlpha',0.3)
                if showIDs
                    [cx,cy] = centroid(currPoly);
                    text(cx,cy,num2str(clipIDs(j)))
                end
            end
            %% populate 3D visible face Plot
            hSurf = figure(surfArgs);
            hold on
            nocFaces3d = s3D.notOccludedFaces;
            clipFaces3D = s3D.originalClippedfaces;
            clipRemains3D = s3D.clippingRemains;
            if ~isempty(nocFaces3d)
                %plot clipping remains
                for k = 1:size(nocFaces3d,3)
                    currPatch = nocFaces3d(:,:,k);
                    patch('XData',currPatch(:,1),...
                          'YData',currPatch(:,2),...
                          'zData',currPatch(:,3),...
                          'EdgeColor',lineColors(1,:),...
                          'FaceColor',fillColors(1,:),...
                          'FaceAlpha',0.3);
                    if showIDs
                        %plot face ID
                        currID = nocIDs(k);
                        coords = Centroids3D(currID,:);
                        text(coords(:,1),...
                             coords(:,2),...
                             coords(:,3),...
                             num2str(currID))
                    end
                end
            end
            if ~isempty(clipFaces3D)
                %plot remains of partially clipped faces
                lastID = 0;
                for l = 1:size(clipRemains3D,2)
                    currPatch = clipRemains3D{l};
                    patch('XData',currPatch(:,1),...
                          'YData',currPatch(:,2),...
                          'zData',currPatch(:,3),...
                          'EdgeColor',lineColors(2,:),...
                          'FaceColor',fillColors(3,:),...
                          'FaceAlpha',0.3);
                    if showIDs
                        currID = clipIDs(l);
                        if ~(currID == lastID)
                            %plot face ID, but only once for each face
                            coords = Centroids3D(currID,:);
                            text(coords(:,1),...
                                 coords(:,2),...
                                 coords(:,3),...
                                 num2str(currID))
                        end
                        lastID = currID;
                    end
                end
            end
            imgPlots.(['cam',num2str(i)]) = hImg;
            surfPlots.(['cam',num2str(i)]) = hSurf;
        end
    end
    results.plots = struct('skipped_plotting',skipPlots,...
                           'cameraImages',imgPlots,...
                           'visibleArea3D',surfPlots);
    
end