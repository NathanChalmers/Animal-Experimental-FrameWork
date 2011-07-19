function weights = hebbian(population, criterion, minWeight, maxWeight)

%A function which learns the correct weights for the synapses of the
%corticol ensemble neurons onto the striatal nerurons via a hebbian
%learning rule.

%INPUT

%population:    An array containg the ensemble population. Each row
%               contains an ensemble neuron at an individual frequency
%               simulated for a previously specified time period

%criterion      The criterion time in seconds which the network is
%               attempting to learn.

%minWeight      the minimum weight value which a cortical-striatal synapse
%               can have.

%maxWeight      The maximum weight value which a cortical-striatal synapse
%               can have.


%OUTPUT

%weights       The weight values between minWeight and maxWeight learnt
%              through the hebbian learning process for each
%              cortico-striatal synapse.

%error checking

[numMembers, time] = size(population);

if isempty(population) || (numMembers == 1 && time == 1)
    error('b:b', 'Error: Population must be a two dimensional matrix');
end

criterion = criterion * 1000; %convert to miliseconds

if round(criterion) ~= criterion
    error('b:b', 'The criterion time when converted to miliseconds must be an integer value');
end

if criterion < 1 || criterion > time || isinf(criterion) || isnan(criterion)
    error('b:b', 'The Criterion Time must be within the range of the simulation time');
end

if minWeight > maxWeight || maxWeight < minWeight
    error('b:b', 'Error: minWeight must be less than maxWeight and maxWeight must be greater than minWeight respectively');
end

if isinf(minWeight) || isnan(minWeight)
    error('b:b', 'Error: minWeight must be a real number');
end

if isinf(maxWeight) || isnan(maxWeight)
    error('b:b', 'Error: maxWeight must be a real number');
end

%Select the cosine  value of the oscilation at criterion time to be the
%synaptic weight
weights = population(:,criterion);

%scale weight vector between minWeight and maxWeight
numWeights = size(weights,1);
minOld = min(weights);
maxOld = max(weights);
oldRange = maxOld - minOld;
newRange = maxWeight - minWeight;

for i = 1:numWeights
    weights(i,1) = (weights(i,1) / (oldRange / newRange)) + minWeight;
end