%% Sampling from a bounded Gaussian distribution (see normrnd)
classdef BoundedNormDist < Dist.Distribution
    properties (Hidden)
        Mu;
        Sigma;
        Min;
        Max;
    end
    methods 
        % Constructor
        %   args: Mu        Distribution mean 
        %         Sigma     Distribution standard deviation
        %         Min       Distribution lower bound 
        %         Max       Distribution upper bound 
        function ND = BoundedNormDist(Mu, Sigma, Min, Max)
            ND.Mu = Mu;
            ND.Sigma = Sigma;
            ND.Min = Min;
            ND.Max = Max;
        end
        % Sample the distribution
        function sample = getSample(ND)
            x = 1;
            while x
                sample = normrnd(ND.Mu, ND.Sigma);
                if (sample > ND.Min) && (sample < ND.Max)
                    x = 0;
                end
            end
        end
    end
end

%% Francois Rivest 2010
% 20100531
% 20110516 - Fixes for Dist. package
