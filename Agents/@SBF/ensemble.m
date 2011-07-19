function population = ensemble(numMembers, minFrequency, maxFrequency, time, percentNoise, percentShift)

%A function which calculates the sinusoide resulting from the summation of
%an ensemble of oscilators with varying frequency described by frequency
%and percentNoise and a randomly computed phase shift between 0 and Pi.

%INPUT

%numMembers:        The number of oscilator ensembles.

%minFrequency:      The frequency of the ensemble member with the lowest
%                   frequency.

%maxFrequency:      The frequency of the ensemble member with the highest
%                   frequency.

%time:              The amount of time, in seconds, which each member
%                   of the ensemble is to be calculated for.

%percentNoise:      The maximum percentage by which the frequency can be either incremented
%                   or decrememnted by. A unique random value in this range will be generated at 
%                   run time for each member in the ensemble. Frequency noise is specified as a
%                   real number between the values of 0 and 1.

%OUTPUT

%population:        A numMembers by time array in which each row contains
%                   the cosine wave pertaining to a frequency in the range
%                   specied by minFrequency and maxFrequency for the
%                   durration specified by time.

%Input Value Error Checking

if numMembers <= 0 || isinf(numMembers) || isnan(numMembers)
    error('b:b', 'Error: Invalid Value for numMembers');
end

if minFrequency <= 0 || minFrequency > maxFrequency || isinf(minFrequency) || isnan(minFrequency)
    error('b:b', 'Error: Invalid Value for minFrequency');
end

if maxFrequency <= 0 || maxFrequency < minFrequency || isinf(minFrequency) || isnan(minFrequency)
    error('b:b', 'Error: Invalid Value for maxFrequency');
end

if time <= 0 || isinf(time) || isnan(time)
    error('b:b', 'Error: Invalid Value for time');
end

if percentNoise < 0 || percentNoise > 1 || isinf(percentNoise) || isnan(percentNoise)
    error('b:b', 'Error: frequencyNoise must be a real number between 0 and 1')
end

if percentShift < 0 || percentShift > 1 || isinf(percentShift) || isnan(percentShift)
    error('b:b', 'Error: Invalid Value for percentShift');
end

%initialize ensemble population
population = zeros(numMembers, time * 1000); %ensemble population cos waves
frequency = minFrequency:((maxFrequency - minFrequency)/(numMembers - 1)):maxFrequency;
time = 0:0.001:(time - 0.001); %array of timing values

for i = 1:numMembers
    phase = scaleRand(0,percentShift * pi);
    f  = frequency(i);
    fRange = f * percentNoise;
    f = scaleRand(f - fRange, f + fRange);
    
    population(i,:) = cos(2 * pi * f .*time + phase);
    population(i,:) = (0.5 .* population(i,:)) + 0.5; %comment out to remove shift and scaling
end

end

function r = scaleRand(minVal, maxVal)
% A function which produces a uniformly distributed random number between
% the valuse of minVal and maxVal inclusive

%INPUT

%minVal:    The minimum value of the desired random number.
%maxVal:    The maximum value of the desired random number.

%OUTPUT

%r:         a random value between minVal and maxVal

%error check
if (maxVal < minVal)
    error('B:B', 'Error: The Maximum Value must be greater than the Minimum Value')
end

if maxVal == minVal
    r = minVal;
    return;
end

oldRange = 1 - 0;
newRange = maxVal - minVal;

r = randn();

r = ((r  * newRange) / oldRange) + minVal;
end