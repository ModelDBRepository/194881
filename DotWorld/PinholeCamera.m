classdef PinholeCamera < Camera
    % Model for a pinhole camera.
    %
    %   Copyright (C) 2015  Florian Raudies, 05/02/2015, Palo Alto, CA.
    %   License, GNU GPL, free software, without any warranty.    
    properties (SetAccess = protected)
        X2D        % Sampling of horizontal dimension.
        Y2D        % Sampling of vertical dimension.
    end
    methods
        function obj = PinholeCamera(DirVector,UpVector,Pos,hFov,vFov,...
                nPxH,nPxV,hSigma,vSigma,t0,t1)
            obj             = obj@Camera('PinholeCamera');
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
            [obj.Y2D obj.X2D] = ndgrid(linspace(-1/2,+1/2,nPxV),...
                                       linspace(-1/2,+1/2,nPxH));
        end
        function T = perspectiveTransform(obj)
            n = obj.t0;            % near
            f = obj.t1;            % far
            l = -n * tan(obj.hFov/2);% left
            b = -n * tan(obj.vFov/2);% bottom
            r = -l;                 % right
            t = -b;                 % top
            T = [2*n/(r-l) 0 (l+r)/(l-r) 0; ...
                 0 2*n/(t-b) (b+t)/(b-t) 0; ...
                 0 0 (f+n)/(n-f) 2*f*n/(f-n); ...
                 0 0 1 0];
        end
        function V = getVisibility(obj,Points)
            Tv = obj.viewpointTransform();
            Tp = obj.perspectiveTransform();
            % Apply transforms for viewpoint and perspective.           
            Points = Tp*Tv*Points';
            % Homogeneous coordinates.
            Points = bsxfun(@rdivide, Points, eps+Points(4,:));
            % Check for visibility.
            V = (Points(1,:) > -1) & (Points(1,:) < +1) ...
              & (Points(2,:) > -1) & (Points(2,:) < +1) ...
              & (Points(3,:) > -1) & (Points(3,:) < +1);
        end        
        function [X Y Z V] = getImagePoints(obj,Points)
            Tv = obj.viewpointTransform();
            Tp = obj.perspectiveTransform();
            % Apply transforms for viewpoint and perspective.           
            Points = Tp*Tv*Points';
            % Homogeneous coordinates.
            Points = bsxfun(@rdivide, Points, eps+Points(4,:));
            % Check for visibility.
            V = (Points(1,:) > -1) & (Points(1,:) < +1) ...
              & (Points(2,:) > -1) & (Points(2,:) < +1) ...
              & (Points(3,:) > -1) & (Points(3,:) < +1);
            Points = Points(1:3,V);
            % Perspective projection
            X = obj.fLength*Points(1,:)./(eps+Points(3,:));
            Y = -obj.fLength*Points(2,:)./(eps+Points(3,:));
            Z = ones(1,size(Points,2));
        end
        function I = raySplash(obj,X,Y)
            nPts = length(X);
            X3D = repmat(shiftdim(obj.X2D,-1),[nPts 1 1]);
            Y3D = repmat(shiftdim(obj.Y2D,-1),[nPts 1 1]);
            I = mean(exp( -bsxfun(@minus,X3D,X(:)).^2/(2*obj.hSigma^2) ...
                          -bsxfun(@minus,Y3D,Y(:)).^2/(2*obj.vSigma^2)),1);
            I = squeeze(I)/max(I(:));
        end
    end
    methods (Static)
        function [Dh Dv] = imageFlow(H,V,D, Vel, Omega, f)
            Dh = 1./(D+eps).*(- f   * Vel(1) ...
                              + H   * Vel(3)) ...
               + 1/f*(+ H.V         * Omega(1) ...
                      - (f^2+H.^2)  * Omega(2) ...
                      + f*V         * Omega(3));
                      
            Dv = 1./(D+eps).*(- f   * Vel(2) ...
                              + V   * Vel(3)) ...
               + 1/f*(+ (f^2+V.^2)  * Omega(1) ...
                      - H.*V        * Omega(2) ...
                      - f*H         * Omega(3));
        end
    end
end