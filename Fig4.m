clc; clear all; close all;
% *************************************************************************
% Fig 4 shows the error of position estimates and grid score pattern under
% the influence of bias-free and biased Gaussian noise.
% To reprodcue you need to run SimNoiseWoutBias.m and SimNoiseWithBias.m, 
% that produce the data required to reproduce this figure.
%
%   Copyright (C) 2015  Florian Raudies, 09/29/2015, Palo Alto, CA.
%   License, GNU GPL, free software, without any warranty.
% *************************************************************************

WoutBias    = load('SimNoiseWoutBias'); % Load the simulation data.
WithBias    = load('SimNoiseWithBias');
LABEL_SIZE  = 10;                       % Label size in points.

WoutBias.MeanErrVel = squeeze(mean(WoutBias.ErrVelPerTrial,1));
WoutBias.MeanErrAng = squeeze(mean(WoutBias.ErrAngPerTrial,1));
WoutBias.StdErrVel  = squeeze(std(WoutBias.ErrVelPerTrial,0,1));
WoutBias.StdErrAng  = squeeze(std(WoutBias.ErrAngPerTrial,0,1));

WoutBias.sigmaVz    = mean( std(WoutBias.ErrVelZPerTrial,0,2),1);
WoutBias.sigmaOy    = mean( std(WoutBias.ErrOmegaYPerTrial,0,2),1);
WoutBias.muVz       = mean( mean(WoutBias.ErrVelZPerTrial,2),1);
WoutBias.muOy       = mean( mean(WoutBias.ErrOmegaYPerTrial,2),1);
dt                  = WoutBias.dt;
Time                = WoutBias.Time;
fprintf('sigma v no bias = %e cm.\n',WoutBias.sigmaVz);
fprintf('sigma o no bias = %e deg.\n',WoutBias.sigmaOy*180/pi);
fprintf('mu v no bias = %e cm.\n',WoutBias.muVz);
fprintf('mu o no bias = %e deg.\n',WoutBias.muOy*180/pi);

WoutBias.MeanErrAccuVelZ    = mean(cumsum(WoutBias.ErrVelZPerTrial,2).^2,1);
WoutBias.MeanErrAccuOmegaY  = mean(cumsum(WoutBias.ErrOmegaYPerTrial,2).^2,1);
WoutBias.ModelErrAccuVelZ   = Time/dt.*(WoutBias.sigmaVz^2+Time/dt*WoutBias.muVz^2);
WoutBias.ModelErrAccuOmegaY = Time/dt.*(WoutBias.sigmaOy^2+Time/dt*WoutBias.muOy^2);

figure('Position',[50 50 900 400]);
subplot(1,4,1);
    plot(Time,WoutBias.MeanErrAccuVelZ,'-b',...
         Time,WoutBias.ModelErrAccuVelZ,'-k','LineWidth',1.0);
    axis square; axis([0 2500 0 120]);
    xlabel('Time (sec)','FontSize',LABEL_SIZE);
    ylabel(sprintf('Mean Squared Error of\nAccumuated Linear Velocity (cm^2)'),...
        'FontSize',LABEL_SIZE);
    title('Linear Velocity','FontSize',LABEL_SIZE);
    set(gca,'FontSize',LABEL_SIZE);
subplot(1,4,2);
    plot(Time,WoutBias.MeanErrAccuOmegaY*(180/pi)^2,'-b',...
         Time,WoutBias.ModelErrAccuOmegaY*(180/pi)^2,'-k','LineWidth',1.0);
    axis square; axis([0 2500 0 100]);
    xlabel('Time (sec)','FontSize',LABEL_SIZE);
    ylabel(sprintf('Mean Squared Error of\nAccumulated Rotational Velocity (deg^2)'),...
        'FontSize',LABEL_SIZE);
    title('Rotational Velocity','FontSize',LABEL_SIZE);
    set(gca,'FontSize',LABEL_SIZE);
    
WithBias.MeanErrVel = squeeze(mean(WithBias.ErrVelPerTrial,1));
WithBias.MeanErrAng = squeeze(mean(WithBias.ErrAngPerTrial,1));
WithBias.StdErrVel  = squeeze(std(WithBias.ErrVelPerTrial,0,1));
WithBias.StdErrAng  = squeeze(std(WithBias.ErrAngPerTrial,0,1));

