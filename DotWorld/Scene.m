classdef Scene < handle
    % Class 'Scene' holds information about one camera and 3D points that
    % describe the world. These 3D points are added through the method
    % addObject.
    % All objects in the scene are described through non-connected points.
    %
    %   Copyright (C) 2015  Florian Raudies, 05/02/2015, Palo Alto, CA.
    %   License, GNU GPL, free software, without any warranty.
    properties (Constant = true)
        N_MAX_POINTS    = 10^4  % Maximum number of points.
        N_MAX_OBJECTS   = 10^2  % Maximum number of objects.
    end
    properties (SetAccess = private)
        Points      % nPoints x 4 matrix
        %objToPoints % Object to points mapping. For removal of objects.
        nPoints     % Number of points.
        nObjects    % Number of objects.
    end
    properties
        camera  % Camera for image coordinates.
        objects % Holds a list of objects.
    end
    methods
        % Constructor
        function obj = Scene(object, camera)
            obj.Points      = zeros(Scene.N_MAX_POINTS,4);
            obj.objects     = cell(Scene.N_MAX_OBJECTS,1);
            obj.nPoints     = 0;
            obj.nObjects    = 0;
            
            if nargin >= 1, obj.addObject(object);  end
            if nargin >= 2, obj.setCamera(camera);  end
        end
        % Adds object to the scene which is represented by 3D points / 
        % 4D points in homogenous coordinates.
        function obj = addObject(obj, object)
            P                               = object.getPoints();
            Index                           = obj.nPoints + 1:size(P,1);
            obj.nObjects                    = obj.nObjects + 1;
            obj.nPoints                     = obj.nPoints + length(Index);
            obj.Points(Index,:)             = P;
            obj.objects{obj.nObjects}       = object;
        end
        function o = getObject(obj,index)
            if nargin < 2, index = 1; end
            o = obj.objects{index};
        end
        % Set the camera for the scene.
        function setCamera(obj,cam)
            obj.camera = cam;
        end
        % Move the camera to the position 'Pos'.
        function moveCameraTo(obj,Pos)
            obj.camera.moveTo(Pos);
        end
        % Orient the camera according to the 'DirVector' and 'UpVector'.
        function orientCamera(obj,DirVector,UpVector)
            obj.camera.orient(DirVector,UpVector);
        end
        % Rotate the camera.
        % If you decide to use this method incrementially the error
        % accumulates. Rather specify the orientation of the camera for
        % each step and use the method orientCamera.
        function rotateCamera(obj,Rotation)
            obj.camera.rotate(Rotation);
        end
        % Get all points of this scene.
        function P = getPoints(obj)
            P = obj.Points(1:obj.nPoints,:);
        end
        % Get a binary vector with a one-entry for the visible point and a
        % zero-entry for a non-visible point (e.g. out of the field of
        % view).
        function V = getVisibility(obj)
            V = obj.camera.getVisibility(obj.getPoints());            
        end
        % Get points projected into the image manifold (not necessarily a
        % plane).
        function [X Y Z V] = getImagePoints(obj)
            [X Y Z V] = obj.camera.getImagePoints(obj.getPoints());
        end
        function P = getAllImagePoints(obj)
            Tv = obj.camera.viewpointTransform();
            P  = Tv*obj.getPoints()';      
        end        
        % raySplash generates an image.
        function I = raySplash(obj, Pos,Dir,Up)
            obj.moveCameraTo(Pos);
            obj.orientCamera(Dir,Up);
            [Az, El, ~] = obj.getImagePoints();
            I = obj.camera.raySplash(Az,El);
        end
        % Get camera object.
        function c = getCamera(obj)
            c = obj.camera;
        end
    end
end