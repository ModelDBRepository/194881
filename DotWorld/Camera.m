classdef Camera < handle
    % Class 'Camera' holds the position, orientation (Dir,Up), the field of
    % view, and range of visibility. This is an abstract class.
    %
    %   Copyright (C) 2015  Florian Raudies, 05/02/2015, Palo Alto, CA.
    %   License, GNU GPL, free software, without any warranty.
    %
    properties (SetAccess = protected)
        name        % Name for the camera.
        Pos         % 4D position vector (column vector)
        DirVector   % Direction vector
        UpVector    % Up vector
        hFov        % Horizontal field of view in RAD
        vFov        % Vertical field of view in RAD
        hSigma      % Standard deviation for azimuth angle of 'splash'.
        vSigma      % Standard deviation for elevation angle of 'splash'.
        nPxH        % Number of pixels in horizontal direction.
        nPxV        % Number of pixels in vertical direction.
        t0          % Mininum distance of viewing frustum
        t1          % Maximum distance of viewing frustum
        fLength     % Focal length
    end
    methods
        % Constructor.
        function obj = Camera(name)
            obj.name        = name;
            obj.Pos         = [0; 0; 0; 0];
            obj.DirVector   = [0; 0; 1; 0];
            obj.UpVector    = [0; 1; 0; 0];
            obj.hFov        = 120/180*pi;
            obj.vFov        = 100/180*pi;
            obj.t0          = 0;
            obj.t1          = 10^4;
            obj.fLength     = 1;
        end
        % Get the horizontal standard deviation for the 'splash' in the 
        % image plane.
        function s = getHorizontalSigma(obj)
            s = obj.hSigma;
        end
        % Get the vertical standard deviation for the 'splash' in the image
        % plane.
        function s = getVerticalSigma(obj)
            s = obj.vSigma;
        end        
        % Get the position of the camera.
        function P = getPosition(obj)
            P = obj.Pos;
        end
        
        function r = getAspectRatio(obj)
            r = obj.vFov / obj.hFov;
        end
        % Get the direction-vector, a 4D row-vector.
        function D = getDirVector(obj)
            D = obj.DirVector;
        end
        % Get the up-vector, a 4D row-vector.
        function U = getUpVector(obj)
            U = obj.UpVector;
        end
        % Move the camera to the position 'Pos'.
        function moveTo(obj,Pos)
            obj.Pos = Pos;
        end
        % Rotate the camera from the current orientation by the rotation
        % angles in 'Rotation'.
        function rotate(obj, Rotation)
            M               = rotMatrixForAngles(Rotation);
            obj.DirVector   = M*obj.DirVector;
            obj.UpVector    = M*obj.UpVector;
        end
        % Orient the camera using the direction-vector and up-vector both
        % are 4D row-vectors.
        function orient(obj, DirVector,UpVector)
            obj.DirVector   = DirVector;
            obj.UpVector    = UpVector;
        end
        % Gives a 4 x 4 transformation matrix which transforms points into 
        % the coordinate sytem of the camera using the orientation and 
        % position of the camera.
        function T = viewpointTransform(obj)
            % Get the position and orientation of the camera.
            DirVec      = obj.getDirVector()';
            UpVec       = obj.getUpVector()';
            RightVec    = [cross(DirVec(1:3),UpVec(1:3)),0];
            UpVec       = [cross(RightVec(1:3),DirVec(1:3)),0];           
            % Construct matrix for viewpoint transformation
            T = [RightVec(1:3) -RightVec*obj.Pos; ...
                 UpVec(1:3)    -UpVec*obj.Pos; ...
                 DirVec(1:3)   -DirVec*obj.Pos;
                 0 0 0         +1];
        end
        function n = getNumberOfPixels(obj)
            n = obj.nPxV * obj.nPxH;
        end
    end
    methods (Abstract)
        % Get the point 'Points' transformed into image space.
        [X Y Z V] = getImagePoints(obj, Points)
        % Get the visibility for each of the points 'Points'.
        V = getVisibility(obj, Points)
        % Get image using a superposition of Gaussian blobs.
        I = raySplash(obj)
    end
    methods (Abstract, Static)
        % Get the image flow for the points according to the camera 
        % position and orientation.
        [Dh Dv] = imageFlow(H,V, D, Vel, Omega, f)
    end
end