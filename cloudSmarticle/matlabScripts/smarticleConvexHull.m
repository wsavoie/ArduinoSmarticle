%%

close all; clear all; clc;
subplot(2,2,1);
I = imread('A:\SmarticleAreaFractionData\smart3.jpg');
imshow(I);
title('Original');

subplot(2,2,2);

I = rgb2gray(I);

BW1 = I < 124;
R = 4; N = 4;
SE = strel('disk',R,N)
BW = imdilate(BW1,SE);
% BW = imerode(BW,SE);
% BW = imdilate(BW,SE);
BW = imerode(BW,SE);

R = 8; N = 8;
SE = strel('disk',R,N)

BW = imdilate(BW,SE);
% BW = imerode(BW,SE);
% BW = imdilate(BW,SE);
BW = imerode(BW,SE);
BW = imerode(BW,SE);


% J = regionfill(I,x,y);

% BW = BW1;

imshow(BW);
title('Closed Binary Image');

subplot(2,2,3);
CH = bwconvhull(BW);
imshow(CH);
title('Union Convex Hull');

bwArea = sum(BW(:));
chArea = sum(CH(:));
solidity = bwArea/chArea;

subplot(2,2,4);
b = bwboundaries(CH);
imshow(BW);
title('Image Convex Hull');
hold on
plot(b{1}(:,2), b{1}(:,1), 'r')
text(0,0,['Solidity = ' num2str(solidity)], 'Color', 'w', 'VerticalAlignment', 'top');

