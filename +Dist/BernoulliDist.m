%% Sampling from a Bernoulli distribution (two values) 
% with probabilities p and 1-p
% 
classdef BernoulliDist < Dist.Distribution
    properties (Hidden)
        Means;
        Prob;
    end
    methods 
        % Constructor
        %   args: Means  The two means (the two possible outcome)
        %         Prob  Probability of the first outcome (the second is 1-p)
        function BD = BernoulliDist(Means, Prob)
            BD.Means = Means;
            BD.Prob = Prob;
        end
        % Sample the distribution
        function sample = getSample(BD)
            x = rand();
            if x < BD.Prob
                sample = BD.Means(1);
            else
                sample = BD.Means(2);
            end
        end
    end
end

%% Francois Rivest 2011
% 20110224 
% 20110516 - Fixes for Dist. package
