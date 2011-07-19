classdef SBF <  Agent
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        simInput
        simOutput
        simThreshold
        curInput
        curOutput
        curThreshold
        curStep
        numMembers
        
        testMatrix
        testVector
        testString
    end
    
    methods (Static)
        population = ensemble(numMembers, minFrequency, maxFrequency, time, percentNoise, percentShift)
        weights = hebbian(population, criterion, minWeight, maxWeight)
        input = striatalInput(population, weights)
        [output, threshold, constOut] = striatalOutput(input, thresholdInitial, reducePercentage, reduceTime, recoveryTime)
    end
    
    methods
        function ag = SBF(samplingRate, stimulusCount, actionCount, paramStruct)
            ag = ag@Agent(samplingRate, stimulusCount, actionCount);
            
            population = SBF.ensemble(paramStruct.numMembers, paramStruct.minFrequency, paramStruct.maxFrequency, paramStruct.time, 0, 0);
            weights = SBF.hebbian(population, paramStruct.criterion, -1, 1);
            
            ag.simInput = SBF.striatalInput(population, weights);
            [ag.simOutput, ag.simThreshold] = SBF.striatalOutput(ag.simInput, paramStruct.threshold, 0.3, 0.4, 2);
            
            ag.curInput = NaN;
            ag.curOutput = NaN;
            ag.curThreshold = NaN;
            ag.curStep = 0;
            ag.numMembers = paramStruct.numMembers;
            ag.testMatrix = NaN;
            ag.testVector = NaN;
            ag.testString = {};
        end
        
        function reset(ag)
            ag.curStep = 0;
        end
        
        function action = process(ag, stimulus, reward)
            ag.curStep = ag.curStep + 1;
            ag.curInput = ag.simInput(ag.curStep);
            ag.curOutput = ag.simOutput(ag.curStep);
            ag.curThreshold = ag.simThreshold(ag.curStep);
            
            ag.testMatrix = zeros(5,2) + ag.curStep;
            ag.testVector = zeros(1,5) + ag.curStep;
            ag.testString = sprintf('Test String: %d', ag.curStep);
            
            action = ag.curOutput;
        end
        
        function sizeList = genSizeStruct(AG)
            sizeList.curInput.type = 'Scalar';
            sizeList.curInput.dimensions = [1,1];
            
            sizeList.curOutput.type = 'Scalar';
            sizeList.curOutput.dimensions = [1,1];
            
            sizeList.curThreshold.type = 'Scalar';
            sizeList.curThreshold.dimensions = [1,1];
            
            sizeList.testMatrix.type = 'Matrix';
            sizeList.testMatrix.dimensions = [5,2];
            
            sizeList.testVector.type = 'Vector';
            sizeList.testVector.dimensions = [5,1];
            
            sizeList.testString.type = 'String';
            sizeList.testString.dimensions = [1,1];
        end
    end
    
end

