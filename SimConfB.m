clc; clear all; close all; clear classes
% *************************************************************************
% Simulation of the module model for configuration B (rectangular box) 
% takes about 4 min.
%
%   Copyright (C) 2015  Florian Raudies, 05/02/2015, Palo Alto, CA.
%   License, GNU GPL, free software, without any warranty.
% *************************************************************************

addpath('./DotWorld');

rng(4); % Set the seed value for the random number generator.
% Initialize the camera, cube box, and the module model.
camera      = SphericalCamera([0;0;1;0],[0;1;0;0],[0;0;0;0],...
                              360/180*pi,120/180*pi,0,0,0,0,5,10^4);
cube        = Cube([-75 -2.5 -75 75 47.5 75],[3 3 3]);
GroundA     = cube.getGroundSegment();
configA     = Scene(cube, camera);
P1          = cube.getPoints();
opt.nStep   = 5;
opt.Ground  = GroundA;
% Create the module model here because of the change of the cube, which
% would influence the width/length parameters inside the module model.
mm          = ModuleModel(configA, opt);

% Change the cube for configuration B.
[cube DeleteIndex]  = cube.resizeX([-50 50]); % Configuration B.
GroundB             = cube.getGroundSegment();
configB             = Scene(cube, camera);
P2                  = cube.getPoints();
opt.nStep           = 5*10^4;
opt.Ground          = GroundB;
opt.DeleteIndex     = DeleteIndex;
mm.resetScene(configB, opt);

tic
mm.simulate();

rmpath('./DotWorld');

PosGt           = mm.getPosGt;
VelZGt          = mm.getVelZGt;
OmegaYGt        = mm.getOmegaYGt;
PosEstByVel     = mm.getPosEstByVel;
PosEstByAng     = mm.getPosEstByAng;
SpikePosForVel  = mm.getSpikePosForVel;
SpikePosForAng  = mm.getSpikePosForAng;

opt.NumPx = [41 27]; % Discretization for firing rate maps.
[gsVelVCO, SpikeRateVelVCO, gsAngVCO, SpikeRateAngVCO] ...
    = mm.calculateGridScores(opt);

mm.calculateGridCellFiringWithAttractorModel();

[gsVelAtt, SpikeRateVelAtt, gsAngAtt, SpikeRateAngAtt] ...
    = mm.calculateGridScores(opt);

toc

save('SimConfB', 'PosGt', 'PosEstByAng', 'PosEstByVel', ...
    'VelZGt', 'OmegaYGt', 'SpikePosForVel', 'SpikePosForAng',...
    'gsVelVCO', 'SpikeRateVelVCO', 'gsAngVCO', 'SpikeRateAngVCO',...
    'gsVelAtt', 'SpikeRateVelAtt', 'gsAngAtt', 'SpikeRateAngAtt');
