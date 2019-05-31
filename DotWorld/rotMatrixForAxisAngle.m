function M = rotMatrixForAxisAngle(RotAxis,rotAngle)
% rotMatrixForAxisAngle
%   RotAxis     - 3D vector with the rotation axis.
%   rotAngle    - Scalar angle for rotation around the axis.
%
% RETURNS
%   M           - 4 x 4 rotation matrix.
%
% DESCRIPTION
%   Uses Rodrigues' rotation formula. More information see:
%   http://mathworld.wolfram.com/RodriguesRotationFormula.html.
%
%   Copyright (C) 2015  Florian Raudies, 05/02/2015, Palo Alto, CA.
%   License, GNU GPL, free software, without any warranty.
%

% Components of the rotation axis.
rx      = RotAxis(1);
ry      = RotAxis(2);
rz      = RotAxis(3);
% Cosine/sine of the rotation angle.
cAng    = cos(rotAngle);
sAng    = sin(rotAngle);
% Define the rotation matrix.
M = [cAng+rx^2*(1-cAng)     rx*ry*(1-cAng)-rz*sAng  ry*sAng+rx*rz*(1-cAng) 0; ...
     rz*sAng+rx*ry*(1-cAng) cAng+ry^2*(1-cAng)      -rx*sAng+ry*rz*(1-cAng) 0; ...
     -ry*sAng+rx*rz*(1-cAng) rx*sAng+ry*rz*(1-cAng)  cAng+rz^2*(1-cAng) 0; ...
     0 0 0 1];
