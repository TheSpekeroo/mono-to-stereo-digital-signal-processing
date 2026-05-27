function c=get_butterworthD(N)
% N: 
c=0;
for t=1:ceil((N-1)/2)
  c(t)=-2*cos((2*t+N-1)/(2*N)*pi);
end
