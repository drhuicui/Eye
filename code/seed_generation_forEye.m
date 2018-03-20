function [nlabels, labels, idx] = seed_generation_forEye(ref,label_Map)
label_Map=double(label_Map);

%% remove the circle boundary of image
ind_black=label_Map;ind_black(ind_black~=1)=0;ind_black=1-ind_black;
se = strel('disk',5);
J = imerode(ind_black,se);
mask=zeros(size(label_Map,1),size(label_Map,2),3);
mask(:,:,1)=J;mask(:,:,2)=J;mask(:,:,3)=J;

ref2=im2double(ref).*mask;

%% find foreground seed
temp_F_ind = ref2(:,:,1)<=0.05 & ref2(:,:,2)>=0.98 & ref2(:,:,3)<=0.05;
F_Map=double(zeros(size(label_Map)));
F_Map(temp_F_ind)=1;

%% find foreground seeds on super pixel map
F_Map_SP=F_Map.*label_Map;
% figure,imshow(F_Map_SP,[]);
un=unique(F_Map_SP);
SP_maks=zeros(size(label_Map,1),size(label_Map,2));
for i=1:length(un)
    v=un(i);
    tempind= label_Map==v;
    SP_maks(tempind)=1;
end
figure(1),subplot(1,2,1),imshow(SP_maks,[]);
L{1}=find(SP_maks==1);

%% find backgroud seed
temp_B_ind= ref2(:,:,1)<=0.05 & ref2(:,:,2)<=0.05 & ref2(:,:,3)>=0.98;
B_Map=double(zeros(size(label_Map)));
B_Map(temp_B_ind)=1;

%% find background seeds on super pixel map
B_Map_SP=B_Map.*label_Map;
% figure,imshow(F_Map_SP,[]);
un=unique(B_Map_SP);
SP_maks=zeros(size(label_Map,1),size(label_Map,2));
for i=1:length(un)
    v=un(i);
    tempind= label_Map==v;
    SP_maks(tempind)=1;
end
figure(1),subplot(1,2,2),imshow(SP_maks,[]);
L{2} = find(SP_maks==1);
%% re-organize seeds for random walk algorithm
num = 0;
nlabels = 0;
for i=1:size(L,2)
    nL = size(L{i},1);
    if nL > 0
        nlabels = nlabels + 1;
        labels(num+1:num+nL) = nlabels;
        idx(num+1:num+nL) = L{i};
        num = num + nL;
    end
end
