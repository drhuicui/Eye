function [geomDistances,valDistances]=make_sep_weights(edges,vals,valScale,points,geomScale,EPSILON)
% Return geom and val distances seperately
%
%01/03/13 - Hui Cui
%
%========================================================================%

%Constants
if nargin < 6
    EPSILON = 1e-5;
end



%Compute intensity differences
if valScale > 0
    valDistances=sqrt(sum((vals(edges(:,1),:)- ...
        vals(edges(:,2),:)).^2,2));
    valDistances=normalize(valDistances); %Normalize to [0,1]
else
    valDistances=zeros(size(edges,1),1);
    valScale=0;
end

%Compute geomDistances, if desired
if geomScale > 0
    geomDistances=sqrt(abs(sum((points(edges(:,1),:)- ...
        points(edges(:,2),:)).^2,2)));
    geomDistances=normalize(geomDistances); %Normalize to [0,1]
    
else
    
    geomDistances=zeros(size(edges,1),1);
    geomScale=0;
end

%Compute Gaussian weights
% weights=exp(-(geomScale*(1-a)*geomDistances + valScale*(1-a)*valDistances+a*priorTerm))+...
%      EPSILON;
