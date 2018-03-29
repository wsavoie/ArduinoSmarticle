function y = AiFun(t,A0,omega,m,gamma,m1,m2,g,mu,mr,mb)

y=2*(g*(2*m1+m2-mb)*t.*mu+A0*m2*omega*cos(gamma+t.*omega));
end