WithBias.sigmaVz    = mean( std(WithBias.ErrVelZPerTrial,0,2),1);
WithBias.sigmaOy    = mean( std(WithBias.ErrOmegaYPerTrial,0,2),1);
WithBias.muVz       = mean( mean(WithBias.ErrVelZPerTrial,2),1);
WithBias.muOy       = mean( mean(WithBias.ErrOmegaYPerTrial,2),1);
dt                  = WithBias.dt;
Time                = WithBias.Time;
fprintf('sigma v with bias = %e cm.\n',WithBias.sigmaVz);
fprintf('sigma o with bias = %e deg.\n',WithBias.sigmaOy*180/pi);
fprintf('mu v with bias = %e cm.\n',WithBias.muVz);
fprintf('mu o with bias = %e deg.\n',WithBias.muOy*180/pi);

WithBias.MeanErrAccuVelZ    = mean(cumsum(WithBias.ErrVelZPerTrial,2).^2,1);
WithBias.MeanErrAccuOmegaY  = mean(cumsum(WithBias.ErrOmegaYPerTrial,2).^2,1);
WithBias.ModelErrAccuVelZ   = Time/dt.*(WithBias.sigmaVz^2+Time/dt*WithBias.muVz^2);
WithBias.ModelErrAccuOmegaY = Time/dt.*(WithBias.sigmaOy^2+Time/dt*WithBias.muOy^2);

subplot(1,4,3);
    plot(Time,WithBias.MeanErrAccuVelZ,'-b',...
         Time,WithBias.ModelErrAccuVelZ,'-k','LineWidth',1.0);
    axis square; axis([0 2500 0 120]);
    xlabel('Time (sec)','FontSize',LABEL_SIZE);
    ylabel(sprintf('Mean Squared Error of\nAccumuated Linear Velocity (cm^2)'),...
        'FontSize',LABEL_SIZE);
    title('Linear Velocity','FontSize',LABEL_SIZE);
    set(gca,'FontSize',LABEL_SIZE);
subplot(1,4,4);
    plot(Time,WithBias.MeanErrAccuOmegaY*(180/pi)^2,'-b',...
         Time,WithBias.ModelErrAccuOmegaY*(180/pi)^2,'-k','LineWidth',1.0);
    axis square; axis([0 2500 0 10^7]);
    xlabel('Time (sec)','FontSize',LABEL_SIZE);
    ylabel(sprintf('Mean Squared Error of\nAccumulated Rotational Velocity (deg^2)'),...
        'FontSize',LABEL_SIZE);
    title('Rotational Velocity','FontSize',LABEL_SIZE);
    set(gca,'FontSize',LABEL_SIZE);
print('-depsc','Fig4Row1');

% Mean/STD of distance between ground-truth and estimated location.
    
Index = 1 : ceil(200/dt);
figure('Position',[50 50 900 400]);
subplot(1,4,1); 
    errorarea(WoutBias.Time(Index),...
              WoutBias.MeanErrVel(Index),...
              WoutBias.StdErrVel(Index),[.7 .7 .7],'k');
    axis square; axis([WoutBias.Time(1) 200 0 220]);
    set(gca,'FontSize',LABEL_SIZE);
    xlabel('Time (sec)','FontSize',LABEL_SIZE);
    ylabel('Euclidean Error (cm)','FontSize',LABEL_SIZE);
    title(sprintf('%s\n%s','Moving Feature System',...
        sprintf('SNR %2.2f dB', WoutBias.meanSNRForVel)));
subplot(1,4,2);
    errorarea(WoutBias.Time(Index),...
              WoutBias.MeanErrAng(Index),...
              WoutBias.StdErrAng(Index),[.7 .7 .7],'k');
    axis square; axis([WoutBias.Time(1) 200 0 220]);
    set(gca,'FontSize',LABEL_SIZE);
    xlabel('Time (sec)','FontSize',LABEL_SIZE);
    ylabel('Euclidean Error (cm)','FontSize',LABEL_SIZE);
    title(sprintf('%s\n%s','Static Feature System',...
        sprintf('SNR %2.2f dB', WoutBias.meanSNRForAng)));
subplot(1,4,3); 
    errorarea(WithBias.Time(Index),...
              WithBias.MeanErrVel(Index),...
              WithBias.StdErrVel(Index),[.7 .7 .7],'k');
    axis square; axis([WithBias.Time(1) 200 0 220]);
    set(gca,'FontSize',LABEL_SIZE);
    xlabel('Time (sec)','FontSize',LABEL_SIZE);
    ylabel('Euclidean Error (cm)','FontSize',LABEL_SIZE);
    title(sprintf('%s\n%s','Moving Feature System',...
        sprintf('SNR %2.2f dB', WithBias.meanSNRForVel)));
