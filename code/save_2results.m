function save_2results(img,OutputDir,name,probabilities,mask)

K=size(probabilities,3);
outputDir_p=[OutputDir '\prop\'];
mkdir(outputDir_p);

for k=1:K
    outputDir_k=[outputDir_p '\' int2str(k) '\'];
    mkdir(outputDir_k);
    % save prob map for further evaluation
    if K~=1
        prob_map=probabilities(:,:,k);
        prob_img = sc(probabilities(:,:,k),'prob_jet');
    else
        prob_map=probabilities;
        prob_img = sc(probabilities,'prob_jet');
    end
    %   
    % save prob map in color version
    imwrite(prob_img, [outputDir_k name '.bmp']);
    clear prob_img;clear prob_map;
end
% save contours on CT
[imgMasks,segOutline,imgMarkup]=segoutput_c(img,mask);
outputDir_c=[OutputDir '\contours\'];
mkdir(outputDir_c);
imwrite(imgMarkup, [outputDir_c name '.bmp']);

%% save mask
outputDir_m=[OutputDir '\mask\'];

mkdir(outputDir_m);

label_img = mask;
label_img(label_img==1)=255;
label_img=uint8(label_img);% double image should be converted to int8 for writing
imwrite(label_img, [outputDir_m name '.bmp']);
