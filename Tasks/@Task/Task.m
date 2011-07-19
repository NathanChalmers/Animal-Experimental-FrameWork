classdef Task < AgentTaskShare
    %Task
    
    %An abstract class which tasks interfacing with the framework must
    %extend. Overloaded methods define the interface by which the task
    %interacts with the framework and inherited properties define both the
    %dimensionality of the stimulus, reward, and action signals inherent to
    %the task and the public task variables to be recorded.
    
    %In addition to the defined methods, child task classes should define a
    %public constructor of the form subAgent(numStimulus, numReward, numAction, sampleRate, duration, paramStruct)
    %paramStruct paramStruct is a structure whose (field name, value) pairs
    %match variables within the subTask to be configured by the
    %contructor. recordList is a cell array in which each cell contains the
    %string litteral of the task variable name to be recorded at the end of
    %a given time step.
    
    %Variables to be recorded by the framework must be publically
    %accessible. Values will be recorded at the end of each time step
    
    %For each time step the process method is called using the agent's
    %action from the previous time step in order to generate stimulus and
    %reward signals for the current timestep.
    
    %**********************************************************************
    %PROPERTIES TO BE SET BY THE CHILD TASK CLASS
    %**********************************************************************
    properties (GetAccess = public, SetAccess = protected)
        %SEE ADDITIONAL PROPERTIES IN AgentTaskShare
        
        duration %The maximum duration of the task.
    end
    
    properties (GetAccess = protected, SetAccess = protected)
        EOT %boolean flag variable which represents the end of task. ONLY WRITE
            %THROUGH CALL TO EndOfTask();
    end
    
    %**********************************************************************
    %SUPER CONSTRUCTOR
    %**********************************************************************
    methods
        %Super constructor used to validate and set the abstract properties
        %inherited by the child class.

        %INPUT
        %samplingRate   The frequency at which the simulation is sampled
        %stimulusCount  The number of elements which define a stimulus
        %               vector
        %actionCount    The number of elements that define an action vector
        %duration      The maximum number of time steps the simulation
        %               will run
        %recordList     The list of task variables to be recorded by the
        %               simulation framework
        function TK = Task(samplingRate, stimulusCount, actionCount, duration)
            TK@AgentTaskShare(samplingRate, stimulusCount, actionCount);

            if isnan(duration) || isinf(duration) || duration - floor(duration) ~= 0
                error('Task:Constructor', 'Error: Invalid Value for Duration');
            else
                TK.duration = duration;
            end
            
            TK.EOT = -1;
        end
    end
    
    %**********************************************************************
    %METHODS TO BE DEFINED BY THE CHILD TASK CLASS
    %**********************************************************************
    methods (Abstract)
        %An abstract function which calculates the stimulus and reward to
        %be provided to an agent for an individual timestep based on the
        %action recieved from the agent from the previous time step.
        
        %INPUT
        
        %TK:        A reference to the initialized Task object
        
        %action:    A vector of length numAction which defines the agents
        %           preceived action from the previous timestep
        
        %OUTPUT
        
        %stimulus:  A vector of length numStimulus which defines the
        %           stimulus to be provided to the agent for the current 
        %           timestep.
        
        %reward:    A vector of length numReward which defines the reward
        %           to be provided to the agent for the current timestep.
        [stimulus, reward] = process(TK, action)
    end
    
    %**********************************************************************
    %OPTIONAL METHODS TO OVERLOAD FOR ADITIONAL FUNCTIONALITY
    %**********************************************************************
    methods
%       A method which determines whether or not the task has concluded.
%       Default behavious is to always return false, in which case task
%       conclusion will occur when a number of time steps equal to
%       duration has occured. This function should be overloaded in order
%       for the user to define a custom stoping criterion. However, whether
%       a custom stoping criterion is defined or not, task execution will
%       always ceases after a number of times steps equivalent to duration
%       has been processed.
%
%       INPUT
%       TK: a reference to the initialized agent
%
%       OUTPUT
%       r:  a boolean value indicating true if the trial has concluded
        r = EndOfTask(TK)
    end
    
    %**********************************************************************
    %METHODS AND PROPERTIES USED BY FRAMEWORK. IGNORE.
    %**********************************************************************
    methods
        %A method which involves the process command for the task, insuring
        %that the stimulus and reward paramaters are equivalent to those
        %defined by the class through stimulusCount and actionCount
        
        %INPUT
        %TK:        a reference to the initialized task
        %action:    The agent action vector from which new stimulus and reward are
        %           to be generated.
        
        %OUTPUT
        %reward:    a scalar value equivalent to the reward to be
        %           administered to the agent.
        %stimulus:  The stimulus vector to be presented to the agent.
        [stimulus, reward] = validProcess(TK, action)
    end
end

