% Univariate Staddon & Higa 1999/2002 Multiple-time-scale (MTS) model
%
% 
% Model description: TODO
%     Decaying trace:
%       This model integrates weight w over time if x is present: +x*w*dt.
%       The integration is bounded below by 0 and above by 1.   
%       Once the integration as reached 1, it stays at 1 until rewarded (1).
%       On reward, or on reset, the integration is reseted to 0.
%       The noise is given by beta*sqrt(x*w*dt)*length(x)
%       The response is 1 if integrator (phi) > theta, 0 otherwise
%       Multistimuli note: 
%           Integration processes are computed individually (phis).
%           Then, if their sum is bigger than 1, 
%               they are normalized to 1
%           Those who have reach 1 individually, 
%               can`t worth more than 1 in the normalization process.
%           Response is based on their sum (phi)
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
% 20110517: First version, uses only the reinforcement. No inputs
%           No learning or response rule yet. Untested.
% 20110603: Recordable variables descriptions added
%
%
classdef UV_MTS < Agent

    % Hyper parameters
    properties (Access = protected)
        dt;             % dt = 1/Sampling frequency
        M;              % Number of cascading units
        lambda;         % Scalar used to generate vector a
        a;              % Vector of a_j values 
        b;              % Vector of b_j values
        theta;          % Vector of theta values
        xi;             % Reinforcement learning efficacies
        eta;            % Noise factor
        e;              % Noise distribution
    end
    
    % Variables that can be recorded
    properties (GetAccess = public, SetAccess = protected)
        x;      % Vector of integrators input (col vector (1,stimulusCount+1))
        v;      % Vector of integrator values (col vector (1,stimulusCount))
        vm;     % Current memory trace (scalar)
        v_rft;  % Value of decaying memory trace on last reinf. (scalar)
        phi;    % Current response threshold (scalar)
    end
    
    % Internal variables, not to be recorded
    properties (Access = protected)
        lastreward;     % reward value at previous time-step
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
            sizeStruct.x.type = 'Vector';
            sizeStruct.x.dimensions = [1, AG.M + 1];
            
            if AG.M > 1
                sizeStruct.v.type = 'Vector';
                sizeStruct.v.dimensions = [1, AG.M];
            else
                sizeStruct.v.type = 'Scalar';
                sizeStruct.v.dimensions = [1,1];
            end
            
            sizeStruct.vm.type = 'Scalar';
            sizeStruct.vm.dimensions = [1,1];
            
            sizeStruct.v_rtf.type = 'Scalar';
            sizeStruct.v_rtf.dimensions = [1,1];
            
            sizeStruct.phi.type ='Scalar';
            sizeStruct.phi.dimensions = [1,1];
        end
        
        % Constructor
        % Arguments:    samplingRate (sampling rate of the simulation)
        %               stimulusCount (length of the received stimulus vector)
        %               actionCount (length ot the returned action vector)
        %               paramStruct (can have any of the following fields)
        %                   UnitCount
        %                   Noise (noise level such that std() = noise * sqrt(xwdt), default 0)
        %                   LearningRateSch (0 = read only, 
        %                                    in (0,1) = fixed learning rate
        %                                    1 = 1/n schedule, n = number of events,
        %                                    default = .1)
        %                   InitWeights (initial weights vector, 
        %                                same lenght as stimulus count
        %                                Default, eps)
        % TODO: more parameter checking
        %               
        function MTS = UV_MTS(samplingRate, stimulusCount, actionCount, paramStruct)
            
            % One line to call constructor check from Agent here 
            % This will save into protected samplingRate, stimulusCount
            % and actionCount properties.
            MTS = MTS@Agent(samplingRate, stimulusCount, actionCount);
            
            % Hyper-params
            MTS.dt = 1/samplingRate;
            %Default values
            MTS.M = 14;
            MTS.lambda = .675;
            MTS.a = 1-exp(-MTS.lambda*(1:MTS.M));
            MTS.b = ones(1,MTS.M)*.04;
            MTS.theta = zeros(1,MTS.M); 
            MTS.xi = .14;
            MTS.eta = .04;
            MTS.e = Dist.UnifDist(-.5, .5);
                    
            % Variables inilializations
            MTS.x = zeros(1,MTS.M+1); 
            MTS.v = zeros(1,MTS.M); 
            MTS.vm = 0;
            MTS.v_rft = 0;
            MTS.phi = 0;
        
        end
        
        % Process the input pattern and returns the output pattern
        %   arguments: x = Input vector
        %              y = Shift from 0 to 1 considered event onset
        function action = process(MTS, stimulus, reward)
        
            % Current version of MTS only cares about reward onset
            
            % Based on time-scales in paper, we assumed constant are
            % defined for dt = 1 (1sec)
            
            % Save current memory trace in case we see a reward
            MTS.v_rft = MTS.vm;
            
            %Compute input x_1
            if reward > 1 && MTS.lastreward == 0
                MTS.x(1) = 1;
            else
                MTS.x(1) = 0;
            end
            MTS.lastreward = reward;
            
            %Compute all other xs and vs
            prev_v = MTS.v;
            for j=1:MTS.M
                MTS.v(j) = MTS.a(j)*prev_v(j)+MTS.b(j)*MTS.x(j);
                MTS.x(j+1) = max(0,MTS.x(j)-prev_v(j)-MTS.theta(j));
            end
            
            %Current memory trace
            MTS.vm = sum(MTS.v)
            
            action = 0;
        end
        
        % Resets the model internal memory traces. 
        % Only current threshold maintained
        function reset(MTS)
            % Variables re-inilializations
            MTS.X = zeros(1,MTS.M+1); 
            MTS.V = zeros(1,MTS.M); 
            MTS.vm = 0;
            MTS.v_rft = 0;
        end
    end
end


    
