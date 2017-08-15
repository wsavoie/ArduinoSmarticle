amp=50 
fs=8192  % sampling frequency
duration=5;
freq=100;
values=0:1/fs:duration;
a=amp*sin(2*pi*freq*values);

sound(a)



freq=211
a=amp*sin(2*pi*freq*values);
sound(a)

pause(.25)
freq=345;
a=amp*sin(2*pi*freq*values);
sound(a)

pause(.25)
freq=458;
a=amp*sin(2*pi*freq*values);
sound(a)

pause(.25)
freq=536;
a=amp*sin(2*pi*freq*values);
sound(a)

pause(.25)
freq=636;
a=amp*sin(2*pi*freq*values)
sound(a)