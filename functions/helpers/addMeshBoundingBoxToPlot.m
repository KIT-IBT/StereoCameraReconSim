%% -------------------------------------------------------
%
%    addMeshBoundingBoxToPlot - Inserts the bounding box of a point cloud
%                               into a target figure
%     
%    Ver. 1.0
%
%    Created:           Jan Kost (19.10.2020)
%    Last modified:     Jan Kost (19.10.2020)
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
%  returnHandle = addMeshBoundingBoxToPlot(handle,V)
%        
%        input: 
%               handle:
%                   target figure handle
%               pts:
%                   nx3 matrix. each row contains the cartesian coordiantes
%                   of on point
%                
%        output: 
%               returnHandle:
%                   handle of the edited target figure 
%
function returnHandle = addMeshBoundingBoxToPlot(handle,pts)
    set(0,'CurrentFigure',handle)
    hold on
    %find the corners of the bounding box
    X = pts(:,1);
    Y = pts(:,2);
    Z = pts(:,3);
    xMax = max(X); 
    xMin = min(X);
    yMax = max(Y); 
    yMin = min(Y);
    zMax = max(Z); 
    zMin = min(Z);
    corners = [...
            xMin,yMin,zMin;...%4 bottom points
            xMax,yMin,zMin;...
            xMax,yMax,zMin;...
            xMin,yMax,zMin;...
            xMin,yMin,zMax;...%4 top points
            xMax,yMin,zMax;...
            xMax,yMax,zMax;...
            xMin,yMax,zMax;...
        ];
    %triangulate the bounding box
    tri = delaunayTriangulation(corners);
    [K,~] = convexHull(tri);
    %plot the convex hull ofthe triangultion (i.e. omit faces within the
    %volume of the box
    trisurf(K,tri.Points(:,1),tri.Points(:,2),tri.Points(:,3),...
                                                          'FaceColor','g');
    hold off
    %move the origin text labels out of the way of the newly plotted box.
    %this only applies to text labels with specific manually added tags.
    shift = ones(1,3)*abs(zMin);
    hLabel = findobj(gcf,'Tag','Origin_Label');
    if ~isempty(hLabel)
       hLabel.Position = hLabel.Position - shift;
    end
    hLabel2 = findobj(gcf,'Tag','Origin_Label_2');
    if ~isempty(hLabel2)
        hLabel2.Position = hLabel2.Position - shift;
    end
    returnHandle = gcf;
end