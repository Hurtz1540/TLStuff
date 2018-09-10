function ABCD = abcdShunt(Y)
%ABCD parameters of transmission line with an element in shunt
% Y = admittance of shunt element

ABCD(1,1) = 1;
ABCD(1,2) = 0;
ABCD(2,1) = Y;
ABCD(2,2) = 1;

%ABCDV1 = [1, 0; Y1, 1]