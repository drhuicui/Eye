
clear all;
close all;

% run('K:\Matlab\vlfeat-0.9.21-bin\vlfeat-0.9.21\toolbox\vl_setup')

%% settings
para.beta  =  60;   % the variance of the color differences
para.beta2  =  60;   % the variance of the prior differences

alpha=0.75; % prior intensity weight. greater alpha, greater intensity.
geoScale=0; % 0= without distance consideration
full_connect=0;% 0 4-neighbouring connection
type_of_seed = 0; % 0: scribbles or 1: trimatp
%% super pixel parameters
ratio = 0.5;
kernelsize = 2;
maxdist = 15;
%% folders
Diskroot='K:\';% SIT
imagesRoot = strcat(Diskroot,'Matlab\Eye\images\');% all uncropped images
scribblesRoot=strcat(Diskroot,'Matlab\Eye\scribbles\');% all uncropped images
OutputRoot=strcat(Diskroot,'Matlab\Eye\results\');
if isempty (OutputRoot)
    mkdir(OutputRoot);
end
%% pre-generated super pixels
SP_Path='.\MeanShiftdata\';
%% read images
FileList = dir(fullfile(imagesRoot));
FileList(1:2)=[];
% find case name
for i=1:length(FileList)
    file_name=FileList(i).name;
    [~,only_name,~] = fileparts(file_name);
    %% load images
    ImageDir = strcat(imagesRoot,file_name);
    SeedDir=strcat(scribblesRoot,file_name);
    %% output Dir
    OutputDir_PM=strcat(OutputRoot,'RGB_BPrior\');mkdir(OutputDir_PM);
    %%
    img_read = imread(ImageDir);
    %% generate super pixels & regional edge
    sp_path = [OutputDir_PM 'regions\']; mkdir(sp_path);
    save_data_path=[SP_Path only_name '\']; mkdir(save_data_path);
    datafile=[save_data_path only_name '_' int2str(ratio) '_' int2str(kernelsize) '_' int2str(maxdist) '.mat'];
    if exist(datafile,'file')==0
        [Label_Map,seg_idx,seg_vals,seg_edges,seg_points,Iseg] = msseg_MS_eye(img_read,ratio,kernelsize,maxdist,full_connect);
        [imgMasks,segOutline,imgMarkup]=segoutput(im2double(img_read),double(Label_Map));
        imwrite(imgMarkup, [sp_path only_name,'.bmp']);
        imwrite(Iseg, [sp_path only_name,'_mean.bmp']);
        save(datafile,'Label_Map','seg_idx','seg_vals','seg_edges','seg_points','Iseg');
        clear imgMasks segOutline imgMarkup;
    else
        load(datafile);
        [imgMasks,segOutline,imgMarkup]=segoutput(im2double(img_read),double(Label_Map));
        imwrite(imgMarkup, [sp_path only_name,'.bmp']);
        imwrite(Iseg, [sp_path only_name,'_mean.bmp']);
    end
    %% do segmentation
    %% read the seeds
    Seeds_Image=imread(SeedDir);
    [K, labels, seeds_idx] = seed_generation_forEye(Seeds_Image,Label_Map);% also consider superpixel
    %% segmentation
    [mask,probabilities1,gmm_P] = prior_random_walker_eye(img_read,seeds_idx,labels,para.beta,para.beta2,alpha,geoScale);
    %% save results
    OutputDir_PM_sub=[OutputDir_PM '/Pixel_LvL/']; mkdir(OutputDir_PM_sub);
    save_data_path=[OutputDir_PM_sub  'Bprior/']; mkdir(save_data_path);
    imwrite(sc(gmm_P,'jet'),[save_data_path only_name,'.bmp' ]);
    save_2results(img_read,OutputDir_PM_sub,only_name,probabilities1,mask);
    %% use superpixel maps as input image
    [mask,probabilities2,gmm_P] = prior_random_walker_eye(Iseg,seeds_idx,labels,para.beta,para.beta2,alpha,geoScale);
    OutputDir_PM_sub=[OutputDir_PM '/Region_LvL/']; mkdir(OutputDir_PM_sub);
    save_data_path=[OutputDir_PM_sub 'Bprior/']; mkdir(save_data_path);
    imwrite(sc(gmm_P,'jet'),[save_data_path only_name,'.bmp' ]);
    save_2results(img_read,OutputDir_PM_sub,only_name,probabilities2,mask);
    %% see joint
    probabilities3=probabilities1.*probabilities2;
    [dummy,mask]=max(probabilities3,[],3);

    OutputDir_PM_sub=[OutputDir_PM '/Region_Pixel/']; mkdir(OutputDir_PM_sub);
    save_2results(img_read,OutputDir_PM_sub,only_name,probabilities3,mask);
    
end
% end
