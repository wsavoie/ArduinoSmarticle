%kdat is from 11-30 data 
%plot stuff from kdat
load('kdat.mat');
%matrices are formatted like:

%each 4 columns are mean(str) std(str) mean(k) std(k)
%the first 4 are cycle 0, second 4 are cycle 1, 3rd four are cycle 2

figure(123);
hold on;
j=kdat50;

for i=0:2
    errorbar(j(:,1+i*4),j(:,3+i*4),j(:,4+i*4),j(:,4+i*4),j(:,2+i*4),j(:,2+i*4))
end
