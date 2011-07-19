% Univariate Harmonic-Mean Adaptive Drift-Diffusion Process 1
%
% 
% Model description:
%     Build-ups:
%       This model integrates weight w over time if x is present: +x*w*dt.
%       The integration is bounded below by 0 and above by 1.   
%       Once the integration as reached 1, it stays at 1 until rewarded(1).
%       On reward, or on reset, the integration is reseted to 0.
%       The noise is given by beta*sqrt(x*w*dt)*length(x)
%       Multistimuli note: 
%           Integration processes are computed individually (phis).
%           Then, if their sum is bigger than 1, 
%               they are normalized to 1
%           Those who have reach 1 individually, 
%               can`t worth more than 1 in the normalization process.
%           Response is based on their sum (phi)
%     Response:
%       The response is 1 if integrator (phi) > theta, 0 otherwise
%       The response is always stored in the first action.
%     Learning:
%       Correction is made to reach 1 on reward (1).
%       The learning rule is the one for harmonic mean of the interval 
%           If event is late, changes are temporarly integrated, 
%               On reward, the changes are saved in the original weight
%       The learning rate can be 0 (no learning), 0<alpha<1, 1 (1/n sched.)
%           'reset' does not reset the schedule.
%       Multistimuli note: 
%           Early event correction is based on individual phi value.
%               To avoid division by 0, phi >= eps.
%           Late rule is modulated by length(stimulus).
%       Weight initialisation: 0.0000001 or as provided.    
%     Reset:
%       Reset temporary cumulated decays and all accumulators. 
%       No learnign rate change or weight changes.
%
%
% Author: Francois Rivest
%
%
% 20110419: Based on LieanrUnit7B as of 20100531
%           First AnimalsSimulationFramework implementation
%           Adapted for Build 1+ (still adjustment to be done)
%           Untested yet.
%           Francois Rivest
% 20110516: Adapted to Build 1.1
%           Renamed, documented
%           Adding weight initialisation parameter
%           Fixing Process for x/y stimulus*reward.. still need to validate
%           Reset function added.
% 20110519: BugFix in constructor
% 20110603: Recordable variables descriptions added
%
%
classdef UV_HM_ADDP < Agent

    % Hyper parameters
    properties (Access = protected)
        dt;             % dt = 1/Sampling frequency
        eps=0.0000001;  % Small starting weights and small minimum phis
        alpha;          % Learning rate
        schedule;       % 1/n learning rate schedule
        beta;           % Noise factor, 0 = No noise, always Weiner absorb.
        theta;          % Level of activity required to respond        
    end
    
    % Variables that can be recorded
    properties (GetAccess = public, SetAccess = protected)
        phi;    %Unit output (scalar)
        phis;   %Individual cumulator (col vector (1,stimulusCount))
        w;      %Weights value (col vector (1,stimulusCount))
        v;      %Temporary fast adapting weights (col vector (1,stimulusCount))
    end
    
    methods
        
        %A function which generates a size structure which the data store
        %will use to properly preallocate memory.
        
        %INPUT
        %AG:            A reference to an initialized agent object.
        
        %Output
        %sizeStruct     The structure that will be used to initialize the
        %               data store.
        
        function sizeStruct = genSizeStruct(AG)
            sizeStruct.phi.type = 'Scalar';
            sizeStruct.phi.dimensions = [1,1];
            
            if AG.stimulusCount == 1
                type = 'Scalar';
                length = 1;
            else
                type = 'Vector';
                length = AG.stimulusCount;
            end
            
            sizeStruct.phis.type = type;
            sizeStruct.phis.dimensions = [1, length];
            
            sizeStruct.w.type = type;
            sizeStruct.w.dimensions = [1, length];
            
            sizeStruct.v.type = type;
            sizeStruct.v.dimensions = [1, length];
        end
        
        % Constructor
        % Arguments:    samplingRate (sampling rate of the simulation)
        %               stimulusCount (length of the stimulus vector)
        %               actionCount (length ot the returned action vector)
        %               paramStruct (can have any of the following fields)
        %                   Threshold (level of activity require to respond
        %                              default .85)
        %                   Noise (noise level such that 
        %                          std() = noise * sqrt(xwdt), default 0.15)
        %                   LearningRateSch (0 = read only, 
        %                                    in (0,1) = fixed learning rate
        %                                    1 = 1/n schedule, 
        %                                        where n = number of events
        %                                    default = .1)
        %                   InitWeights (initial weights vector, 
        %                                same lenght as stimulus count
        %                                Default, eps)
        % TODO: more parameter checking
        %               
        function DDM = UV_HM_ADDP(samplingRate, stimulusCount, ...
                actionCount, paramStruct)
            
            % One line to call constructor check from Agent here 
            % This will save into protected samplingRate, stimulusCount
            % and actionCount properties.
            DDM = DDM@Agent(samplingRate, stimulusCount, actionCount);
            
            % Hyper-params
            DDM.dt = 1/samplingRate;
            if isfield(paramStruct, 'Threshold') 
                DDM.theta = paramStruct.Threshold;
            else
                DDM.theta = .85;
            end
            if isfield(paramStruct, 'Noise') 
                DDM.beta = paramStruct.Noise;
            else
                DDM.beta = 0.15;
            end
            if isfield(paramStruct, 'LearningRateSch') 
                switch paramStruct.LearningRateSch
                    case 0
                        DDM.schedule = 0;
                        DDM.alpha = 0;
                    case 1
                        DDM.schedule = 1;
                        DDM.alpha = 1;
                    otherwise   
                        DDM.schedule = 2;
                        DDM.alpha = LearningRateSch;
                end
            else
                DDM.schedule = 2;
                DDM.alpha = .1;
            end
                    
            % Variables inilializations
            DDM.phi = 0;
            DDM.phis = zeros(1,stimulusCount);
            DDM.w = ones(1,stimulusCount)*DDM.eps;
            DDM.v = zeros(1,stimulusCount);
            
            % Initial Weights
            if isfield(paramStruct, 'InitWeights') 
                if size(paramStruct.InitWeights) ~= [stimulusCount,1]
                    error('UV_HM_ADDP:Constructor', ...
                        'Error: Invalid InitWeights Parameter!')
                else
                    DDM.w = paramStruct.InitWeights;
                end
            end
            
        end
        
        % Process the input pattern and returns the output pattern
        %   arguments: x = Input vector
        %              y = 1 for event onset, 0 otherwise
        function action = process(DDM, stimulus, reward)
            
            % TODO ad one line detection of input check
            x = stimulus;
            y = reward;
            
            % Compute noise (only if there is still space for it)
            %Absorbing process, Weiner noise, no rebound below 1
            if DDM.phi ~= 1 
                zhetas = DDM.beta*sqrt(x.*DDM.w*DDM.dt).*...
                    randn(size(stimulus)); 
            else
                zhetas = 0;
            end
            % Cumulate individual evidences and bound between 0 and 1
            DDM.phis = max(0,min(DDM.phis + x.*DDM.w*DDM.dt + zhetas, 1));
            % Compute total activity
            DDM.phi = sum(DDM.phis);
            % Normalize to 1
            if DDM.phi > 1
                DDM.phis = DDM.phis/sum(DDM.phis);
                DDM.phi = 1;
            end
            
            % Reward earlier than expected, make a single big correction
            if y == 1 && DDM.phi < 1 
                %disp('early reward')
                %local update
                DDM.v = DDM.w*(1.0-DDM.phi)/max(DDM.dt,DDM.phi);%div/0 ok
                %global update
                DDM.w = DDM.w + DDM.alpha*DDM.v;
                DDM.v = zeros(1,length(x));
                DDM.phi = 0;
                DDM.phis = zeros(1,length(x));
                if DDM.schedule == 1
                    DDM.alpha = 1/((1/DDM.alpha)+1);
                end
            % Timing is ok now
            elseif y == 1 && DDM.phi == 1 
                %disp('ok')
                %DDM.v
                %global update
                DDM.w = DDM.w + DDM.alpha*DDM.v;
                DDM.v = zeros(1,length(x));
                DDM.phi = 0;
                DDM.phis = zeros(1,length(x));
                if DDM.schedule == 1
                    DDM.alpha = 1/((1/DDM.alpha)+1);
                end
            % Reward later than expected, decay weights proportionnaly
            elseif DDM.phi == 1
                %disp('waiting reward')
                %local update
                DDM.v = DDM.v - DDM.dt.*((DDM.w+DDM.v).^2)*length(x);
            end
            
            % Test potential problems
            if isinf(DDM.w)
                error('Infinite weights!')
            end
            if isinf(DDM.v)
                error('Inifinite delta-weights')
            end
         
            % Compute thesholded action
            action = zeros(DDM.actionCount,1);
            if DDM.actionCount > 0
                action(1) = (DDM.phi >= DDM.theta);
                if (action(1) > 0)
                    disp('acting');
                    disp(action);
                end
            end
            
        end
        
        % Resets the model internal build-ups. 
        % No weight update, no learning rate changes, just phis, phi, v = 0
        function reset(DDM)
            DDM.phi = 0;
            DDM.phis = zeros(1,stimulusCount);
            DDM.v = zeros(1,stimulusCount);            
        end
    end
end


    
