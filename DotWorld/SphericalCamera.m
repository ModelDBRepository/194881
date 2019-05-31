classdef SphericalCamera < Camera
    % Spherical camera model.
    %
    %   Copyright (C) 2015  Florian Raudies, 05/02/2015, Palo Alto, CA.
    %   License, GNU GPL, free software, without any warranty.
    %
    properties (SetAccess = protected)
        Az2D        % Sampling of azimuth angle.
        El2D        % Sampling of elevation angle.
    end
    methods
        function obj = SphericalCamera(DirVector,UpVector,Pos,...
                hFov,vFov,nPxH,nPxV,hSigma,vSigma,t0,t1)
            obj             = obj@Camera('SphericalCamera');
            obj.DirVector   = DirVector;
            obj.UpVector    = UpVector;
            obj.Pos         = Pos;
            obj.hFov        = hFov;
            obj.vFov        = vFov;
            obj.nPxH        = nPxH;
            obj.nPxV        = nPxV;
            obj.hSigma      = hSigma;
            obj.vSigma      = vSigma;
            obj.t0          = t0;
            obj.t1          = t1;
            [obj.El2D obj.Az2D]	= ndgrid(linspace(-vFov/2,+vFov/2,nPxV),...
                                         linspace(-hFov/2,+hFov/2,nPxH));            
        end
        function V = getVisibility(obj,Points)
            Tv          = obj.viewpointTransform();
            Points      = Tv*Points';
            [Az, El, D] = cart2sph(Points(3,:),Points(1,:),Points(2,:));
            V           = (Az > -obj.hFov/2) & (Az < obj.hFov/2) ...
                        & (El > -obj.vFov/2) & (El < obj.vFov/2) ...
                        & (D > obj.t0) & (D < obj.t1);
        end
        function [X Y Z V] = getImagePoints(obj,Points)
            Tv          = obj.viewpointTransform();
            Points      = Tv*Points';
            [Az El D]   = cart2sph(Points(3,:),Points(1,:),Points(2,:));
            V           = (Az >= -obj.hFov/2-eps) & (Az <= obj.hFov/2+eps) ...
                        & (El >= -obj.vFov/2-eps) & (El <= obj.vFov/2+eps) ...
                        & (D >= obj.t0-eps) & (D <= obj.t1+eps);
            X = Az(V);
            Y = El(V);
            Z = D(V);
        end
        function I = raySplash(obj,Az,El)
            nPts = length(Az);
            El3D = repmat(shiftdim(obj.El2D,-1),[nPts 1 1]);
            Az3D = repmat(shiftdim(obj.Az2D,-1),[nPts 1 1]);
            I = mean(exp( -bsxfun(@minus,Az3D,Az(:)).^2/(2*obj.hSigma^2) ...
                          -bsxfun(@minus,El3D,El(:)).^2/(2*obj.vSigma^2)),1);
            I = squeeze(I)/max(I(:));
        end
    end
    methods (Static)
        function [Dh Dv] = imageFlow(H,V,D, Vel, Omega, ~)
            CosAz = cos(H);
            SinAz = sin(H);
            CosEl = cos(V);
            SinEl = sin(V);
            Dh = 1./(D+eps).*(-CosAz./CosEl * Vel(1) ...
                              +SinAz./CosEl * Vel(3)) ...
               + SinAz.*SinEl./CosEl        * Omega(1) ...
               - 1                          * Omega(2) ...
               + CosAz.*SinEl./CosEl        * Omega(3);
            Dv = 1./(D+eps).*(+SinAz.*SinEl * Vel(1) ...
                              -CosEl        * Vel(2) ...
                              +CosAz.*SinEl * Vel(3)) ...
               + CosAz                      * Omega(1) ...
               - SinAz                      * Omega(3);
        end
    end
end