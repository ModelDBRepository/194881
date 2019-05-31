function [CorrCoeff, Stretch] = rescaleCorr(X, Y, opt)
% rescaleCorr
%   X   - First input 2D matrix.
%   Y   - Second input 2D matrix.
%   opt - Structure with fields:
%         * scale - Compression scale that refers to 100% compression.
%
% RETURN
%   CorrCoff    - Correlation coefficient for all tested stretches along
%                 the 1st dimension.
%   Strecth     - Tested strech ratios.
%
%   Copyright (C) 2015  Florian Raudies, 05/02/2015, Palo Alto, CA.
%   License, GNU GPL, free software, without any warranty.
%

nX1         = size(X,1);
nY1         = size(Y,1);
scale       = opt.scale;
nStretch    = 51;
CorrCoeff   = zeros(nStretch, 1);
Stretch     = linspace(0.6, 1.15, nStretch); % Range of stretch factors.

if nX1~=nY1,    
    X = interp1(linspace(-1,+1,nX1)',X,linspace(-scale,scale,nY1)','*linear');    
    Original    = linspace(-scale,scale,nY1);
    for iStretch = 1:nStretch,
        stretch                     = Stretch(iStretch);
        Rescale                     = linspace(-stretch,+stretch,nY1);
        YStretch                    = interp1(Rescale',Y,Original',...
                                              '*linear');
        YStretch(isnan(YStretch))   = 0;
        CorrCoeff(iStretch)         = corrCoeff(X,YStretch);
    end
    
    Stretch = 2*(Stretch - scale)/scale; % strech = 2/3 is 100%
else
    error('Matlab:IO','Only supports matching for the 1st dimension!');
end


function r = corrCoeff(X,Y)

    X = X(:);
    Y = Y(:);
    X = X - mean(X);
    Y = Y - mean(Y);
    r = sum(X.*Y)./(eps + sqrt(sum(X.^2).*sum(Y.^2)));
    