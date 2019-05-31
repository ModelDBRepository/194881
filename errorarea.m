function [ha hl] = errorarea(X,LineVal,AreaVal,colorArea,colorLine)
% ERRORAREA
%   X               - abscissa.
%   LineVal         - Mean values.
%   AreaVal         - Standard deviation.
%   colorArea       - color of area.
%   colorLine       - color of line.
%
% RETURN
%   ha              - Handle to area.
%   hl              - Handle to line.
%

%   Florian Raudies, 2009/10/23, University of Ulm.

if nargin<4, colorArea='b'; end
if nargin<5, colorLine='k'; end

d = 1;
X = X(:);
LineVal = LineVal(:);
AreaVal = AreaVal(:);

Xd = [X; flipud(X)];
Yd = [LineVal-d*AreaVal; flipud(LineVal+d*AreaVal)];

ha = fill(Xd,Yd,colorArea,'LineStyle','none');
hold on;
hl = plot(X,LineVal,'-','LineWidth',1.0,'Color',colorLine);
hold off;
