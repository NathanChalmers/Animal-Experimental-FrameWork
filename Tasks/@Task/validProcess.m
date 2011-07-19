function [stimulus, reward] = validProcess(TK, action)

if (length(action) ~= TK.actionCount)
    error('Task:validProcess', 'Error: Action is of the incorrect length');
end


try
    [stimulus, reward] = TK.process(action);
catch err
    for i = 1:TK.actionCount
        if isinf(action(i)) || isnan(action(i))
            error('Task:validProcess', 'Error: Action contains an invalid element');
        end
    end
    
    error('Task:ValidProces', 'Error: An unknown error occured while running Task.Process');
end

if (length(stimulus) ~= TK.stimulusCount)
    error('Task:validProcess', 'Error: Stimulus is of the incorrect length');
end

