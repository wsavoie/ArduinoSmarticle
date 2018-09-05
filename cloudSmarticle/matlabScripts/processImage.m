function [solidity,area,p] = processImage(I,h)
%PROCESSIMAGE Summary of this function goes here
%   Detailed explanation goes here
[hull,solidity, ~,~]=GetHull(I,h);
area=polyarea([hull(:,2)],[hull(:,1)]);
p=[hull(:,2),hull(:,1)];
end

