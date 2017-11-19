function [ idx,val] = findNearestInd( inp,data )
%FINDNEARESTIND finds nearest value in 1D array to given input
    [~,idx]=min(abs(data-inp));
    val=data(idx); 
end

