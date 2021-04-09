%% -------------------------------------------------------
%
%    convertToPlucker - returns the directed line between two points p & q
%                       (from p to q)
%                       in pluecker coordinates using a representation of 
%                       p and q in homogeneous coordinates 
%
%    Ver. 1.0
%
%    Created:           Jan Kost (15.09.2017)
%    Last modified:     Jan Kost (19.10.2020)
%
%    Institute of Biomedical Engineering
%    Karlsruhe Institute of Technology
%
%    http://www.ibt.kit.edu
%
%    Copyright 2018 - All rights reserved.
%
% ------------------------------------------------------
%
%        pl = convertToPlucker(p,q)
% 
%        input: 
%               p:"Departure" point in cartesian coordinates (1x3 vector)
%               q:"Destination" point in cartesian coordinates (1x3 vector)
%
%        output: 
%               pl: Pluecker representation of the line (1x6 vector)

function pl = convertToPlucker(p,q)
    % calculate primal pluecker coordinates of the line 
    pl_1 = p(1)*q(2) - q(1)*p(2);           
    pl_2 = p(1)*q(3) - q(1)*p(3);           
    pl_3 = p(1) - q(1);
    pl_6 = p(2)*q(3) - q(2)*p(3);
    pl_4 = p(3) - q(3);
    pl_5 = q(2) - p(2);
    % combine into vector
    pl = [pl_1,pl_2,pl_3,pl_4,pl_5,pl_6];   
end

