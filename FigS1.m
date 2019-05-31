clc; clear all; close all;
% *************************************************************************
% Fig S1 shows the compression for the grid cell firing patterns of the 
% static feautre system in configuration B compared to configuration A.
% In comparison to Fig 3, this figure shows the simulation results for the
% attractor model. To update the data run SimConfA.m and SimConfB.m.
%
%   Copyright (C) 2015  Florian Raudies, 05/02/2015, Palo Alto, CA.
%   License, GNU GPL, free software, without any warranty.
% *************************************************************************

ConfA       = load('SimConfA'); % Load the simulation data.
ConfB       = load('SimConfB');
LABEL_SIZE  = 16;               % Font size for the labels in points.
opt.scale   = 2/3;              % Scale factor for 100% compression.

figure('Position',[50 50 1200 900]);
subplot(2,3,1);
    imagesc(ConfA.SpikeRateVelAtt); axis equal tight off;
    title(sprintf('%s\n%s','Moving Feature System',...
        sprintf('Configuration A, GS %2.2f',ConfA.gsVelAtt)),...
        'FontSize',LABEL_SIZE);
subplot(2,3,2);
    imagesc(ConfB.SpikeRateVelAtt); axis equal tight off;
    title(sprintf('%s\n%s','Moving Feature System',...
        sprintf('Configuration B, GS %2.2f',ConfB.gsVelAtt)),...
        'FontSize',LABEL_SIZE);
subplot(2,3,3);
    [CorrCoeff Stretch] = rescaleCorr(...
        ConfA.SpikeRateVelAtt,ConfB.SpikeRateVelAtt,opt);
    Stretch = Stretch*100;
    [mv mi] = max(CorrCoeff);
    plot(Stretch,CorrCoeff,'.k',[Stretch(mi) Stretch(mi)],[0 mv],'-r',...
        'LineWidth',2.0);
    xlabel('Rescaling (%)','FontSize',LABEL_SIZE);
    ylabel('Correlation r2','FontSize',LABEL_SIZE);
    axis square; axis([Stretch(1) Stretch(end) 0 1]);
    set(gca,'FontSize',LABEL_SIZE);
    title('Moving Feature System','FontSize',LABEL_SIZE);
subplot(2,3,4);
    imagesc(ConfA.SpikeRateAngAtt); axis equal tight off;
    title(sprintf('%s\n%s','Static Feature System',...
        sprintf('Configuration A, GS %2.2f',ConfA.gsAngAtt)),...
        'FontSize',LABEL_SIZE);
subplot(2,3,5);
    imagesc(ConfB.SpikeRateAngAtt); axis equal tight off;
    title(sprintf('%s\n%s','Static Feature System',...
        sprintf('Configuration B, GS %2.2f',ConfB.gsAngAtt)),...
        'FontSize',LABEL_SIZE);
subplot(2,3,6);
    [CorrCoeff Stretch] = rescaleCorr(...
        ConfA.SpikeRateAngAtt,ConfB.SpikeRateAngAtt,opt);
    Stretch = Stretch*100;
    [mv mi] = max(CorrCoeff);
    plot(Stretch,CorrCoeff,'.k',[Stretch(mi) Stretch(mi)],[0 mv],'-r',...
        'LineWidth',2.0);
    xlabel('Rescaling (%)','FontSize',LABEL_SIZE);
    ylabel('Correlation r2','FontSize',LABEL_SIZE);
    axis square; axis([Stretch(1) Stretch(end) 0 1]);
    set(gca,'FontSize',LABEL_SIZE);
    title('Static Feature System','FontSize',LABEL_SIZE);
print('-depsc','FigS1');
