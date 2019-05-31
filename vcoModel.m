function [SpikePos SpikeTime] = vcoModel(Time, PosGt, PosEst, opt)
% vcoModel -- Velocity Controlled Oscillator (VCO)
%   Time    - Time in sec.
%   Pos     - Postion as matrix with dimensions (sampleNum x 2) and values 
%             in cm.
%   Vel     - Linear velocity in cm/sec.
%   opt     - Structure with fields:
%             * f       - frequency in Hz.
%             * beta    - model paramter in sec/cm (inverse velocity).
%             * Phi     - Angles for basis vectors.
%             * theta   - Threshold value for spike.
%
% RETURN
%   SpikePos    - Position of spike.
%   SpikeTime   - Time of spike.
%
%   Copyright (C) 2015  Florian Raudies, 04/29/2015, Palo Alto, CA.
%   License, GNU GPL, free software, without any warranty.

if isfield(opt, 'f'),       f       = opt.f;     
else                        f       = 7.38; end % Hz
if isfield(opt, 'beta'),    beta    = opt.beta;  
else                        beta    = 0.00385; end % 1/(cm*Hz)
if isfield(opt, 'Phi'),     Phi     = opt.Phi;   
else                        Phi     = 2*pi*[0 1/3 2/3]';end
if isfield(opt, 'theta'),   theta   = opt.theta; 
else                        theta   = 1.8; end
if isfield(opt, 'phi0'),    phi0    = opt.phi0;  
else                        phi0    = 0; end

% Define basis system.
Base    = [cos(Phi) sin(Phi)];
omega   = 2*pi*f; % Angular frequency.
T       = repmat(Time,[1 3]);

% Define phase relationship for arbitrary phase phi0.
Phi0    = (Base*[cos(phi0) sin(phi0)]')';
Phi0    = repmat(Phi0,[size(Time,1) 1]);

% Compute spike times using the velocity controlled oscillator model.
Spike   = prod(cos(omega*T) ...
        + cos(omega*T + Phi0 + omega*beta*PosEst*Base'),2)>theta;

% Pick the corresponding position of a spike.
SpikePos    = PosGt(Spike,:);
SpikeTime   = Time(Spike);
