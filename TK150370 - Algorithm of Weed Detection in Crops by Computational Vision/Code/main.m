clc;
clear
close all hidden;
warning off;
%%
%%%%%%%%%% Image selection
[filename, pathname] = uigetfile({'*.jpg'}, 'Select a image file');

img = imread(fullfile(pathname, filename));
figure,
imshow(img);
title('original image');

%%%%%%%% RGB to Gray
img_gray = rgb2gray(img);

%%%%%%%% Extracting RGB components
redChannel = img(:,:,1); 
greenChannel = img(:,:,2);
blueChannel = img(:,:,3);

%%%%%%%% Subtracting Gray component from green component
img_subtract = greenChannel-img_gray;
figure,
imshow(img_subtract);
title('substraction of image');

%%%%%%%%% Denoising using medium filter
img_filtered = medfilt2(img_subtract);
figure,
imshow(img_filtered);
title('median filtered image');

%%%%%%%%%% Threshold segmentation
thresh_value = graythresh(img_filtered);
img_bw = im2bw(img_filtered, thresh_value);
figure,
imshow(img_bw);
title('Threshold segmentation');

%%%%%%%%%%% Morphological operations
BW2 = imfill(img_bw,'holes');
figure, 
imshow(BW2);
title('Image with filled holes');

W=bwmorph(BW2,'remove');
figure,
imshow(W);
title('morphological operation');

%%%%%%%%%%% labeled image
R = bwlabel(W);
figure,
imshow(R);
title('labelling image');

%%%%%%%% Removing small objects
small_region = bwareaopen(R,2);
figure,
imshow(small_region);
title('Removing small objects');

region_img = regionprops(small_region, 'BoundingBox','Area');
region_img(2);

region = extractfield(region_img,'Area');

avg=mean(region,'all');

figure;
imshow(img);
hold on;

%%%%%% Applying bounding box 
for i=1:numel(region_img)
if region(i) < avg
     BB = region_img(i).BoundingBox;
     rectangle('Position', [BB(1),BB(2),BB(3),BB(4)],'EdgeColor','r','LineWidth',2) ;
else
end
end
title('weed detection');

%%%%%%%% Parameters calculations
gt_bw = im2bw(img);

tp = sum(sum(gt_bw & small_region)) * 100;
tn = sum(sum(~gt_bw & ~small_region));
fp = sum(sum(~gt_bw & small_region));
fn = sum(sum(gt_bw & ~small_region));

sensitivity = tp / (tp + fn) * 100;
fprintf('Sensitivity: %.2f\n', sensitivity);

specificity = tn / (tn + fp) * 100;
fprintf('Specificity: %.2f\n', specificity);

Positive_predictive_value= tp / (tp + fp) * 100

Negative_predictive_value= tn / (tn + fn) * 100

%%