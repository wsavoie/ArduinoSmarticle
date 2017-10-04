function MI=momentOfInertia2(m0,D,L,arm)
MI=m0*(0.25*D*D+0.5*D*L*cos(arm)+(1/3)*L*L);
end