subplot(1,4,4);
    errorarea(WithBias.Time(Index),...
              WithBias.MeanErrAng(Index),...
              WithBias.StdErrAng(Index),[.7 .7 .7],'k');
    axis square; axis([WithBias.Time(1) 200 0 220]);
    set(gca,'FontSize',LABEL_SIZE);
    xlabel('Time (sec)','FontSize',LABEL_SIZE);
    ylabel('Euclidean Error (cm)','FontSize',LABEL_SIZE);
    title(sprintf('%s\n%s','Static Feature System',...
        sprintf('SNR %2.2f dB', WithBias.meanSNRForAng)));
print('-deps','Fig4Row2');
    
% *************************************************************************
% Single last trail.
% *************************************************************************

figure('Position',[50 50 900 400]);
subplot(1,4,1);
    plot(WoutBias.Time,WoutBias.ErrVel,'-k','LineWidth',1.0);
    axis square; axis([WoutBias.Time(1) 200 0 220]);
    set(gca,'FontSize',LABEL_SIZE);
    xlabel('Time (sec)','FontSize',LABEL_SIZE);
    ylabel('Euclidean Error (cm)','FontSize',LABEL_SIZE);
subplot(1,4,2);
    plot(WoutBias.Time,WoutBias.ErrAng,'k','LineWidth',1.0);
    axis square; axis([WoutBias.Time(1) 200 0 220]);
    set(gca,'FontSize',LABEL_SIZE);
    xlabel('Time (sec)','FontSize',LABEL_SIZE);
    ylabel('Euclidean Error (cm)','FontSize',LABEL_SIZE);
subplot(1,4,3);
    plot(WithBias.Time,WithBias.ErrVel,'k','LineWidth',1.0);
    axis square; axis([WithBias.Time(1) 200 0 220]);
    set(gca,'FontSize',LABEL_SIZE);
    xlabel('Time (sec)','FontSize',LABEL_SIZE);
    ylabel('Euclidean Error (cm)','FontSize',LABEL_SIZE);
subplot(1,4,4);
    plot(WithBias.Time,WithBias.ErrAng,'k','LineWidth',1.0);
    axis square; axis([WithBias.Time(1) 200 0 220]);
    set(gca,'FontSize',LABEL_SIZE);
    xlabel('Time (sec)','FontSize',LABEL_SIZE);
    ylabel('Euclidean Error (cm)','FontSize',LABEL_SIZE);
print('-depsc','Fig4Row3');


    
figure('Position',[50 50 900 400]);
subplot(1,4,1);
    imagesc(WoutBias.SpikeRateVelVCO); axis xy equal tight off;
    title(sprintf('%s\n%s\n%s\n%s','Moving Feature System',...
        sprintf('GS %2.2f',WoutBias.gsVelVCO), ...
        sprintf('mu %2.2f deg/sec', WoutBias.muNoiseForVel*180/pi),...
        sprintf('sigma %2.2f deg/sec', WoutBias.sigmaNoiseForVel*180/pi)),...
            'FontSize',LABEL_SIZE);
subplot(1,4,2);
    imagesc(WoutBias.SpikeRateAngVCO); axis xy equal tight off;
    title(sprintf('%s\n%s\n%s\n%s','Static Feature System',...
        sprintf('GS %2.2f',WoutBias.gsAngVCO), ...
        sprintf('mu %2.2f deg', WoutBias.muNoiseForAng*180/pi),...
        sprintf('sigma %2.2f deg', WoutBias.sigmaNoiseForAng*180/pi)),...
            'FontSize',LABEL_SIZE);
subplot(1,4,3);
    imagesc(WithBias.SpikeRateVelVCO); axis xy equal tight off;
    title(sprintf('%s\n%s\n%s\n%s','Moving Feature System',...
        sprintf('GS %2.2f',WithBias.gsVelVCO), ...
        sprintf('mu %2.2f deg/sec', WithBias.muNoiseForVel*180/pi),...
        sprintf('sigma %2.2f deg/sec', WithBias.sigmaNoiseForVel*180/pi)),...
            'FontSize',LABEL_SIZE);
subplot(1,4,4);
    imagesc(WithBias.SpikeRateAngVCO); axis xy equal tight off;
    title(sprintf('%s\n%s\n%s\n%s','Static Feature System',...
        sprintf('GS %2.2f',WithBias.gsAngVCO), ...
        sprintf('mu %2.2f deg', WithBias.muNoiseForAng*180/pi),...
        sprintf('sigma %2.2f deg', WithBias.sigmaNoiseForAng*180/pi)),...
            'FontSize',LABEL_SIZE);
print('-depsc','Fig4Row4');
