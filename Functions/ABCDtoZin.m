function [Zin] = ABCDtoZin(ABCD,Zload)

Zin =  (ABCD(1,1)*Zload + ABCD(1,2))/(ABCD(2,1)*Zload + ABCD(2,2));
%calculate Zin = (AZload + B)/(CZload + D) for shunt fed annular slot
