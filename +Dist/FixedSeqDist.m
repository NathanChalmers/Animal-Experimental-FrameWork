%% Sampling from a single fixed value distribution
classdef FixedSeqDist < Dist.Distribution
    properties (Hidden)
        Value;
        i;
    end
    methods 
        % Constructor
        %   args: Value    Fixed sample value
        function FD = FixedSeqDist(Value)
            FD.Value = Value;
            FD.i = 1;
        end
        % Sample the distribution
        function sample = getSample(FD)
            sample = FD.Value(FD.i);
            FD.i = mod(FD.i, length(FD.Value)) + 1;
        end
    end
end

%% Francois Rivest 2011
% 20110512
% 20110516 - Fixes for Dist. package
