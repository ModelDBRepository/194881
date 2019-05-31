clc; clear all; close all; clear classes
% *************************************************************************
% Simulation of the module model for configuration A (square box) runs for
% about 4 min.
%
%   Copyright (C) 2015  Florian Raudies, 05/02/2015, Palo Alto, CA.
%   License, GNU GPL, free software, without any warranty.
% *************************************************************************

addpath('./DotWorld/');

rng(4); % Set the seed value for the random number generator.
% Initialize the camera, cube box, and the module model.
camera      = SphericalCamera([0;0;1;0],[0;1;0;0],[0;0;0;0],...
                              360/180*pi,120/180*pi,0,0,0,0,5,10^4);
cube        = Cube([-75 -2.5 -75 75 47.5 75],[3 3 3]);
Ground      = cube.getGroundSegment();
configA     = Scene(cube, camera);
opt.nStep   = 5*10^4; % Number of steps to simulate.
opt.Ground  = Ground; % Logical index for ground samples.
mm          = ModuleModel(configA, opt); % Instantiate the module model.

tic

mm.simulate();

rmpath('./DotWorld/');

PosGt           = mm.getPosGt;      % use 1-x, 2-y
VelZGt          = mm.getVelZGt;
OmegaYGt        = mm.getOmegaYGt;
PosEstByVel     = mm.getPosEstByVel;
PosEstByAng     = mm.getPosEstByAng; % use 1-x, 2-y
SpikePosForVel  = mm.getSpikePosForVel;
SpikePosForAng  = mm.getSpikePosForAng;

opt.NumPx = [41 41]; % Discretization for firing rate maps.
[gsVelVCO, SpikeRateVelVCO, gsAngVCO, SpikeRateAngVCO] ...
    = mm.calculateGridScores(opt);

mm.calculateGridCellFiringWithAttractorModel();

[gsVelAtt, SpikeRateVelAtt, gsAngAtt, SpikeRateAngAtt] ...
    = mm.calculateGridScores(opt);

toc

save('SimConfA', 'PosGt', 'PosEstByAng', 'PosEstByVel', ...
    'VelZGt', 'OmegaYGt', 'SpikePosForVel', 'SpikePosForAng',...
    'gsVelVCO', 'SpikeRateVelVCO', 'gsAngVCO', 'SpikeRateAngVCO',...
    'gsVelAtt', 'SpikeRateVelAtt', 'gsAngAtt', 'SpikeRateAngAtt');
