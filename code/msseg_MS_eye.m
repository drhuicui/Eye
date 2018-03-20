
%------------------------------------------------------------------------

function [labels,seg,seg_vals,seg_edges,seg_points,Iseg] = msseg_MS_eye(img,ratio,kernelsize,maxdist,full)

[Iseg,labels,~,~,~] = vl_quickseg(img, ratio, kernelsize, maxdist);% Iseg: an image with mean intensity values for each SP. % labels: label map

% L=labels;
[X,Y,Z] = size(img); nseg = max(labels(:)); vals = reshape(img,X*Y,Z);
if full == 1
    [x,y] = meshgrid(1:nseg,1:nseg);
    seg_edges = [x(:) y(:)];
else
    [seg_points,edges]=lattice(X,Y,0);    clear points;
    d_edges = edges(labels(edges(:,1))~=labels(edges(:,2)),:);
    all_seg_edges = [labels(d_edges(:,1)) labels(d_edges(:,2))]; all_seg_edges = sort(all_seg_edges,2);
    
    tmp = zeros(nseg,nseg);
    tmp(nseg*(all_seg_edges(:,1)-1)+all_seg_edges(:,2)) = 1;
    [edges_x,edges_y] = find(tmp==1); seg_edges = [edges_x edges_y];
end

seg_vals = zeros(nseg,Z);

for i=1:nseg
    seg{i} = find(labels(:)==i);
    seg_vals(i,:) = mean(vals(seg{i},:));
    
end


