function [gs SpikeRate] = gridScoreForSpikes(SpikePosCm,TrajPosCm, opt)
% gridScoreForSpikes
%   G       - Positions of spikes with dimensions: (nSample x 2) in cm.
%   opt     - Structure with fields:
%             * NumPx - Number of pixel in horizontal and vertical
%                       direction in that order.
%             * DimCm - Dimensions of the box in horizontal and vertical
%                       direction in that order.
%               
% RETURN
%   gs      - Grid score that ranges between -2 and +2.
%
% DESCRIPTION
%   A detailed a description of this measure can be found in the
%   supplementary material of Langston, R. F., Ainge, J. A., Couey, J. J., 
%   Canto, C. B., Bjerkens, T. L., Witter, M. P., Moser, E. I., 
%   & Moser, M.-B. (2010). Development of the spatial representation 
%   system in the rat. Science, 328, 1576–1580.
%
%   Copyright (C) 2015  Florian Raudies, 05/02/2015, Palo Alto, CA.
%   License, GNU GPL, free software, without any warranty.
%

if isfield(opt, 'NumPx'),       NumPx       = opt.NumPx;
else                            NumPx       = [31 31];          end
if isfield(opt, 'DimCm'),       DimCm       = opt.DimCm;
else                            DimCm       = [-50 50 -50 50];  end

xMinCm = DimCm(1);
xMaxCm = DimCm(2);
yMinCm = DimCm(3);
yMaxCm = DimCm(4);

if 0.8*xMinCm < min(TrajPosCm(:,1)) ...
        || 0.8*xMaxCm > max(TrajPosCm(:,1)) ...
        || 0.8*yMinCm < min(TrajPosCm(:,2)) ...
        || 0.8*yMaxCm > max(TrajPosCm(:,2)),
    warning('Matlab:Parameter','Shrink the DimCm to match the data!');
end

if 1.05*xMinCm > min(TrajPosCm(:,1)) ...
        || 1.05*xMaxCm < max(TrajPosCm(:,1)) ...
        || 1.05*yMinCm > min(TrajPosCm(:,2)) ...
        || 1.05*yMaxCm < max(TrajPosCm(:,2)),
    warning('Matlab:Parameter','Increase the DimCm to match the data!');
end

% Get spike count in bins registering the positions at which spikes occured.
SpikeCount  = getOccupancyMap(SpikePosCm,DimCm,NumPx);
Occupancy   = getOccupancyMap(TrajPosCm,DimCm,NumPx);
SpikeRate   = SpikeCount./(eps+Occupancy);

% Calculate the grid score from the spike rate map.
gs = gridScoreForActivity(SpikeRate, opt);


function Occupancy = getOccupancyMap(PosCm,DimCm,NumPx)
    % getOccupancyMap
    %   PosCm       - x,y coordinates in 2nd dimension sample points in 1st
    %                 dimension in units of cm.
    %   DimCm       - Dimensions in cm for x and y. Assumes the center to be in
    %                 the middle. DimCm = [xMinCm xMinCm yMinCm yMaxCm]
    %   DimPx       - Dimension in pixels for x and y.
    %                 DimPx = [xLenPx yLenPx]
    %
    % RETURN
    %   Occupancy   - Map that encodes the occupancy of the rat in the box
    %                 according to the binning into a 2D pixel grid.

    xMinCm = DimCm(1);
    xMaxCm = DimCm(2);
    yMinCm = DimCm(3);
    yMaxCm = DimCm(4);

    xLenCm = xMaxCm - xMinCm;
    yLenCm = yMaxCm - yMinCm;

    xCenCm = xLenCm/2;
    yCenCm = yLenCm/2;

    xLenPx = NumPx(1);
    yLenPx = NumPx(2);

    PosPx = [min(max(ceil( (PosCm(:,1) + xCenCm)/xLenCm * xLenPx ),1),xLenPx) ...
             min(max(ceil( (PosCm(:,2) + yCenCm)/yLenCm * yLenPx ),1),yLenPx)];

    LinearIndex = sub2ind([yLenPx xLenPx], PosPx(:,2), PosPx(:,1));
    Occupancy   = zeros(yLenPx, xLenPx);
    nPos        = numel(LinearIndex);
    for iPos = 1:nPos,
       Occupancy(LinearIndex(iPos)) = Occupancy(LinearIndex(iPos))+1; 
    end

