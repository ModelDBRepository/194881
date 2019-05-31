clc; clear all; close all; clear classes
% *************************************************************************
% Simulation of the module model for Gaussian noise without bias, which 
% takes about 4.5 hours.
%
%   Copyright (C) 2015  Florian Raudies, 09/29/2015, Palo Alto, CA.
%   License, GNU GPL, free software, without any warranty.
% *************************************************************************

muNoiseForVel       = 1/180*pi; % Set the noise parameters.
sigmaNoiseForVel    = 1.75/180*pi;
muNoiseForAng       = 0.8/180*pi;
sigmaNoiseForAng    = 1/180*pi;

addpath('./DotWorld/');
rng(4); % Set the seed value for the random number generator.
% Initialize the camera, cube box, and the module model.
nStep       = 5*10^4; % Number of steps to simulate.
nTrial      = 100;
camera      = SphericalCamera([0;0;1;0],[0;1;0;0],[0;0;0;0],...
                              360/180*pi,120/180*pi,0,0,0,0,5,10^4);
cube        = Cube([-75 -2.5 -75 75 47.5 75],[3 3 3]);
Ground      = cube.getGroundSegment();
configA     = Scene(cube, camera);
opt.nStep   = nStep;
opt.Ground  = Ground; % Logical index for ground samples.
mm          = ModuleModel(configA, opt); % Instantiate the module model.
mm.setGaussianNoiseAng(muNoiseForAng, sigmaNoiseForAng);
mm.setGaussianNoiseVel(muNoiseForVel, sigmaNoiseForVel);

ErrAngPerTrial      = zeros(nTrial,nStep);
ErrVelPerTrial      = zeros(nTrial,nStep);
ErrVelZPerTrial     = zeros(nTrial,nStep);
ErrOmegaYPerTrial   = zeros(nTrial,nStep);
SNRAngPerTrial      = zeros(nTrial,1);
SNRVelPerTrial      = zeros(nTrial,1);
dt = mm.getDeltaTime();

tic
for iTrial = 1:nTrial,
    fprintf('Working on %d-th trial of %d trials.\n',iTrial,nTrial);
    mm.simulate();
    ErrAngPerTrial(iTrial,:)    = mm.getEuclideanErrorForAng();
    ErrVelPerTrial(iTrial,:)    = mm.getEuclideanErrorForVel();
    ErrVelZPerTrial(iTrial,:)   = (mm.getVelZGt() - mm.getVelZEst())*dt;
    ErrOmegaYPerTrial(iTrial,:) = (mm.getOmegaYGt() - mm.getOmegaYEst())*dt;
    SNRAngPerTrial(iTrial)      = mm.getMeanSNRForAng();
    SNRVelPerTrial(iTrial)      = mm.getMeanSNRForVel();
end

rmpath('./DotWorld/');

opt.NumPx = [41 41]; % Discretization for firing rate maps.
[gsVelVCO, SpikeRateVelVCO, gsAngVCO, SpikeRateAngVCO] ...
    = mm.calculateGridScores(opt);

mm.calculateGridCellFiringWithAttractorModel();

[gsVelAtt, SpikeRateVelAtt, gsAngAtt, SpikeRateAngAtt] ...
    = mm.calculateGridScores(opt);

Time            = mm.getTime();
ErrAng          = mm.getEuclideanErrorForAng();
ErrVel          = mm.getEuclideanErrorForVel();
meanSNRForAng   = mm.getMeanSNRForAng();
meanSNRForVel   = mm.getMeanSNRForVel();
VelZGt          = mm.getVelZGt;
OmegaYGt        = mm.getOmegaYGt;
SpikePosForVel  = mm.getSpikePosForVel;
SpikePosForAng  = mm.getSpikePosForAng;

toc

save('SimNoiseWithBias', 'Time', 'ErrAngPerTrial', 'ErrVelPerTrial', ...
    'ErrVelZPerTrial', 'ErrOmegaYPerTrial', 'SNRAngPerTrial', ...
    'SNRVelPerTrial', 'dt', 'ErrAng', 'ErrVel', ...
    'muNoiseForVel', 'sigmaNoiseForVel', 'muNoiseForAng', 'sigmaNoiseForAng',...
    'meanSNRForAng', 'meanSNRForVel',...
    'VelZGt', 'OmegaYGt', 'SpikePosForVel', 'SpikePosForAng',...
    'gsVelVCO', 'SpikeRateVelVCO', 'gsAngVCO', 'SpikeRateAngVCO',...
    'gsVelAtt', 'SpikeRateVelAtt', 'gsAngAtt', 'SpikeRateAngAtt');
