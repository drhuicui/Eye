function [weights]=make_multi_weights(edges,imgVals,imgVals2,valScale,valScale2,points,geomScale,alpha)
% This function is to generate the combined weight of 2 images for the graph. 
% function 'make_sep_weights' is the original makeweights by Leo Grady
% By Hui Cui 04/06/2014

%% make valDistances and geomDistances according to the original code

[geomDistances,valDistances]=make_sep_weights(edges,imgVals,valScale,points,geomScale);
[geomDistances2,valDistances2]=make_sep_weights(edges,imgVals2,valScale2,points,geomScale);

%% whole weights
sum_geomDistance=alpha.*geomDistances+alpha.*geomDistances2;
sum_valDistance=(1-alpha).*valDistances+(1-alpha).*valDistances2;

EPSILON = 1e-5;
weights=exp(-(geomScale*sum_geomDistance + valScale*sum_valDistance))+...
    EPSILON;