classdef Object < handle
    % Class 'Object' holds the point 4D homonogenous coordinates of points. 
    %
    %   Copyright (C) 2015  Florian Raudies, 05/02/2015, Palo Alto, CA.
    %   License, GNU GPL, free software, without any warranty.
    %
    properties (Constant = true)
        N_MAX_POINTS    = 10^3  % Maximum number of points.
        N_MAX_OBJECTS   = 10^2  % Maximum number of objects.
    end    
    properties (Access = protected)
        Points      % Matrix with dimensions: nPoints x 4.
        objToPoints % Object to points mapping. For removal of objects.
        nPoints     % Number of points.
        nObjects    % Number of sub-objects that form this object.
        Interval    % Interval for object, typically a bounding box.
    end
    methods
        % Constructor
        function obj = Object()
            obj.Points      = zeros(Object.N_MAX_POINTS,4);
            obj.objToPoints = zeros(Object.N_MAX_OBJECTS,2); % start,end
            obj.nPoints     = 0;
            obj.nObjects    = 0;
        end
        % Get the points.
        function Points = getPoints(obj)
            Points = obj.Points(1:obj.nPoints,:);
        end
        function Interval = getInterval(obj)
            Interval = obj.Interval;
        end
        % Add an object to this object to form a joined object.
        function addObject(obj,object)
            P = object.getPoints();
            Index = obj.nPoints + (1:size(P,1));
            obj.Points(Index,:) = P;
            obj.nPoints = obj.nPoints + size(P,1);
            obj.nObjects = obj.nObjects + 1;
            obj.objToPoints(obj.nObjects,:) = [Index(1) Index(end)];
        end
        function Index = getObjectToPoint(obj)
            Index = obj.objToPoints(1:obj.nObjects,:);
        end
    end
    methods (Abstract)
        M = getMesh(obj);
    end
end