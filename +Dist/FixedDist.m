%% Sampling from a single fixed value distribution
classdef FixedDist < Dist.Distribution
    properties (Hidden)
        Value;
    end
    methods 
        % Constructor
        %   args: Value    Fixed sample value
        function FD = FixedDist(Value)
            FD.Value = Value;
        end
        % Sample the distribution
        function sample = getSample(FD)
            sample = FD.Value;
        end
    end
end

%% Francois Rivest 2010
% 20100512
% 20110516 - Fixes for Dist. package
