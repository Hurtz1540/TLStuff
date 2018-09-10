function [Yin] = ABCDtoYinSeries(abcd)

% Yin for series fed annular slot

Y1 = abcd(2,2)/abcd(1,2) - 1;
Y2 = (abcd(1,1) - 1)/abcd(1,2);
Y3 = 1/abcd(1,2);

Yin = (Y1*Y2)/(Y1 + Y2) + Y3;