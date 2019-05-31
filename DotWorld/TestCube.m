clc; clear all; close all;
% *************************************************************************
% Test the creation of a cube as box, especially the functionlity for 
% resizing the cube that will enable the deletion of some points.
%
%   Copyright (C) 2015  Florian Raudies, 05/02/2015, Palo Alto, CA.
%   License, GNU GPL, free software, without any warranty.
% *************************************************************************
cube                = Cube([-50 -25 -50 50 25 50],[5 5 5],'regular');
P1                  = cube.getPoints();
[cube, DeleteIndex] = cube.resizeX([-20 20]);
P2                  = cube.getPoints();
Ground              = cube.getGroundSegment();

plot3(P1(:,3),P1(:,1),P1(:,2),'.k', ...
      P2(:,3),P2(:,1),P2(:,2),'or', ...
      P2(Ground,3),P2(Ground,1),P2(Ground,2),'xg');
xlabel('z (cm)'); ylabel('x (cm)'); zlabel('y (cm)');

