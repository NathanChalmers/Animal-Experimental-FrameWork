function input = striatalInput(population, weights)

%a function which calculates the striatal input for each instance of time
%as determined by the population input and the cortico-striatal synapse
%veigt vector

%INPUT

%population:    An array containg the ensemble population. Each row
%               contains an ensemble neuron at an individual frequency
%               simulated for a previously specified time period

%weights:       The cortico-striatal synapse weights learnt via the
%               specified hebbian learning rule.

%OUTPUT

%input:         A vector whose length is equal to the simulation time. Each
%               element contains the calculated cortico-strial input the
%               coresponding time period.

%error checking
[numMembers, time] = size(population);

if isempty(population) || (numMembers == 1 && time == 1)
    error('b:b', 'Error: Population must be a two dimensional matrix');
end

if size(weights, 1) ~= numMembers || size(weights,2) ~= 1
    error('b:b', 'Error: The weight vector must match the population size');
end

%Apply synaptic weights to oscilators
for i = 1:time
    population(:,i) = population(:,i) .* weights;
end

input = sum(population);
input = input';