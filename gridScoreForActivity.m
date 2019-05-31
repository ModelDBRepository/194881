function gs = gridScoreForActivity(Activity, opt)
% gridScoreForActivity
%   Activity    - Acitvity pattern of a (simulated) cell.
%   opt         - Structure with fields:
%                 * minRadius -- Minimum radius for circular histogram
%                                computed from values within the disk 
%                                defined by minRadius and maxRadius.
%                 * maxRadius -- Maximum radius.
%
% RETURN
%   gs          - Returns the grid score for the activity pattern.
%
%   Copyright (C) 2015  Florian Raudies, 05/02/2015, Palo Alto, CA.
%   License, GNU GPL, free software, without any warranty.
%

if isfield(opt, 'minRadius'),   minRadius   = opt.minRadius; 
else                            minRadius   = 0.05;             end
if isfield(opt, 'maxRadius'),   maxRadius   = opt.maxRadius; 
else                            maxRadius   = 0.95;             end

% Determine sizes and their ratio.
[nY nX]     = size(Activity);
r           = nX/nY;
[Y X]       = ndgrid(linspace(-1, +1, nY), linspace(-r, +r, nX));
Radius      = hypot(X, Y);
Phi         = mod(atan2(Y, X) + 2*pi, 2*pi);
Selection   = (minRadius < Radius) & (Radius < maxRadius);

% Calculate the product moment correlation coefficient of Pearson
AutoCorr = normAutoCorrWithFFT2D(Activity);

% Extract a circular disk of the auto-correlation
binNum          = 12;
binNum2         = binNum/2;
dPhi            = 2*pi/binNum;
dPsi            = dPhi/2;
DiskSelection   = AutoCorr(Selection);
PhiSelection    = Phi(Selection);

% Define bins for circular distribution.
BinCenter       = 0 : dPhi : (2*pi - dPhi);
DiskVoting      = zeros(binNum, 1);
PhiVoting       = zeros(binNum, 1);

% Select everything above and below adding an subtracting half of the bin
% distance, circular boundary condition.
IndexSelection  = PhiSelection < BinCenter(1)+dPsi ...
                | PhiSelection >= 2*pi-dPsi;
DiskVoting(1)   = sum(DiskSelection(IndexSelection));
PhiVoting(1)    = sum(IndexSelection);

% Do the remaining bins.
for iBin = 2:binNum,
    IndexSelection      = PhiSelection >= BinCenter(iBin)-dPsi ...
                        & PhiSelection < BinCenter(iBin)+dPsi;
    DiskVoting(iBin)    = sum(DiskSelection(IndexSelection));
    PhiVoting(iBin)     = sum(IndexSelection);
end

% Calculate the circular correlation
% In one group correlate rotations of 60° and 120° and in the other group 
% correlate rotations of 30°, 90°, and 150°.
% Conversion into orientations.
Shift           = [30 60 90 120 150]/180*pi;
GroupIndexOne   = [2 4];
GroupIndexTwo   = [1 3 5];
sNum            = length(Shift);
% Use function pearsonCorr because it works for even number (unlike the fft solution)
DiskCorr        = pearsonCorr(DiskVoting, 'circular');
ShiftCorr       = zeros(sNum, 1);
for iShift = 1:sNum,
    DiskCorrShift       = vecShiftCyc(DiskCorr, -Shift(iShift)*binNum2/pi);
    ShiftCorr(iShift)   = DiskCorrShift(binNum2);
end
ValGroupOne = ShiftCorr(GroupIndexOne); % 60° and 120°
ValGroupTwo = ShiftCorr(GroupIndexTwo); % 30°, 90°, and 150°
gs = min(ValGroupOne) - max(ValGroupTwo);


function X = vecShiftCyc(X, s)
    % vecShiftCyc
    %   X       - Vector to shift for amount 's' with cyclic boundary
    %             condition.
    %   s       - Amount to shift, which could be also a FRACTION of one pixel.
    %
    % RETURN
    %   X       - Shifted version of the vector.
    %
    ds1 = s - floor(s);
    ds0 = 1 - ds1;
    s0  = floor(s);
    s1  = ceil(s);
    X0  = circshift(X(:), s0);
    X1  = circshift(X(:), s1);
    X   = ds0 * X0 + ds1 * X1;


function X = pearsonCorr(X, boundary)
    % personCorr
    %   X           - Input data which could be a multi-dimensional array.
    %   boundary    - Boundary condition for correlation.
    %
    % RETURN
    %   Y           - Full correlation result for all shifts which data X
    %                 provides, basicially determined by the dimensions of X.
    %
    % DESCRIPTION
    %   Pearson's product moment correlation coefficient.
    %
    n = numel(X);
    I = ones(size(X));
    A = n * imfilter(X, X, 'same', boundary);
    B = sum(X(:)) * imfilter(X, I, 'same', boundary);
    C = sqrt( n * sum(X(:).^2) - sum(X(:)).^2 );
    D = sqrt( n * imfilter(X.^2, I, 'same', boundary) - imfilter(X, I, 'same', boundary).^2 );
    X = (A - B) ./ (C.*D + eps);


function AC = normAutoCorrWithFFT2D(S)
    % normAutoCorrWithFFT2D
    %   S   - Signal one assumed to be a row-vector.
    %
    % RETURN
    %   NA  - Normalized auto-correlation result.
    %
    F   = fft2(S-mean(S(:)));
    F   = F .* conj(F);
    AC  = fftshift(ifft2(F));
    AC  = real(AC);
    AC  = AC/AC(1);
