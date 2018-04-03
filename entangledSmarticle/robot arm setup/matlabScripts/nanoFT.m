
sRate = 10000; %sample rate hertz
sRead=1000; %samples to read
CALIB_FILE='C:\Users\Administrator\Desktop\robot arm and force sensor\FT21164.cal';
[calmat,maxes,DIST_UNITS,F_UNITS,T_UNITS,RANGE]=getCalibInfo(CALIB_FILE);
% 
% fx=[-0.03606  -0.29755   0.28558  36.14986   0.11731 -36.23864];
% fy=[-0.13167 -42.84995  -0.11704  21.06432  -0.17403  20.93029];
% fz=[20.28745   0.13251  21.61649   0.08578  21.09325  -0.02982];
% tx=[0.30659  -0.07523  37.33246   0.31191 -36.56620   0.00448];
% ty=[-40.86706  -0.67383  21.72370   0.20115  20.71606   0.14494];
% tz=[ -0.21910 -21.22920  -0.24460 -20.35247   0.53824 -20.62378];

