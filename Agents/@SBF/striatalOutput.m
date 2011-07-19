function [output, threshold, constOut] = striatalOutput(input, thresholdInitial, reducePercentage, reduceTime, recoveryTime)

%A function which calculates whether the striatal neuron will fire as a
%function of cortical input and a variable threshold level whose maximum
%value is threshold but can be reduced by a percentage describe in
%reduction.

%INPUT

%input                 A vector whose length is that of the simulation time
%                      and contains the striatal input for each instance of
%                      time

%thresholdInitial      The initial resting threshold of the striatal neuron

%reducePercentage      The percent by which the original threshold will be
%                      reduced in a linear manner after a striatal spike.

%reduceTime            The amount of time required for the threshold to
%                      lineraly decrese from the initial threshold to the
%                      reduced threshold after a striatal spike. Reduce
%                      time is specified in seconds.

%recoveryTime          The amount of time required for the threshold to recover to
%                      the initial threshold value after a period of
%                      inactivity in the striatal neuron defined by reduce
%                      time. Recovery time is specified in seconds.

%OUTPUT

%output                A binary vector whose value is either 0 to indicate
%                      absence of a striatal spike or 1 to indicate the
%                      presence of a striatal spike.

reduceTime = reduceTime * 1000;
recoveryTime = recoveryTime * 1000;
thresholdReduction = thresholdInitial - (reducePercentage * thresholdInitial);

reduceStep = (thresholdInitial - thresholdReduction) / (reduceTime - 1);
recoveryStep = (thresholdInitial - thresholdReduction) / (recoveryTime - 1);

reduceClock = 0;
recoveryClock = 0;

time = size(input,1);
output = zeros(time,1);
threshold = zeros(time,1);
constOut = zeros(time,1);
curThreshold = thresholdInitial;


for i = 1:time
    %correct the current threshold value in the event that the recovery
    %process over shoots the initial threshold value.
    if reduceClock == 0 && recoveryClock == 0 && curThreshold ~= thresholdInitial
        curThreshold = thresholdInitial;
    end
    
    %determine if we have to reduce the threshold
    if curThreshold > thresholdReduction && reduceClock > 0
        curThreshold = curThreshold - reduceStep;
        reduceClock = reduceClock - 1;
        
    elseif curThreshold <= thresholdReduction && reduceClock > 0
        reduceClock = reduceClock - 1;
    end
    
    %determine if we can switch from reduction to recovery
    if reduceClock == 0 && recoveryClock == 0 && curThreshold < thresholdInitial
        recoveryClock = recoveryTime;
    end
    
    %determine if we have to increase the threshold
    if curThreshold < thresholdInitial && recoveryClock > 0
        curThreshold = curThreshold + recoveryStep;
        recoveryClock = recoveryClock - 1;
        
    elseif curThreshold >= thresholdInitial && recoveryClock > 0
        recoveryClock = recoveryClock - 1;
    end
    
    %write threshold value to result vector
    threshold(i, 1) = curThreshold;
    
    %determine if the neuron spikes
    if input(i, 1) > curThreshold
        output(i,1) = 1;
        recoveryClock = 0;
        reduceClock = reduceTime;
    end
    
    if input(i,1) > thresholdInitial
        constOut(i,1) = 1;
    end
end