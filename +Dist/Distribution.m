% A random number generator for a specific distribution.
classdef Distribution < handle
    methods (Abstract)
        % Sample the distribution
        sample = getSample(D)
    end
end

%% Francois Rivest 2010
% 20100512 - Basic interface
% 20110516 - Fixes for Dist. package