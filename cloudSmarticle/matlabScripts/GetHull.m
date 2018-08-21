function [b,solidity,CH,BW] = GetHull(I,h)
%%

% close all; clear all; clc;
% subplot(2,2,1);
% I = imread('A:\SmarticleAreaFractionData\smart3.jpg');
% imshow(I);
% title('Original');

% subplot(2,2,2);

I = rgb2gray(I);

BW = I > 70;
% BW1=BW;
R = 8; N = 8;
SE = strel('disk',R,N);
% 


BW = imclose(BW,SE);
% BW = imdilate(BW,SE);
% BW = imerode(BW,SE);
BW = bwareaopen(BW, 15);
% BW = imclose(BW,SE);

% clf;
% imshow(BW);



CH = bwconvhull(BW);


bwArea = sum(BW(:));
chArea = sum(CH(:));
solidity = bwArea/chArea;

% subplot(2,2,4);
% b = cell2mat(bwboundaries(CH));
b = cell2mat(bwboundaries(CH));
% imshow(BW);
% title('Image Convex Hull');
% hold on
% plot(b{1}(:,2), b{1}(:,1), 'r')
% text(0,0,['Solidity = ' num2str(solidity)], 'Color', 'w', 'VerticalAlignment', 'top');



end

