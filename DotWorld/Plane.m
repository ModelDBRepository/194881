classdef Plane < Object
    % Class 'Plane' defines a plane through the sampling of points in a
    % plane within the specified interval using the specified number of
    % samples in each dimension of the plane.
    %
    %   Copyright (C) 2015  Florian Raudies, 05/02/2015, Palo Alto, CA.
    %   License, GNU GPL, free software, without any warranty.
    %
    methods
        % Constructor for the plane with the normal vector [nx;ny;nz;0] and
        % the Interval = [uMin vMin uMax vMax] -- where u,v are the
        % coordinates of the plane -- and Samples = [nU nV].
        function obj = Plane(Normal, distance, Interval, Samples, sampleType)            
            obj = obj@Object();
            obj.Interval = Interval;
            if strcmp(sampleType,'random'),
                dy      = 1/Samples(2);
                dx      = 1/Samples(1);
                [Y X]   = ndgrid(+linspace(0,1-dy,Samples(2)),...
                                 +linspace(0,1-dx,Samples(1)));
                Y       = Y + dy*rand(Samples(2),Samples(1));
                X       = X + dx*rand(Samples(2),Samples(1));
            elseif strcmp(sampleType,'regular'),
                [Y X] = ndgrid(+linspace(0,1,Samples(2)),...
                               +linspace(0,1,Samples(1)));
            else
                error('Matlab:Parameter',...
                    'The sample type %s is not valid!',sampleType);
            end
            Y = Interval(2) + (Interval(4) - Interval(2)) * Y;
            X = Interval(1) + (Interval(3) - Interval(1)) * X;
            Z = zeros(Samples(2),Samples(1));
            N = [0; 0; 1; 0];
            rotAngle = acos(Normal'*N);
            RotAxis = [cross(Normal(1:3),N(1:3)); 0];
            T = rotMatrixForAxisAngle(RotAxis,rotAngle);
            Pos = Normal*distance;
            Pos(4) = 1;
            T(:,4) = Pos;
            obj.Points = ( T*[X(:) Y(:) Z(:) ones(numel(Z),1)]' )';
            obj.nPoints = numel(Z);
        end
        function M = getMesh(obj)
            uMin = obj.Interval(1);
            vMin = obj.Interval(2);
            uMax = obj.Interval(3);
            vMax = obj.Interval(4);
            M = [uMin vMin; ...
                 uMax vMax; ...
                 uMin vMax; ...
                 uMin vMin; ...
                 uMax vMin; ...
                 uMax vMax];
        end
    end
end