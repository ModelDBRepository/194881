function Vel = estimateVelocity(DAzGrd,DElGrd, AzGrd,ElGrd,d)
% estimateVelocity
%   DAzGrd  - Angular velocity for the azimuth angle in RAD/sec.
%   DElGrd  - Angular velocity for the elevation angle in RAD/sec.
%   AzGrd   - Azimuth angle in RAD.
%   AlGrd   - Elevation angle in RAD.
%   d       - Distance of the camera from the ground-plane.
%
% RETURN
%   Vel     - Self-motion velocities, Vel = (vz, oy) with 
%             * vz - being the linear velocity along the optical axis and
%             * oy - being the rotational velocity around the y-axis (yaw).
%
% DESCRIPTION
%   This method assumes all sample points lie on a ground-plane, which
%   appears at the distance d of the camera, and the camera moves with a
%   linear velocity and a yaw-rotational velocity. All other degrees of
%   freedom are set to zero.
%
%   Copyright (C) 2015  Florian Raudies, 04/29/2015, Palo Alto, CA.
%   License, GNU GPL, free software, without any warranty.
%

% Compute the trigonometric functions of the input angles.
TanElGrd    = tan(ElGrd);
SinElGrd    = sin(ElGrd);
SinAzGrd    = sin(AzGrd);
CosAzGrd    = cos(AzGrd);

% Estimate the linear and rotational velocity in the ground-plane from
% optic flow.
a1  = + 1/d*mean(TanElGrd.^2.*SinAzGrd.^2+SinElGrd.^4.*CosAzGrd.^2);
a2  = - mean(TanElGrd.*SinAzGrd);
a3  = + 1/d*mean(TanElGrd.*SinAzGrd);
a4  = - 1;
b1  = mean(DAzGrd.*TanElGrd.*SinAzGrd+DElGrd.*SinElGrd.^2.*CosAzGrd);
b2  = mean(DAzGrd);
A   = [a1 a2; ...
       a3 a4];
Vel = A\[b1; b2];