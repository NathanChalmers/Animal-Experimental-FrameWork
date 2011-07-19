function compatible(task, agent)

if (task.stimulusCount ~= agent.stimulusCount)
    error('FrameTrial:compatible', 'Error: Task and Agent stimulusCount mismatch');
end

if (task.actionCount ~= agent.actionCount)
    error('FrameTrial:compatible', 'Error: Task and Agent actionCount mismatch');
end
