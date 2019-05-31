clc; clear all; close all; clear classes
% *************************************************************************
% Test the creation of a box and views of the spherical camera orbiting 
% around (0,0) on a circular trajectory.
%
%   Copyright (C) 2015  Florian Raudies, 05/02/2015, Palo Alto, CA.
%   License, GNU GPL, free software, without any warranty.
% *************************************************************************

% Define trajectory
nStep   = 45; % Number of steps.
r       = 25; % Radius.
Angle   = 2*pi*linspace(0,1,nStep);
Pos = [+r*cos(Angle);  zeros([1,nStep]); +r*sin(Angle);  zeros(1,nStep)];
Dir = [-sin(Angle);    zeros(1,nStep);   +cos(Angle);    zeros(1,nStep)];
Up  = [zeros(1,nStep); ones(1,nStep);    zeros(1,nStep); zeros(1,nStep)];

% Define scene
scene = Scene();
scene.addObject(Cube([-50 -25 -50 50 25 50],[15 15 15]));
scene.setCamera(SphericalCamera([0;0;1;0],[0;1;0;0],[0;0;0;0],...
    2/3*pi,3/4*pi,0,0,0,0,5,10^3));
P = scene.getPoints()';

% Simulate the movement
for iStep = 1:nStep,
    scene.orientCamera(Dir(:,iStep),Up(:,iStep));
    scene.moveCameraTo(Pos(:,iStep));
    [Az El D V] = scene.getImagePoints();    
    
    cla; 
    subplot(1,2,1);
        quiver3(Pos(3,iStep),Pos(1,iStep),Pos(2,iStep),...
                Dir(3,iStep),Dir(1,iStep),Dir(2,iStep),10); hold on;
        plot3(P(3,~V),P(1,~V),P(2,~V),'.g',P(3,V),P(1,V),P(2,V),'.b'); hold off;
        view(0,90); axis equal tight; title('Top view');
    subplot(1,2,2);
        plot(Az*180/pi,El*180/pi,'.k');
        axis equal; axis([-1/3*pi 1/3*pi -3/8*pi 3/8*pi]*180/pi); title('Image');
    drawnow;
end
