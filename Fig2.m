clc; clear all; close all;
% *************************************************************************
% Fig 2 shows the compression for the position estimates of the static
% feautre system in configuration B compared to configuration A.
% To update the data run SimConfA.m and SimConfB.m.
%
%   Copyright (C) 2015  Florian Raudies, 05/02/2015, Palo Alto, CA.
%   License, GNU GPL, free software, without any warranty.
% *************************************************************************

ConfA       = load('SimConfA'); % Load the simulation data.
ConfB       = load('SimConfB');
LABEL_SIZE  = 16;               % Font size for the labels in points.

figure('Position',[50 50 1000 800],'PaperPosition',[2 2 10 8]);
subplot(2,2,1); 
    plot(ConfA.PosEstByAng(:,1),ConfA.PosEstByAng(:,2),'-k'); 
    axis equal; axis([-75 75 -75 75]);
    xlabel('Horizontal Position (cm)','FontSize',LABEL_SIZE);
    ylabel('Vertical Position (cm)','FontSize',LABEL_SIZE);
    title(sprintf('%s\n%s','Moving Feature System','Configuration A'),...
          'FontSize',LABEL_SIZE);
    set(gca,'FontSize',LABEL_SIZE);
subplot(2,2,3);
    plot(ConfA.PosEstByVel(:,1),ConfA.PosEstByVel(:,2),'-k'); 
    axis equal; axis([-75 75 -75 75]);
    xlabel('Horizontal Position (cm)','FontSize',LABEL_SIZE);
    ylabel('Vertical Position (cm)','FontSize',LABEL_SIZE);
    title(sprintf('%s\n%s','Static Feature System','Configuration A'),...
        'FontSize',LABEL_SIZE);
    set(gca,'FontSize',LABEL_SIZE);
subplot(2,2,2); 
    plot(ConfB.PosEstByAng(:,1),ConfB.PosEstByAng(:,2),'-k'); 
    axis equal; axis([-75 75 -75 75]);
    xlabel('Horizontal Position (cm)','FontSize',LABEL_SIZE);
    ylabel('Vertical Position (cm)','FontSize',LABEL_SIZE);
    title(sprintf('%s\n%s','Moving Feature System','Configuration B'),...
        'FontSize',LABEL_SIZE);
    set(gca,'FontSize',LABEL_SIZE);
subplot(2,2,4);
    plot(ConfB.PosEstByVel(:,1),ConfB.PosEstByVel(:,2),'-k'); 
    axis equal; axis([-75 75 -75 75]);
    xlabel('Horizontal Position (cm)','FontSize',LABEL_SIZE);
    ylabel('Vertical Position (cm)','FontSize',LABEL_SIZE);
    title(sprintf('%s\n%s','Static Feature System','Configuration B'),...
        'FontSize',LABEL_SIZE);
    set(gca,'FontSize',LABEL_SIZE);
print('-depsc','Fig2');
