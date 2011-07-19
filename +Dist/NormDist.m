%% Sampling from a Gaussian distribution (see normrnd)
classdef NormDist < Dist.Distribution
    properties (Hidden)
        Mu;
        Sigma;
    end
    methods 
        % Constructor
        %   args: Mu       Distribution mean 
        %         Sigma    Distribution variance
        function ND = NormDist(Mu, Sigma)
            ND.Mu = Mu;
            ND.Sigma = Sigma;
        end
        % Sample the distribution
        function sample = getSample(ND)
            sample = normrnd(ND.Mu, ND.Sigma);
        end
    end
end

%% Francois Rivest 2010
% 20100531
% 20110516 - Fixes for Dist. package
