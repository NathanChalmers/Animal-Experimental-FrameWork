%% Sampling from an exponential distribution (see exprnd)
% A minimal offset is added and the exp dstribution is bounded
classdef BoundedExpDist < Dist.Distribution
    properties (Hidden)
        Mean;
        Offset;
        Bound;
    end
    methods 
        % Constructor
        %   args: Mean   Distribution mean
        %         Offset Minimal value added to the exp sample
        %         Bound  Upper bound on the exp sample (without offset)
        function ED = BoundedExpDist(Mean, Offset, Bound)
            ED.Mean = Mean;
            ED.Offset = Offset;
            ED.Bound = Bound;
        end
        % Sample the distribution
        function sample = getSample(ED)
            sample = ED.Offset + min(exprnd(ED.Mean), ED.Bound);
        end
    end
end

%% Francois Rivest 2010
% 20100520
% 20110516 - Fixes for Dist. package
