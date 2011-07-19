function action = validProcess(AG, stimulus, reward)

if (AG.stimulusCount ~= length(stimulus))
    error('Agent:validStimuls', 'Error: The stimulus vector length does not match the expected length');
end

try
    action = AG.process(stimulus, reward);
catch err
    for i = 1:AG.stimulusCount
        if isinf(stimulus(i)) || isnan(stimulus(i))
            error('Agent:validStimulus', 'Error: One of the elements of the stimulus vector is invalid');
        end
    end
    
    error('Agent:Process', 'Error: An Unknown error occured while running Agent.process')
end

if (AG.actionCount ~= length(action))
    error('Agent:validStimuls', 'Error: The action vector length does not match the expected length');
end