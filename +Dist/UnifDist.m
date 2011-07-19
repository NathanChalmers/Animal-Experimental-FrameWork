%% Sampling from a uniform distribution (see unifrnd)
classdef UnifDist < Dist.Distribution
    properties (Hidden)
        Min;
        Max;
    end
    methods 
        % Constructor
        %   args: Min    Distribution lower bound 
        %         Max    Distribution upper bound 
        function UD = UnifDist(Min, Max)
            UD.Min = Min;
            UD.Max = Max;
        end
        % Sample the distribution
        function sample = getSample(UD)
            sample = unifrnd(UD.Min, UD.Max);
        end
    end
end

%% Francois Rivest 2010
% 20100512
% 20110516 - Fixes for Dist. package
