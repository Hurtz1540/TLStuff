function [ABCD] = abcdTL(Z,L,B)
%ABCD parameters for a segment of transmission line
% Z = impedance of transmission line
% L = length of transmission line
% B = propagation constant (beta) of transmission line
% angles are in radians

ABCD(1,1) = cos(B*L);
ABCD(1,2) = j*Z*sin(B*L);
ABCD(2,1) = j*1/Z*sin(B*L);
ABCD(2,2) = cos(B*L);

%ABCDSL1 = [cos(B*L1), j*Zc*sin(B*L1); j*1/Zc*sin(B*L1), cos(B*L1)]