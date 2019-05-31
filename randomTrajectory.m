function Pos = randomTrajectory(opt)
% randomTrajectory
%   opt - Structure with the following fields:
%         * dt              - Step width in sec/step.
%         * dTh             - Below this distance threshold change speed 
%                             and rotate away from the closest wall in cm.
%         * sMin            - Minimal speed in cm/sec.
%         * sPeak           - Target speed in cm/sec.
%         * PosInit         - Initial position with x,y coordinates in cm.
%         * PosXInterval    - Horizontal interval xMin and xMax in cm.
%         * PosYInterval    - Vertical interval yMin and yMax in cm.
%         * DirInit         - Initalization of direction, no UNIT.
%         * nStep           - Number of steps for this trajectory, no UNIT.
%         * rayBeta         - Beta parameter of Rayleigh distribution, in
%                             cm. This corresponds to the peak location of
%                             the distribution.
%         * normMu          - Mean value of normal distribution, in °/RAD.
%         * normSimga       - Standard deviation of normal distribution, in
%                             °/RAD.
%
% RETURN
%   Pos - Position vector with x,y coordinates, which has the dimensions:
%         nStep x 2.
%
% DESCRIPTION
%   This script generates a random trajectory in the 2D plane within a box
%   of the specified dimensions. The distribution of linear and rotational
%   speeds follows that of data. Linear speed is modeled through a Rayleigh
%   distribution and rotational speed is modeled through a normal
%   distribution.
%
%   Copyright (C) 2015  Florian Raudies, 05/02/2015, Palo Alto, CA.
%   License, GNU GPL, free software, without any warranty.
%

if isfield(opt,'dt'),           dt              = opt.dt;
else                            dt              = 0.02;     end % sec/step
if isfield(opt,'dTh'),          dTh             = opt.dTh; 
else                            dTh             = 15;       end % cm
if isfield(opt,'sMin'),         sMin            = opt.sMin;   
else                            sMin            = 5;        end % cm/sec
if isfield(opt,'sPeak'),        sPeak           = opt.sPeak; 
else                            sPeak           = 20;       end % cm/sec
if isfield(opt,'PosInit'),      PosInit         = opt.PosInit;
else                            PosInit         = [0 0];    end % cm
if isfield(opt,'PosXInterval'), PosXInterval    = opt.PosXInterval;
else                            PosXInterval    = [-50 50]; end % cm
if isfield(opt,'PosYInterval'), PosYInterval    = opt.PosYInterval;
else                            PosYInterval    = [-50 50]; end % cm
if isfield(opt,'DirInit'),      DirInit         = opt.DirInit;
else                            DirInit         = [0 1];    end % NONE
if isfield(opt,'nStep'),        nStep           = opt.nStep;
else                            nStep           = 5*10^4;   end % step
if isfield(opt,'rayBeta'),      rayBeta         = opt.rayBeta;
else                            rayBeta         = 13.25;    end % cm/sec
if isfield(opt,'normMu'),       normMu          = opt.normMu;
else                            normMu          = 0.0;      end % deg/sec
if isfield(opt,'normSigma'),    normSigma       = opt.normSigma;
else                            normSigma       = 15.0;     end % deg/sec


% Generate random turn speeds and linear speeds.
RandTurn    = normMu/180*pi + randn(nStep,1)*normSigma/180*pi;
RandSpeed   = raylrnd(rayBeta,[nStep 1]);
s           = sPeak;
eta         = 0.5;
Pos         = zeros(nStep,2);
Pos(1,:)    = PosInit';
Dir         = DirInit;

% Define borders. 
xMin = PosXInterval(1);
xMax = PosXInterval(2);
yMin = PosYInterval(1);
yMax = PosYInterval(2);

% Define the corners NorthEast, NorthWest, SouthEast, and SouthWest.
NE = [xMax yMax];
NW = [xMin yMax];
SE = [xMax yMin];
SW = [xMin yMin];

% Setup the walls. Points appear in this order to have always positive 
% distances.
Wall = [wall2D(NW, NE); ... % top wall
        wall2D(SW, NW); ... % left wall
        wall2D(SE, SW); ... % bottom wall
        wall2D(NE, SE)];    % right wall

for iStep = 2:nStep,
    [dWall aWall] = minDistAngleWallInFoV2D(Wall, Pos(iStep-1,:), Dir, pi);
    
    % Update speed and turn angle.
    if dWall<dTh && abs(aWall)<pi/2,
        s       = s - eta*(s-sMin);
        angle   = sign(aWall)*(pi/2-abs(aWall)) + RandTurn(iStep,:);        
    else
        s       = RandSpeed(iStep);
        angle   = RandTurn(iStep,:);
    end
    
    % Move.
    Pos(iStep,:) = Pos(iStep-1,:) + Dir*s*dt;
    
    % Turn.
    Dir = ([+cos(angle) -sin(angle); ...
            +sin(angle) +cos(angle)]*Dir')';
end


function W = wall2D(P1, P2)
    % Defines a wall by [nx ny d p1x p1y p2x p2y]
    Delta   = P2 - P1;
    Delta   = Delta/hypot(Delta(1), Delta(2));
    d       = - (P1(1)*Delta(2) - P1(2)*Delta(1));
    W       = [-Delta(2) Delta(1) d min(P1(1),P2(1)) min(P1(2),P2(2)) ...
                                    max(P1(1),P2(1)) max(P1(2),P2(2))];
                                
function [d a] = minDistAngleWallInFoV2D(Wall, Pos, Dir, foV)
    NxWall  = Wall(:,1);
    NyWall  = Wall(:,2);
    DWall   = Wall(:,3);
    XMin    = Wall(:,4);
    YMin    = Wall(:,5);
    XMax    = Wall(:,6);
    YMax    = Wall(:,7);
    px      = Pos(1);
    py      = Pos(2);
    nx      = Dir(1);
    ny      = Dir(2);
    Valid   = abs(NxWall*nx + NyWall*ny) > eps;
    NxWall  = NxWall(Valid);
    NyWall  = NyWall(Valid);
    DWall   = DWall(Valid);
    D       = (DWall - NxWall*px - NyWall*py)./(NxWall*nx + NyWall*ny);
    Sx      = px + D*nx;
    Sy      = py + D*ny;
    % To avoid numerical problems need to add/sub 10^-5.
    Valid   = XMin(Valid) <= (Sx+10^-5) & (Sx-10^-5) <= XMax(Valid) ...
            & YMin(Valid) <= (Sy+10^-5) & (Sy-10^-5) <= YMax(Valid);
    NxWall  = NxWall(Valid);
    NyWall  = NyWall(Valid);
    D       = D(Valid);
    A       = atan2(-NyWall*nx + NxWall*ny, NxWall*nx + NyWall*ny);
    Valid   = abs(A) <= foV/2;
    D       = D(Valid);
    A       = A(Valid);
    [d,mi]  = min(abs(D));
    a       = A(mi);                                