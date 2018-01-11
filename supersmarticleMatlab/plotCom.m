superLightRingMass=10.28; 
regularRingMass=119.5; 
mediumRingMass=60.5;
chordRingMass=75.8;
chordRingAng=252*pi/180;

extraMass=35.25; %includes tracking marker
smartMass=31.5;

PrintRingThick=2.5;
superLightRingThick=0;%because of how mass is oriented on the ring

ringRad=192/2;
extraSmartWidth=20;
extraSmartHeight=3;

ringR=192/2;

inactiveLoc=ringR-30;%com of inactive smarticle is 30mm from edge 
chordLoc=ringR-3.75;

figure(11);
hold on;
h=plot(ringRad*cos(0:.01:2*pi),ringRad*sin(0:.01:2*pi),'k','linewidth',2);
set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
%superlight with extra mass
masses=[superLightRingMass extraMass 0]; %ringmass,extraSmart,smarts
locs=[0 (ringRad+extraSmartWidth/2) 0];
com=1/sum(masses)*sum(masses.*locs);
plot(0,com,'o');

%reg ring with extra mass
masses=[regularRingMass extraMass 0]; %ringmass,extraSmart,smarts
locs=[0 (ringRad+PrintRingThick+extraSmartHeight/2) 0];
com=1/sum(masses)*sum(masses.*locs);
plot(0,com,'o');

%reg ring with inactiveSmart
masses=[regularRingMass smartMass 0]; %ringmass,extraSmart,smarts
locs=[0 (inactiveLoc) 0];
com=1/sum(masses)*sum(masses.*locs);
plot(0,com,'o');

%com chord with 4 smarts 
% masses=[chordring smartMass 0]; %ringmass,extraSmart,smarts
% locs=[0 (inactiveLoc) 0];
com=(68.18*chordRingMass+(extraSmartHeight/2+ringRad-40)*extraMass)/(extraMass+chordRingMass);
plot(0,com,'o');

%com chord with 4 smarts no extra mass
% masses=[chordring smartMass 0]; %ringmass,extraSmart,smarts
% locs=[0 (inactiveLoc) 0];
com=(68.18);
plot(0,com,'o');


legz={'superLight w/ extra mass','RegRing w/ extra mass','RegRing a=4 i=1', 'chord a=4 + extra mass','chord a=4'};
l=legend(legz,'interpreter','latex');
xlabel('$R_x$ (mm)','interpreter','latex');
ylabel('$R_y$ (mm)','interpreter','latex');

figText(gcf,18);
l.FontSize=12;
axis equal