function [T]=model_likelihood_VbGM(img,seeds_idx,labels,k)

label_idx = find(labels(:)==k);
[a,b]=size(label_idx);
grd=seeds_idx(label_idx(:));% location of seeds labelded as k
[X,Y,Z]=size(img);
if(Z > 1) %Color images
    tmp=img(:,:,1);
    imgVals=tmp(:);
    fgrd=tmp(grd(:));
    tmp=img(:,:,2);
    imgVals(:,2)=tmp(:);
    fgrd(:,2)=tmp(grd(:));
    tmp=img(:,:,3);
    imgVals(:,3)=tmp(:);
    fgrd(:,3)=tmp(grd(:));
else
    imgVals=img(:);
    fgrd=imgVals(grd(:));
end
% k=2;

%% foreground a by Variational Bayesian for Gaussian Mixture Model
[label, model, ~] = mixGaussVb(fgrd',10);
% [label, model, llh] = emgm_ch(fgrd',nbStates);
% mu=model.mu;Sigma=model.Sigma;w = model.weight;
% n = length(imgVals);
% k = size(mu,2);
% logRho = zeros(n,k);
% %Compute the log likelihood
% for i = 1:k
%     logRho(:,i) = loggausspdf(imgVals',mu(:,i),Sigma(:,:,i));
% end
% logRho = bsxfun(@plus,logRho,log(w));
% T = logsumexp(logRho,2);
[y2, R] = mixGaussVbPred(model,imgVals');
T = logsumexp(R,2);
% T_show=reshape(T,[X,Y]);
function y = loggausspdf(X, mu, Sigma)
d = size(X,1);
X = bsxfun(@minus,X,mu);
[U,p]= chol(Sigma);
if p ~= 0
    error('ERROR: Sigma is not PD.');
end
Q = U'\X;
q = dot(Q,Q,1);  % quadratic term (M distance)
c = d*log(2*pi)+2*sum(log(diag(U)));   % normalization constant
y = -(c+q)/2;