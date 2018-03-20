function [mask,probabilities,gmm_show1] = prior_random_walker_eye(img_read,seeds,labels,beta,beta2,alpha,geoScale)
%Inputs: img - The image to be segmented
%        seeds - The input seed locations (given as image indices, i.e., 
%           as produced by sub2ind)
%        labels - Integer object labels for each seed.  The labels 
%           vector should be the same size as the seeds vector.
%        beta - Optional weighting parameter (Default beta = 90)
%
%Output: mask - A labeling of each pixel with values 1-K, indicating the
%           object membership of each pixel
%        probabilities - Pixel (i,j) belongs to label 'k' with probability
%           equal to probabilities(i,j,k)
%Find image size
EPSILON=1e-5;
img=im2double(img_read);

[X,Y,Z]=size(img);N=X*Y;
%Build graph
[points,edges]=lattice(X,Y);
%% Generate weights and Laplacian matrix
if(Z > 1) %Color images
    tmp=img(:,:,1);
    imgVals=tmp(:);
    tmp=img(:,:,2);
    imgVals(:,2)=tmp(:);
    tmp=img(:,:,3);
    imgVals(:,3)=tmp(:);
else
    imgVals=img(:);
end
%% image weight with Prior intensity distribution
% GMM modeling
[prior_B]=model_likelihood_VbGM(img,seeds,labels,K);
K=1;% model background=2, model foreground, p=1;
[prior_F]=model_likelihood_VbGM(img,seeds,labels,K);
prior_B=normalize(prior_B);
prior_F=normalize(prior_F);
prior_P=1-prior_B;
prior_P1=reshape(prior_P,X,Y);
%%
figure(3),subplot(2,2,1),imshow(img);
subplot(2,2,2),imagesc(prior_P1);
subplot(2,2,3),imagesc(reshape(prior_F,X,Y));
subplot(2,2,4),imagesc(reshape(prior_B,X,Y));

%%
Prior=(prior_P);
Prior=normalize(Prior);
gmm_show1=reshape(Prior,X,Y);
weight_i=make_multi_weights(edges,imgVals,Prior,beta,beta2,points,geoScale,alpha);
%% revised adjacency matrix
weight_f=weight_i;
L=laplacian(edges,weight_f);
%% Determine which label values have been used
label_adjust=min(labels); labels=labels-label_adjust+1; %Adjust labels to be > 0
labels_record(labels)=1;
labels_present=find(labels_record);
number_labels=length(labels_present);
%% Set up Dirichlet problem
boundary=zeros(length(seeds),number_labels);
for k=1:number_labels
    boundary(:,k)=(labels(:)==labels_present(k));
end

%% Solve for random walker probabilities by solving combinatorial Dirichlet
probabilities=dirichletboundary(L,seeds(:),boundary);
%Generate mask
[dummy mask]=max(probabilities,[],2);
mask=labels_present(mask)+label_adjust-1; %Assign original labels to mask
mask=reshape(mask,[X Y]);
probabilities=reshape(probabilities,[X Y number_labels]);

