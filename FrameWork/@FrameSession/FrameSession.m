classdef FrameSession < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %PROPERTIES TO BE SET BY USER AT CONSTRUCTION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (GetAccess = public, SetAccess = protected)
        %Current Simulation Instance Variables
        
        %These are the framework variables which describe the current
        %instance of Agent and Task that are being simulated. These
        %variables are configured by calls to constructTask(FW) and
        %constructAgent(FW)
        
        task %The current task being run
        agent %the current agent being rum
        file
        
        taskRecordList;
        agentRecordList;
    end
    
    methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %PUBLICALLY ACCESSIBLE CONSTRUCTOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %A function which constructs a valid FrameSession object. If a
        %taskRecordList, agentRecordList, and file are not provided, than
        %the simulation is run without recording any data.
        
        %INPUT
        %Task:              An initialized reference to a Task object to be simulated
        %Agent:             An initialized reference to an Agent object to be simulted
        %taskRecordList:    The list of variables in task to be recorded
        %agentRecordList:   The list of variables in agent to be recorded
        %file:              The disk location where recorded task, agent, and frame
        %                   data will be stored.
        
        %OUTPUT
        %FW:                A reference to an initilized FrameSession
        %                   object.
        function FW = FrameSession(task, agent, taskRecordList, agentRecordList, file)
             
             if FrameSession.isSubClass(task, 'Task') ~= 1
                 error('b:b', 'Error: The provided task must be a subclass of type Task');
             end
             
             if FrameSession.isSubClass(agent, 'Agent') ~= 1
                 error('b:b', 'Error: The provided agent must be a subclass of type Agent');
             end
             
             FrameSession.compatible(task,agent);

             if isobject(task) ~= 1 || isobject(agent) ~= 1
                 error('FrameSession:Constructor', 'Error: The Agent and Task objects provided must be valid matlab objects')
             end

             FW.task = task;
             FW.agent = agent;
             
             if nargin > 2
                 FW.frameRecordList = {'curStimulus'; 'curAction'; 'curReward'; 'step'};
                 FW.agentRecordList = agentRecordList;
                 FW.taskRecordList = taskRecordList;

                 FW.file = file;
                
                 FW.recordData = true;
             else
                 FW.recordData = false;
             end
 
             %initialize the action for time step 0
             FW.curAction = zeros(FW.task.actionCount,1);
             FW.step = 0;
        end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %PUBLICALLY ACCESSIBLE METHODS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %A function which starts the processing of the current task and
        %agent configuration until the maximum duration or a task
        %termination condition is reached
        
        %INPUT
        %FW:    An instance to an initialized FrameSession object.
        function runSession(FW)
            %generate data stores
            if FW.recordData
                FrameStore = DataStore(FW, FW.frameRecordList, FW.task.duration * FW.task.samplingRate);
                TaskStore = DataStore(FW.task, FW.taskRecordList, FW.task.duration * FW.task.samplingRate);
                AgentStore = DataStore(FW.agent, FW.agentRecordList, FW.task.duration * FW.task.samplingRate);
            end

            %main simulation loop
            while (FW.step < (FW.task.duration * FW.task.samplingRate)) && (FW.task.EndOfTask() ~= 1)
                [FW.curStimulus, FW.curReward] = FW.task.validProcess(FW.curAction);

                FW.curAction = FW.agent.validProcess(FW.curStimulus, FW.curReward);

                %record data from each object

                if FW.recordData
                    FrameStore.record(FW.step);
                    TaskStore.record(FW.step);
                    AgentStore.record(FW.step);
                end

                FW.step = FW.step + 1;
            end

            if FW.recordData
                save(FW.file, 'FrameStore', 'TaskStore', 'AgentStore');
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %PROPERTIES USED BY FRAMEWORK. IGNORE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (GetAccess = protected, SetAccess = protected)
        curStimulus %the stimulus at the current time step
        curAction %the action at the current time step
        curReward %the reward at the current time step
        step %the current time step
        frameRecordList; %the list of frame variables to record, this is always equivalent to {'curStimulus'; 'curAction'; 'curReward'}

        recordData; %A flag variable indicating that nothing should be recorded
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %METHODS USED BY FRAMEWORK. IGNORE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        %A function which generate a size structure which describes the
        %recordable variables in FrameSession
        
        %INPUT
        %FW         An initialied instance of FrameSession
        
        %OUTPUT
        %sizeList   A structure describing the size of FrameSession
        %           variables to be recorded.
        function sizeList =  genSizeStruct(FW)
            
            if FW.task.stimulusCount ~= 1
                sizeList.curStimulus.type = 'Vector';
                sizeList.curStimulus.dimensions = [FW.task.stimulusCount, 1];
            else
                sizeList.curStimulus.type = 'Scalar';
                sizeList.curStimulus.dimensions = [1,1];
            end
            
            if FW.task.actionCount ~= 1
                sizeList.curAction.type = 'Vector';
                sizeList.curAction.dimensions = [FW.task.actionCount, 1];
            else
                sizeList.curAction.type = 'Scalar';
                sizeList.curAction.dimensions = [1,1];
            end
            
            sizeList.curReward.type = 'Vector';
            sizeList.curReward.dimensions = [FW.task.stimulusCount,1];
            
            sizeList.step.type = 'Scalar';
            sizeList.step.dimensions = [1,1];
        end
    end
    
    methods (Static)
        %A Function which determines if an instance of a task and an agent
        %are compatible by comparing the expected action and stimulus
        %vector lengths.
        
        %INPUT
        %task:  An initialized instance of the task to be ran
        %agent: An initialized instance of the agent to be ran
        
        %Output
        %r: Boolean whose value is 1 if the agent and task are compatible
        %   and 0 otherwise.
        r = compatible(task, agent);
        
        %A function which determines whether the provided object has a
        %super class whose name is equivalent to class.
        
        %INPUT
        %OBJ:   The initialized ovbject to be checked.
        %class: The string literal name of the class which will be checked
        %       to determine if it is  super class of OBJ
        
        %Output
        %r: Boolean whose value is 1 if the string literal class name class
        %   is a super class of OBJ, or 0 otherwise.
        r = isSubClass(OBJ, class);
    end
end