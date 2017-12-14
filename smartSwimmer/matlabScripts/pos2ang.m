function [arm1E,arm2E]=pos2ang(x1,y1,x2,y2,x3,y3,x4,y4)
rrx=x1-x2; rry=y1-y2; % right arm vector
nr=norm([rrx,rry]);
rrx=rrx/nr; rry=rry/nr;

rbx=x2-x3; rby=y2-y3; % body vector
nb=norm([rbx,rby]);
rbx=rbx/nb; rby=rby/nb;

rlx=x4-x3; rly=y4-y3; % left arm vector
nl=norm([rlx,rly]);
rlx=rlx/nl; rly=rly/nl;

arm1E=acos(rrx*rbx+rry*rby)*sign(rrx*rby-rry*rbx);
arm2E=acos(-rlx*rbx-rly*rby)*sign(rlx*rby-rly*rbx);
end