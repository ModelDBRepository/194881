clc; clear all; close all;
% *************************************************************************
%   Test script for triangulation using the regularization constraint.
%
%   Copyright (C) 2015  Florian Raudies, 05/02/2015, Palo Alto, CA.
%   License, GNU GPL, free software, without any warranty.
% *************************************************************************

rng(3);                 % Set seed for random number generator.
P0      = [-49 40]';    % Initial position of the rat.
nPoints = 10;           % Number of points on walls.
w       = 150;          % Width of the box.
l       = 150;          % Height of the box.

% Define the points on the walls.
P   = [linspace(-w/2,w/2,nPoints) linspace(-w/2,w/2,nPoints) ...
            repmat(-w/2,[1 nPoints]) repmat(w/2,[1 nPoints]); ...
       repmat(-l/2,[1 nPoints]),   repmat(l/2,[1 nPoints]),    ...
            linspace(-l/2,l/2,nPoints), linspace(-l/2,l/2,nPoints)];
        
% To alter the configuration to length l2 we define several indices. 
l2          = 100;
Invisible   = ( (P(2,:) >= +l2/2) | (P(2,:) <= -l2/2)) ...
            & ( abs(P(1,:)-w/2) < eps('single') ...
              | abs(P(1,:)+w/2) < eps('single') );
Top         = abs(P(2,:)-l/2)   < eps('single');
Bottom      = abs(P(2,:)+l/2)   < eps('single');

% Make the change to define configuration B.
P2              = P;
P2(2,Top)       = P2(2,Top)     - 25;
P2(2,Bottom)    = P2(2,Bottom)  + 25;
P2(:,Invisible) = [];

% Ovserve the visual angles based on the altered configuration.
Th  = wrapTo2Pi(atan2(P2(2,:)-P0(2), P2(1,:)-P0(1)));

% Adjust the memorized locations from the prior configuration.
P(:,Invisible) = [];

opt.w       = w;
opt.l       = l;
opt.alpha   = 10^-2;
S           = estimatePosition(Th, P(1,:),P(2,:), opt);

LABEL_SIZE = 16;

figure('Position',[50 50 800 400]);
plot(P(1,:),P(2,:),'.k',P2(1,:),P2(2,:),'or',P0(1),P0(2),'ob',S(1),S(2),'+r');
axis equal; axis([-80 80 -80 80]);
xlabel('X Position (cm)','FontSize',LABEL_SIZE);
ylabel('Y Position (cm)','FontSize',LABEL_SIZE);
set(gca,'FontSize',LABEL_SIZE);
legend('Configuration A', 'Configuration B', 'Ground-truth', 'Estimate',...
    'Location','EastOutside');
