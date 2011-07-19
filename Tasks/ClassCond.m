% Classical conditioning tasks
%
%
% Task description:
%   Run alternating ITI and ISI. Begins in ITI and terminate in ISI.
%       Always ends with one ITI time step after the last reward delivery.
%   ITI and ISI are all randomly selected from given distributions
%       and represented using given coding. ITI can be 0 (i.e. no ITI).
%   ISI is one time step longuer than defined, to deliver the reward.
%
%
% Stuff to think about:
%   - More parameters check in constructor
%   - Copy distributions before using them, to reset them on reset
%
%
% Author: Francois Rivest
%
%
% 20110419: Based on RunClassCond as of 20100531
%           First AnimalsSimulationFramework implementation
%           Adapted for Build 1+ (still adjustment to be done)
%           Untested yet.
%           Francois Rivest
% 20110516: Adapted to Build 1.1
%           TODO, add a maximum number of trial to stop the task.
% 20110518: Numerous bug fix
%           TODO: add a maximum number of trial to stop the task.
%                 More bugs to fix, More tests to do
% 20110519: Default constructor hyper-parameters added
%           Documentation expanded
%           MaxTrial added, but EOT not yet included (next build)
%
%
classdef ClassCond < Task

    % Hyper parameters
    properties (Access = protected)
        ITIDist;        % Inter-trial time intervals distribution (s)
        ITIStim;        % Intertrial stimulus vector code
        ISIDist;        % Inter-stimuli time intervals distribution (s)
        ISIStim;        % Trial stimulus vector code
        ISIRewStim;     % Trial stimulus vector code on reward
        MaxTrial;       % Maximum number of trial
    end
    
    % Variables that can be recorded
    properties (GetAccess = public, SetAccess = protected)
        clock;          % Task clock / internal copy of simulation clock
        trialno;        % Current trial number (matching ITI ISI NO?? TODO)
        trialtype;      % 1 for trial, 0 for intertrial
        trialtime;      % Time within the current trial or intertrial
        trialinterval;  % Expected duration of current trial
    end

    % Class constants
    properties (Constant = true, GetAccess = public)
        ITI = 0;        % ITI marker
        ISI = 1;        % ISI marker
    end
    
    % Internal variables, not to be recorded
    properties (Access = protected)
        step;           % Number of calls to process since reset() (-1)
        trialstep;      % Number of calls to process within trial (-1)
        lastreward;     % Boolean indicating if reward was given lastly
    end
    
    
    methods
        
        %A method which generates teh necessary recordable variable size
        %structure so the recording data stores may be properly
        %initialized.
        
        %INPUT
        %SH:            A reference to an initialized task object
        
        %OUTPUT
        %sizeStruct     A structure containing size definitions for all
        %               recordable values.
        function sizeList = genSizeStruct(TK)
            sizeList.clock.type = 'Scalar';
            sizeList.clock.dimensions = [1,1];
            
            sizeList.trialno.type = 'Scalar';
            sizeList.trialno.dimensions = [1,1];
            
            sizeList.trialtype.type = 'Scalar';
            sizeList.trialtype.dimensions = [1,1];
            
            sizeList.trialtime.type = 'Scalar';
            sizeList.trialtime.dimensions = [1,1];
            
            sizeList.trialinterval.type = 'Scalar';
            sizeList.trialinterval.dimensions = [1,1];
        end
    
        % Constructor
        % Arguments:    samplingRate (sampling rate of the simulation)
        %               paramStruct (can have any of the following fields)
        %                   ITIDist (class derived from Distribution that
        %                            generates intervals (in s) for ITSI,
        %                            CAN BE 0, default FixedDist(10))
        %                   ITIStim (vector representing the state in ITI
        %                            default... all 0)
        %                   ISIDist (class derived from Distribution that
        %                            generates intervals (in s) for ISI,
        %                            CANNOT BE 0, default FixedDist(1)))
        %                   ISIStim (vector representing the state in ISI
        %                            default... all 0 but the first input)
        %                   ISIRewStim (vector representing ISI state on 
        %                               reward delivery. default ISIStim)
        %                   MaxTrial (Maximum number of trial, default 100)
        %               
        function CC = ClassCond(samplingRate, stimulusCount, ...
                actionCount, duration, paramStruct)
            
            % One line to call constructor check from Agent here 
            % This will save into protected samplingRate, stimulusCount
            % and actionCount properties.'
            CC = CC@Task(samplingRate, stimulusCount, actionCount, ...
                duration);
            
            % Hyper-params TODO add parameter check code.
            if isfield(paramStruct, 'ITIDist') 
                CC.ITIDist = paramStruct.ITIDist;
            else
                CC.ITIDist = Dist.FixedDist(10);
            end
            if isfield(paramStruct, 'ITIStim') 
                CC.ITIStim = paramStruct.ITIStim;
            else
                CC.ITIStim = zeros(stimulusCount,1);
            end
             if isfield(paramStruct, 'ISIDist') 
                CC.ISIDist = paramStruct.ISIDist;
            else
                CC.ISIDist = Dist.FixedDist(1);
            end
            if isfield(paramStruct, 'ISIStim') 
                CC.ISIStim = paramStruct.ISIStim;
            else
                CC.ISIStim = zeros(stimulusCount,1);
                CC.ISIStim(1) = 1;
            end
            if isfield(paramStruct, 'ISIRewStim') 
                CC.ISIRewStim = paramStruct.ISIRewStim;
            else
                CC.ISIRewStim = CC.ISIStim;
            end

            if isfield(paramStruct, 'MaxTrial')
                CC.MaxTrial = paramStruct.MaxTrial
            else
                CC.MaxTrial = 100;
            end
            
            % Initialization
            CC.reset();
            
        end
        
        % Complete documention of this method here TODO
        function [stimulus, reward] = process(CC, action)
        
            % Default values
            reward = 0;
            if CC.trialtype == CC.ITI
                stimulus = CC.ITIStim;
            else % CC.trialtype == CC.ISI
                stimulus = CC.ISIStim;
            end
            
            % Then update the clock
            CC.step = CC.step + 1;
            CC.clock = CC.step/CC.samplingRate;
            CC.trialstep = CC.trialstep + 1;
            CC.trialtime = CC.trialstep/CC.samplingRate;
            
            % Then check if it is time to switch from one trial to the next
            if CC.trialtime >= CC.trialinterval
                % Switch to ISI
                if CC.trialtype == CC.ITI
                    CC.trialtype = CC.ISI;
                    CC.trialtime = 0;
                    CC.trialstep = 0;
                    CC.trialinterval = CC.ISIDist.getSample();
                    stimulus = CC.ISIStim;
                else % trialtype == CC.ISI
                    % First time give reward                      
                    if ~CC.lastreward
                        reward = 1;
                        CC.lastreward = true;
                        stimulus = CC.ISIRewStim;
                        %Test if very last trial HERE TODO!
                    % Second time switch to ITI                        
                    else
                        CC.trialtype = CC.ITI;
                        CC.trialtime = 0;
                        CC.trialstep = 0;
                        CC.trialinterval = CC.ITIDist.getSample();
                        stimulus = CC.ITIStim;
                        %Extra
                        CC.lastreward = false;
                        CC.trialno = CC.trialno + 1;
                        %If ITI is zero, turn to ISI right away
                        if CC.trialinterval == 0
                            CC.trialtype = CC.ISI;
                            CC.trialinterval = CC.ISIDist.getSample();
                            stimulus = CC.ISIStim;
                        end
                    end
                end
            end     
    
        end
        
        % Totally reseted, except distributions not reinitialized!
        function reset(CC)
            
            % Initialize steps
            CC.step = -1;
            CC.trialstep = -1;            
            CC.lastreward = false;
            
            % Initialize task
            CC.clock = 0;
            CC.trialno = 0;
            CC.trialtype = CC.ITI;
            CC.trialtime = 0;
            CC.trialinterval = CC.ITIDist.getSample();
            
        end
        
    end
    
end

    
    
