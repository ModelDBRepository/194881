classdef ModuleModel < handle
    % The module model for grid cell firing takes visual input such as 
    % (i)  visual angles of memorized landmarks to estimate the position of 
    %      self and
    % (ii) angular velocities from the ground plane to estimate the
    %      self-motion.
    %
    %   Copyright (C) 2015  Florian Raudies, 04/30/2015, Palo Alto, CA.
    %   License, GNU GPL, free software, without any warranty.
    %
    properties (SetAccess = protected)
        scene           % The scene with the camera and objects.
        Points          % All image points in allocentric coordinates.
        Ground          % Segmentation into ground.
        ratio           % Ratio: vertical/horizontal field of view.
        TrajGt          % The 3D coordinates of the trajectory.
        TrajEstByAng    % Trajectory estimated from angles.
        TrajEstByVel    % Trajectory estimated from velocities.
        sigmaNoiseAng   % Standard deviation for noise in angles.
        muNoiseAng      % Mean value for noise in angles.
        sigmaNoiseVel   % Standard deviation for noise in velocity.
        muNoiseVel      % Mean value for noise in velocity.
        SNRAng          % Signal-to-noise ratio for angles.
        SNRVel          % Signal-to-noise ratio for velocity.
        nStep           % Number steps in the trajectory.
        dt              % Time step interval.
        VelZGt          % Linear velocity along the optical axis.
        OmegaYGt        % Rotational yaw-velocity.
        VelZEst         % Estimate of linear velocity.
        OmegaYEst       % Estimate of yaw velocity.
        Phi             % Orientation of the camera (head direction).
        
        % Variables used by the algorithm itself.
        w               % Width of the box.
        l               % Length of the box.
        alpha           % Regularization parameter for the algorithm.
        phi             % Current orientation of the camera.
        PosMem          % All memorized positions.
        Az              % Azimuth angle of visible points.
        El              % Elevation angle of visible points.
        AzNoise         % Azimuth angle with noise.
        ElNoise         % Elevation angle with noise.
        DAzGrd          % Image velocity for azimuth angle.
        DElGrd          % Image velocity for elevation angle.
        DAzGrdNoise     % Image velocity for azimuth angle with noise.
        DElGrdNoise     % Image velocity for elevation angle with noise.
        AzGrd           % Azimuth angle for visible points on the ground.
        ElGrd           % Elevation angle for visible points on the ground.
        Xm              % The x-position \
        Ym              % The y-position  retrieved from memory.
        Zm              % The z-position /
        distFromGround  % Distance from ground plane.
        % Grid cell model
        PosGt           % Ground-truth position of trajectory.
        SpikePosForVel  % Spikes for velocity system.
        SpikePosForAng  % Spikes for angle system
    end
    methods (Static)
        % Esimate the Signa-to-Noise Ratio (SNR).
        function snr = estimateSNR(Signal, SignalWithNoise)
            snr = 20*log10( sum(Signal(:).^2) ...
               ./(eps + sum((Signal-SignalWithNoise).^2)) );
        end
        % Calculate the Euclidean Error.
        function Err = euclideanError(GroundTruth,Estimate)
            % Assumes components are in the 2nd dimension.
            Err = sqrt( sum((GroundTruth-Estimate).^2,2) );
        end
    end
    methods
        % If opt is present this sets a random trajectory using fields in 
        % opt as parameters.
        function obj = ModuleModel(scene, opt)
            obj.scene           = scene;
            obj.Points          = scene.getPoints();
            obj.ratio           = scene.camera.getAspectRatio();
            obj.sigmaNoiseAng   = 0/180*pi;
            obj.muNoiseAng      = 0/180*pi;
            obj.sigmaNoiseVel   = 0/180*pi;
            obj.muNoiseVel      = 0/180*pi;
            obj.dt              = 0.05;            
            P                   = scene.getPoints();
            obj.distFromGround  = min(P(:,2));
            
            % Check that the camera is above the ground.
            if abs(obj.distFromGround)<=eps,
                error('Matlab:Parameter',...
                    ['Scene should have points below the',...
                     'camera that is at 0.']);
            end
            
            % Parameters for triangulation method.
            obj.alpha           = 10^-4; % Regularization.
            Interval            = scene.getObject().getInterval();
            obj.w               = Interval(6) - Interval(3); % Width of box.
            obj.l               = Interval(4) - Interval(1); % Height of box.
            
            % If the structure opt is present set a random trajectory.
            if nargin >= 2,
                obj.setRandomTraj(opt);
                obj.memorizePositions();
                obj.setGroundSegment(opt.Ground);
            end
        end
        % Set the step width (delta t).
        function obj = setDeltaTime(obj, dt)
            obj.dt = dt;
        end
        % Get the step width (delta t).
        function dt = getDeltaTime(obj)
            dt = obj.dt;
        end
        % Reset the scene, by assigning a new layout and random trajectory.
        % opt contains the index to points that should be deleted from the
        % memorized positions.
        function obj = resetScene(obj,scene,opt)
            obj.scene = scene;            
            obj.setRandomTraj(opt);
            % This handles visibility.
            obj.updateMemorizedPositions(opt.DeleteIndex); 
            obj.setGroundSegment(opt.Ground);
        end
        % Use the current scene to memorize all the points present in that
        % scene.
        function obj = memorizePositions(obj)
            % The current camera position is reference for memorized points.
            obj.PosMem = obj.scene.getAllImagePoints();
        end
        % Update the memorized positions through a delete index by 
        % excluding positions.
        function obj = updateMemorizedPositions(obj, DeleteIndex)
            obj.PosMem(:,DeleteIndex) = [];
        end
        % Set a logical index with entries '1' for all points from the
        % ground.
        function obj = setGroundSegment(obj, Ground)
            obj.Ground = Ground;
        end
        % Set the position, direction-vector, and up-vector of the
        % trajectory to simulate.
        function obj = setPosDirUpOfTraj(obj, Pos,Dir,Up)
            
            if nargin<3,
                DPos        = Pos(:,2:end) - Pos(:,1:end-1);
                DPos(1:3,:) = DPos(1:3,:) ...
                    ./repmat( (eps + sqrt(sum(DPos(1:3,:).^2,1))), [3 1]);
                Dir         = DPos;
                Pos         = Pos(:,1:end-1);
                Up          = [zeros(1,size(Pos,2)); ...
                               ones(1,size(Pos,2)); ...
                               zeros(1,size(Pos,2)); ...
                               zeros(1,size(Pos,2))];
            end
            
            if any(Pos(2,:)>eps), 
                error('Matlab:Parameter','Assumes camera is at y=0'); 
            end
            
            % Pos (1-4), Dir (5-8), Up (9-12)
            obj.TrajGt              = [Pos; Dir; Up];
            obj.scene.moveCameraTo(Pos(:,1)); % set position
            obj.scene.orientCamera(Dir(:,1),Up(:,1)); % set orientation
            Bz                      = Dir;
            obj.VelZGt              = [0 sqrt(sum((Pos(1:3,2:end) ...
                                                 - Pos(1:3,1:end-1)).^2,1))/obj.dt];
            obj.Phi                 = atan2( Bz(3,:), Bz(1,:) );
            obj.phi                 = obj.Phi(1);
            obj.OmegaYGt            = [0 (wrapTo2Pi(obj.Phi(2:end)...
                                         -obj.Phi(1:end-1)+pi)-pi)/obj.dt];
            obj.nStep               = length(obj.OmegaYGt);
            obj.TrajGt              = obj.TrajGt(:,1:obj.nStep);
            obj.TrajEstByAng        = zeros(12, obj.nStep);
            obj.TrajEstByVel        = zeros(12, obj.nStep);
            obj.VelZEst             = zeros(1, obj.nStep);
            obj.OmegaYEst           = zeros(1, obj.nStep);
            obj.SNRAng              = zeros(1, obj.nStep-1);
            obj.SNRVel              = zeros(1, obj.nStep-1);
        end
        % Set a random trajectory.
        function obj = setRandomTraj(obj, opt)
            opt.nStep           = opt.nStep + 1;
            opt.dt              = obj.dt;
            % Get the extent of the ground plane.         
            Interval            = obj.scene.getObject().getInterval();
            opt.PosYInterval    = Interval([1 4]); % attention xy-flip
            opt.PosXInterval    = Interval([3 6]);            
            Pos                 = randomTrajectory(opt);
            Pos                 = [Pos(:,2)'; zeros(1,size(Pos,1)); ...
                                   Pos(:,1)'; zeros(1,size(Pos,1))]; % flip xz
            obj.setPosDirUpOfTraj(Pos);
        end
        % Calculate the grid score using either opt.ventral or opt.dorsal
        % estimates.
        function [gsVel, SpikeRateVel, gsAng, SpikeRateAng] = ...
                calculateGridScores(obj, opt)
            Interval = obj.scene.getObject().getInterval();
            opt.DimCm = Interval([3 6 1 4]) * 0.85;
            [gsVel, SpikeRateVel] = gridScoreForSpikes(...
                                        obj.SpikePosForVel,obj.PosGt, opt);
            [gsAng, SpikeRateAng] = gridScoreForSpikes(...
                                        obj.SpikePosForAng,obj.PosGt, opt);
        end
        % The main simulation loop, which goes over the trajectory and
        % computes the optic flow, visual angles to landmarks, and feeds
        % that information into the model estimating position from the
        % visual angles through triangulation and estimating self-motion
        % from optic flow.
        function obj = simulate(obj)
            opt.w                   = obj.w;
            opt.l                   = obj.l;
            opt.alpha               = obj.alpha;
            obj.TrajEstByAng(:,1)   = obj.TrajGt(:,1);
            obj.TrajEstByVel(:,1)   = obj.TrajGt(:,1);
            obj.VelZEst(1)          = obj.VelZGt(1);
            obj.OmegaYEst(1)        = obj.OmegaYGt(1);
            % *************************************************************
            % Estimate the position signals using the landmarks and
            % velocity signals.
            % *************************************************************
            for iStep = 2:obj.nStep,
                obj.scene.moveCameraTo(obj.TrajGt(1:4,iStep));
                obj.scene.orientCamera(obj.TrajGt(5:8,iStep),obj.TrajGt(9:12,iStep));
                [obj.Az obj.El D V] = obj.scene.getImagePoints();
                
                obj.AzNoise = obj.Az + obj.muNoiseAng ...
                            + obj.sigmaNoiseAng * randn(size(obj.Az));
                obj.ElNoise = obj.El + obj.muNoiseAng ...
                            + obj.sigmaNoiseAng * obj.ratio * randn(size(obj.El));
                
                % Only the azimuth angle is used for estimation, so then
                % also compute the SNR using only the azimuth angle.
                obj.SNRAng(iStep-1) = ModuleModel.estimateSNR(obj.Az(:),obj.AzNoise(:));


                % Selecting only the visible points and getting the order according to 
                % the angles for azimuth and elevation requires a recognition of
                % features.
                obj.Xm = obj.PosMem(1,V);
                obj.Ym = obj.PosMem(2,V);
                obj.Zm = obj.PosMem(3,V);
                G      = obj.Ground(V);

                % We swap the x,z coordinates and the direction of the
                % z-axis, because the camera points toward -z.
                % The azimuth angle is transformed from ego-centric to
                % allo-centric.
                Pos = estimatePosition(obj.AzNoise(~G)+obj.Phi(iStep)-pi/2,...
                    -obj.Xm(~G),obj.Zm(~G), opt);
                Pos = [Pos(1); 0; Pos(2)];

                obj.TrajEstByAng(1:3,iStep) = Pos;
                
                % If we have at least two samples on the ground, then 
                % calculate the optic flow and estimate self-motion from 
                % that flow. In some pathological cases, we end up not 
                % seeing the ground, when the rat is too close to a wall.
                if sum(G) >= 2,
                    obj.AzGrd       = obj.Az(G);
                    obj.ElGrd       = obj.El(G);
                    
                    % Get the optic flow sensed by the spherical camera for
                    % the given self-motion.
                    [obj.DAzGrd obj.DElGrd] = SphericalCamera.imageFlow(...
                        obj.AzGrd, obj.ElGrd, D(G),...
                        [0 0 obj.VelZGt(iStep)], [0 obj.OmegaYGt(iStep) 0], 1);
                    
                    % Super-impose (biased) Gaussian noise onto the
                    % components of optic flow.
                    obj.DAzGrdNoise = obj.DAzGrd ...
                                    + obj.muNoiseVel ...
                                    + obj.sigmaNoiseVel ...
                                        * randn(size(obj.DAzGrd));
                    obj.DElGrdNoise = obj.DElGrd ...
                                    + obj.muNoiseVel ...
                                    + obj.sigmaNoiseVel ...
                                        * obj.ratio * randn(size(obj.DElGrd));
                    
                    % Characterize the "strength" of the noise through the
                    % Signal-to-Noise Ratio.
                    obj.SNRVel(iStep-1) = ModuleModel.estimateSNR(...
                        [obj.DAzGrd(:); obj.DElGrd(:)],...
                        [obj.DAzGrdNoise(:); obj.DElGrdNoise(:)]);

                    % Estiamte the self-motion velocities from optic flow.
                    Vel = estimateVelocity(obj.DAzGrdNoise,obj.DElGrdNoise, ...
                        obj.AzGrd,obj.ElGrd,obj.distFromGround);
                    
                    vzEst = Vel(1);
                    oyEst = Vel(2);
                else
                    vzEst = obj.VelZGt(iStep);
                    oyEst = obj.OmegaYGt(iStep);
                    fprintf('No flow on the ground.\n');
                end
                % Record the estimated velocities.
                obj.VelZEst(iStep)      = vzEst;
                obj.OmegaYEst(iStep)    = oyEst;
                
                % Temporal integration of the self-motion velocity.
                obj.TrajEstByVel(1:3,iStep) = ...
                    [cos(obj.phi); 0; sin(obj.phi)]*vzEst*obj.dt ...
                    + obj.TrajEstByVel(1:3,iStep-1);
                
                % Temporal integration of the head-direction angle.
                obj.phi = obj.phi + oyEst*obj.dt;
            end
            % By default calcualte the grid cell firing using the VCO
            % model.
            obj.calculateGridCellFiringWithVCOModel();
        end
        % Calculate the grid cell firing using the estimated trajectory and
        % the VCO model.
        function obj = calculateGridCellFiringWithVCOModel(obj)
            obj.PosGt   = obj.TrajGt([3,1],:)';
            PosEst      = obj.TrajEstByVel([3,1],:)';
            Time        = (0 : (obj.nStep-1))'*obj.dt;
            opt.f       = 7.38; % Frequency of theta oscillation for VCO.
            opt.beta    = 0.004; % Controls the grid spacing.
            obj.SpikePosForVel = vcoModel(Time, obj.PosGt, PosEst, opt);
            opt.beta    = 0.003; % Controls the grid spacing.
            PosEst      = obj.TrajEstByAng([3,1],:)';
            obj.SpikePosForAng = vcoModel(Time, obj.PosGt, PosEst, opt);            
        end
        % Calculate the grid cell firing using the estimated trajectory and
        % the attractor model.
        function obj = calculateGridCellFiringWithAttractorModel(obj)
            obj.PosGt   = obj.TrajGt([3,1],:)';
            PosEst      = obj.TrajEstByVel([3,1],:)';
            Time        = (0 : (obj.nStep-1))'*obj.dt;
            VelEst      = diff(PosEst)/obj.dt;
            opt.alpha   = 1.4e-3; % Controls the grid spacing.
            obj.SpikePosForVel = attractorModel(Time, ...
                                    obj.PosGt(1:end-1,:), VelEst, opt);
            opt.alpha   = 0.9e-3; % Controls the grid spacing.
            PosEst      = obj.TrajEstByAng([3,1],:)';
            VelEst      = diff(PosEst)/obj.dt;
            obj.SpikePosForAng = attractorModel(Time, ...
                                    obj.PosGt(1:end-1,:), VelEst, opt);
        end
        % Return the ground-truth positions in the 2D ground-plane with
        % dimensions 2 x nSample. The 1st component is the horizontal
        % component and the 2nd component is the vertical component.
        function Pos = getPosGt(obj)
            Pos = obj.TrajGt([3,1],:)';
        end
        % Get the linear velocity along the optical axis in cm/sec.
        function V = getVelZGt(obj)
            V = obj.VelZGt;
        end
        % Get the rotational velocity around the y-axis (yaw) in rad/sec.
        function O = getOmegaYGt(obj)
            O = obj.OmegaYGt;
        end
        % Get the ground-truth of the the linear velocity in cm/sec.
        function V = getVelZEst(obj)
            V = obj.VelZEst;
        end
        % Get the ground-truth of the rotational yaw-velocity in rad/sec.
        function O = getOmegaYEst(obj)
            O = obj.OmegaYEst;
        end        
        % Get the position estimated through the temporal integration of
        % self-motion velocities (and knowing the initial reference
        % position).
        function Pos = getPosEstByVel(obj)
            Pos = obj.TrajEstByVel([3,1],:)';
        end
        % Get the position estimated through visual angles.
        function Pos = getPosEstByAng(obj)
            Pos = obj.TrajEstByAng([3,1],:)';
        end
        % Get the position of spikes estimated by optic flow and the
        % veloctiy controlled oscillator model or attractor model.
        function SpikePos = getSpikePosForVel(obj)
            SpikePos = obj.SpikePosForVel;
        end
        % Get the position of spikes estimated by visual angles and the
        % velocity controlled osciallator model or attractor model.
        function SpikePos = getSpikePosForAng(obj)
            SpikePos = obj.SpikePosForAng;
        end
        % Set the Gaussian noise superimposed to the visual angles of 
        % landmarks.
        function obj = setGaussianNoiseAng(obj,mu,sigma)
            obj.muNoiseAng      = mu;
            obj.sigmaNoiseAng   = sigma;
        end
        % Set the Gaussian noise superimposed to the angular velocities of
        % the optic flow.
        function obj = setGaussianNoiseVel(obj,mu,sigma)
            obj.muNoiseVel      = mu;
            obj.sigmaNoiseVel   = sigma;
        end
        % Get the mean value (taken over steps) for the Signal-to-Noise 
        % Ratio (SNR) for the visual angles of landmarks.
        function snr = getMeanSNRForAng(obj)
            snr = mean(obj.SNRAng);
        end
        % Get the mean value (taken over steps) for the Signal-to-Noise
        % Ratio (SNR) for the angular velocities.
        function snr = getMeanSNRForVel(obj)
            snr = mean(obj.SNRVel);
        end
        % Get the Euclidean error for the positions estaimted by visual 
        % angles toward landmarks.
        function Err = getEuclideanErrorForAng(obj)
            Err = ModuleModel.euclideanError(obj.getPosGt(), ...
                                             obj.getPosEstByAng());
        end
        % Get the Euclidean error for the positions estimated by temporal
        % integration of self-motion velocity estimates.
        function Err = getEuclideanErrorForVel(obj)
            Err = ModuleModel.euclideanError(obj.getPosGt(), ...
                                             obj.getPosEstByVel());
        end
        % Get the time axis for this simulation.
        function Time = getTime(obj)
            Time = (1:obj.nStep)*obj.dt;
        end
    end
end