function [SpikePos SpikeTime] = attractorModel(Time, Pos, Vel, opt)
% attractorModel - Guanella et al., 2007
%   Time    - Time axis with dimensions: sampleNum x 1 in sec.
%   Pos     - Postion as matrix with dimensions: sampleNum x 2 in cm.
%   Vel     - Linear velocity in cm/sec.
%   opt     - Structure with fields:
%             * alpha -- velocity modulation which controls grid spacing.
%                        Grid spacing is approx. 1.02 - 0.48*log2(alpha).
%
% RETURN
%   SpikePos    - Position of spike.
%   SpikeTime   - Time of spike.
%
% DESCRIPTION
%   This is an implementation of
%   Guanella, A., Kiper, D., and Verschure, P. (2007). A model of grid 
%   cells based on a twisted torus topology. International Journal of 
%   Neural Systems 17(4), 231-240.
%
%   Copyright (C) 2015  Florian Raudies, 04/29/2015, Palo Alto, CA.
%   License, GNU GPL, free software, without any warranty.
%

if isfield(opt,'alpha'), alpha = opt.alpha; else alpha = 5e-4; end
if isfield(opt,'init'), init = opt.init; else init = 5; end

% If init is non-zero set the initial state of the random number generator.
if init, rng(init); end

nX      = 9;        % Cells in x direction.
nY      = 10;       % Cells in y direction.
n       = nX*nY;    % Total cell count.
beta    = 0;        % Grid orientation.
sigma   = 0.24;     % Standard deviation of Gaussian.
I       = 0.3;      % Peak synaptic strength.
T       = 0.05;     % Weights at the tail end turn inhibitory.
tau     = 0.8;      % Weight for normalization.
th      = 0.1;      % Threshold for firing.
A       = rand(1,n)/sqrt(n);        % Initial activity.
R       = [cos(beta) -sin(beta); ...
           sin(beta) cos(beta)];    % Rotation matrix.
Dsq     = zeros(7,n,n);             % Distance matrix.
iCell   = round(n/2-nY/2);          % Index of recorded cell in the center.
[Y X]   = ndgrid(sqrt(3)/2*((1:nY) - 0.5)/nY, ...
                ((1:nX) - 0.5)/nX); % X, Y
[Ix Jx] = ndgrid(X(:), X(:));   % Indices in columns and rows.
[Iy Jy] = ndgrid(Y(:), Y(:));   % Indices in columns and rows.
Dy      = Iy - Jy;              % Difference of indices in y.
Dx      = Ix - Jx;              % Difference of indices in x.
nStep   = size(Pos,1);          % Number of simulation steps.
Spike   = zeros(nStep,1);       % Positions of spikes.
for iStep = 1:nStep,
    % Get biased, rotated velocity.
    AlphaRv     = alpha*R*Vel(iStep,:)';
    
    % Compute distance in tri-norm.
    Dsq(1,:,:)  = (Dx   +0 +AlphaRv(1)).^2 + (Dy         +0 +AlphaRv(2)).^2;
    Dsq(2,:,:)  = (Dx -0.5 +AlphaRv(1)).^2 + (Dy +sqrt(3)/2 +AlphaRv(2)).^2;
    Dsq(3,:,:)  = (Dx -0.5 +AlphaRv(1)).^2 + (Dy -sqrt(3)/2 +AlphaRv(2)).^2;
    Dsq(4,:,:)  = (Dx +0.5 +AlphaRv(1)).^2 + (Dy +sqrt(3)/2 +AlphaRv(2)).^2;
    Dsq(5,:,:)  = (Dx +0.5 +AlphaRv(1)).^2 + (Dy -sqrt(3)/2 +AlphaRv(2)).^2;
    Dsq(6,:,:)  = (Dx -1.0 +AlphaRv(1)).^2 + (Dy         +0 +AlphaRv(2)).^2;
    Dsq(7,:,:)  = (Dx +1.0 +AlphaRv(1)).^2 + (Dy         +0 +AlphaRv(2)).^2;
    DsqTri      = squeeze(min(Dsq));
    
    % Update the weights and activities.
    W           = I*exp(-DsqTri/sigma^2) - T;
    B           = A*W';
    A           = (1-tau)*B + tau*B/sum(A);
    A(A<0)      = 0;
    
    % Produce spike whenever the activity at the recorded cell is above
    % threshold.
    Spike(iStep)= A(iCell) > th;
end

% Returns spikes with position and time.
Spike       = logical(Spike);
SpikePos    = Pos(Spike,:);
SpikeTime   = Time(Spike);

