%% Sampling from an exponential distribution (see exprnd)
classdef ExpDist < Dist.Distribution
    properties (Hidden)
        Mean;
    end
    methods 
        % Constructor
        %   args: Mean   Distribution mean
        function ED = ExpDist(Mean)
            ED.Mean = Mean;
        end
        % Sample the distribution
        function sample = getSample(ED)
            sample = exprnd(ED.Mean);
        end
    end
end

%% Francois Rivest 2010
% 20100512
% 20110516 - Fixes for Dist. package
