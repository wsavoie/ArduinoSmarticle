function [initDir,lights]=readLightData(fname)
%file is created by hand listing when light changes.
%first index tells which side the light is on first -1 for left or -x
%direction


fname=[fname(1:end-3),'txt'];
fid=fopen(fname,'r');

out=fscanf(fid,['%f'])
fclose(fid);
pts(out);
initDir=out(1);
lights=out(2:end);

