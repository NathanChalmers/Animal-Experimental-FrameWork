classdef SBFTask < Task
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        
        function TK = SBFTask(samplingRate, stimulusCount, actionCount, duration, paramStruct)
           TK = TK@Task(samplingRate, stimulusCount, actionCount, duration);
        end
        
        function [stimulus, reward] = process(TK, action)
            stimulus = 0;
            reward = 0;
        end
        
        function [stimulus, reward] = processNoAction(TK)
            stimulus = 0;
            reward = 0;
        end
        
        function sizeList = genSizeStruct(TK)
            sizeList.EOT.type = 'Scalar';
            sizeList.EOT.dimensions = [1,1];
        end
    end
    
end

