function [msk,imgout]=spacefilter2(img,LL);

isz=size(img);


if length(isz)==2
    
    size_stack=1;
    
    mr=img;
    
else
    
    size_stack=isz(3);
    
    mr=mean(img,3);
    
end

imgout=squeeze(zeros(isz(1),isz(2),size_stack));

[x,y]=meshgrid(-(isz(2)/2):isz(2)/2-1,-(isz(1)/2):isz(1)/2-1);

[th,r]=cart2pol(x,y);

f=fftshift(fft2(fftshift(mr)));

%figure(2);

msk=real(ifftshift(ifft2(ifftshift(f.*exp(-(r/LL).^2)))));

%imagesc(msk);


for jj=1:size_stack
    
    imgout(:,:,jj)=(img(:,:,jj)./msk);
    
end

imgout=squeeze(imgout);

%figure(1);