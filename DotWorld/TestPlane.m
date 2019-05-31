clc; clear all; close all; clear classes
% *************************************************************************
% Test the creation of a plane.
%
%   Copyright (C) 2015  Florian Raudies, 05/02/2015, Palo Alto, CA.
%   License, GNU GPL, free software, without any warranty.
% *************************************************************************

Normal      = [0; 1; 0; 0];
distance    = 5;
Interval    = [-3 -2 4 7];
Samples     = [5 3];
sampleType  = 'regular';
plane       = Plane(Normal, distance, Interval, Samples, sampleType);
P           = plane.getPoints();

plot3(P(:,3),P(:,1),P(:,2),'.k');
axis([-10 10 -10 10 -10 10]);
xlabel('z (cm)'); ylabel('x (cm)'); zlabel('y (cm)');
