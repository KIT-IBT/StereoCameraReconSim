%% -------------------------------------------------------
%
%    occlusionStatus - Finds out if a subject polygon is partially or 
%                      entirely hidden by a potential occluder polygon.
%
%    Ver. 1.0
%
%    Created:           Jan Kost (26.02.2020)
%    Last modified:     Jan Kost (21.10.2020)
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
%   [occlusion,fullyInside,whoInWho] = occlusionStatus(poly1,poly2)
%
% 
%        input:
%
%           subj: polyshape object for face 1
%
%        	occl: polyshape object for face 2
%
%        output: 
%
%           occlusion - Boolean, true if the polygons intersect.
%
%           fullyInside - Boolean, true if either polygon is entirely
%                         contained within the other one
%
%           whoInWho - 0: error case, 1: subj in occl, 2: occl in subj.
%                      (2 means that the occluder'S shade cuts a hole into
%                       the subject polygon)

function [occlusion,fullyInside,whoInWho] = occlusionStatus(subj,occl)
                
    occlusion = false;
    fullyInside = false;
    whoInWho = 0;
    if overlaps(subj,occl) %the two polygons intersect
        occlusion = true;
        %distinguish full or partial occlusion
        mergedPoly = union(subj,occl);
        if mergedPoly.NumRegions == 1 %sanity check 
            mrgVtcs = mergedPoly.Vertices;
            if isequal(mrgVtcs,subj.Vertices)
                %poly1 contains poly2
                fullyInside = true;
                whoInWho = 2;
            elseif isequal(mrgVtcs,occl.Vertices)
                %poly2 contains poly1
                fullyInside = true;
                whoInWho = 1;
            end
        else
            %Degenerate input polygons. The union of the two polygons 
            %should only have one region (assuming no holes and no self
            %intersecting polygons)
            warning(['Degenerate poylgons (e.g. polygons with holes)',...
                    ' detected!']);
            subj.Vertices
            occl.Vertices
            fullyInside = false;
            whoInWho = 0;
        end
    end
end
