clear all;
close all;
clc;

f = [900E6:1E8:6E9];   % frequency spectrum in Hz
C1 = [0.63E-12:0.01E-12:2.67E-12];   % capacitance of top varacter  (0.63 to 2.67 pF)
r1 = 0.05;  % radius of ring reactor in meters
%r1 = radius./0.0254;   % radius of ring reactor converted to inches (3 mm = 0.11811 in)
angle1 = pi/3;  % angle of first varacter in radians
% rmin = (3E8/f(1))/100;  % wavelength = c/f  max radius of wavelength/100
% rmax = (3E8/f(1))/8;  % wavelength = c/f  max radius of wavelength/8

tic;

options = optimset('TolX',1E-9,'MaxFunEvals',2000);

v0 = [r1,angle1];
fun = @(v)DRRELSA(f,C1,v);
[v,fval] = fminunc(fun,v0,options);   %[rmin,-pi/2],[rmax,pi/2]);

toc