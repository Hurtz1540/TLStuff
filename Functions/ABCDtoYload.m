function [Yload] = ABCDtoYload(ABCD)

% Yload of series fed annular slot
Y1 = (ABCD(2,2)/ABCD(1,2)) - 1; 
Y2 = (ABCD(1,1)-1)/ABCD(1,2);
Y3 = 1/ABCD(1,2);
Yload = (Y1*Y2)/(Y1+Y2)+Y3;