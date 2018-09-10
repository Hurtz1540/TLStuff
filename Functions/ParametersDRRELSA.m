close all;
clear all;
clc;


er = 2.2;   %relative permativity for dielectric substrate (3ISH) RTDUROID 4350/5880
f = [900E6:1E8:6E9];   %frequency spectrum in Hz
%f = [2.55024E9:100:2.55026E9];
%f = 6.2E9;
angle1 = 0.9; %1.0472; %0.5236;  % 2.3245; % 0.6242; % 0.7992;  %angle of first varacter in radians
angle2 = angle1;
%r = 5; % in mm
r1 = 0.0497;  % 0.0101; % 0.0039; % 0.0123;   %radius of ring reactor in mm
C1 = 0.63E-12:0.01E-12:2.67E-12;   %capacitance of top varacter  (0.63 to 2.67 pF)
%C1 = 0.1E-12:0.1E-12:500E-12; %0.01to500pF
C2 = C1;  %capacitance of bottom varacter
L1 = angle1*r1; % length of RR from slot antenna to varacter in mm (arc length = angle in radians times radius)
L2 = (pi-angle1)*r1;   % length from first varacter to next RR in mm
L3 = angle2*r1;   % length of parallel section to l1
L4 = (pi-angle2)*r1;   % length of parallel section to l2
L5 = 2*(L1+L2);   % length of second RR from first RR 
w = 0.15748;    %slot width in inches (0.4 mm) required for slotCalcsCohn function (0.4 mm)
d = 0.01;   %dielectric width in inches (Rogers Corp ?RO4350? 10 mil thickness)

tic;

for indf = 1:numel(f)
    [Zc,lambdadet,Zcest,lambdapest,pdet,vel]=slotcalcscohn(f(indf),er,w,d);
     
    for indC = 1:numel(C1) 
     B = 2*pi/lambdadet;    %Propagation constant (beta value) of transmission line
     Y1(indC) = j*2*pi*f(indf)*C1(indC);   %Admittance of top varacter
     Y2(indC) = Y1(indC);   %Admittance of bottom varacter
         
     ABCDSL1 = abcdTL(Zc,L1,B);  %[cos(B*L1), j*Zc*sin(B*L1); j*1/Zc*sin(B*L1), cos(B*L1)]; %ABCD parameters for RR's 1st segment of slot line
     ABCDV1 = abcdShunt(Y1(indC));  %[1, 0; Y1(indC), 1];   % ABCD parameters for varacter
     ABCDSL2 = abcdTL(Zc,L2,B); %[cos(B*L2), j*Zc*sin(B*L2); j*1/Zc*sin(B*L2), cos(B*L2)]; %ABCD parameters for RR's 2nd segment of slot line

     ABCDRR1top = ABCDSL1*ABCDV1*ABCDSL2;  % ABCD parameter for cascade of SL1, varacter, SL2

     ABCDSL3 = abcdTL(Zc,L3,B); %[cos(B*L3), j*Zc*sin(B*L3); j*1/Zc*sin(B*L3), cos(B*L3)]; %ABCD parameters for 1st RR's 1st segment of slot line
     ABCDV2 = abcdShunt(Y2(indC)); %[1, 0; Y2(indC), 1];   % ABCD parameters for varacter
     ABCDSL4 = abcdTL(Zc,L4,B);%[cos(B*L4), j*Zc*sin(B*L4); j*1/Zc*sin(B*L4), cos(B*L4)]; %ABCD parameters for 1st RR's 2nd segment of slot line

     ABCDRR1bottom = ABCDSL3*ABCDV2*ABCDSL4;  % ABCD parameter for cascade of SL1, varacter, SL2

     YRR1top = abcd2y(ABCDRR1top);  %convert top ABCD parameters to y parameters so that they add in parallel
     YRR1bottom = abcd2y(ABCDRR1bottom);  %convert bottom ABCD parameters to y parameters so that they add in parallel
     YRR1 = YRR1top + YRR1bottom;  % Y parameters add in parallel

     ABCDRR1 = y2abcd(YRR1);  % convert from Y parameters to ABCD parameters

     ABCDRR2 = [cos(B*L5), j*Zc*sin(B*L5); j*1/Zc*sin(B*L5), cos(B*L5)]; %ABCD parameters for 2nd RR length of slot line
     
     Yload(indf) = ABCDtoYload(ABCDRR2);     %admittance of load (second RR)
     Zload(indf) = 1/Yload(indf);    %impedance of load (second RR)
     %Zin(indf) = ABCDtoZin(ABCDRR1,Zload); %impedance looking into the the RRs
     Zin(indf,indC) = ABCDtoZin(ABCDRR1,Zload); %impedance looking into the the RRs
     
     phaseAng(indf,indC) = angle(Zin(indf,indC));  % phase angle of Zin in radians
                
    end
     
     invPhaseAngRange(indf) = 1/(max(phaseAng(indf,:))-min(phaseAng(indf,:)));  % maximize phase angle
    
     figure(indf)
     gamma = z2gamma(Zin(indf,:),Zc)';   %(800+Zin,800);  % reflection coefficient gammaIn
     [lineseries,hsm] = smithchart(gamma);
     hold on
     lineseries.Marker = 'x';
     %lineseries.Color = 'r';
     lineseries.LineWidth = 2;
     title([num2str(angle1*180/pi), ' degrees ', num2str(r1*1000), ' mm ', num2str(f(indf)/10^9),' GHz']);
     
     Zc(indf) = Zc;

end
toc

for i = 1:numel(f)
    phaseAngRange(i) = (max(phaseAng(i,:))-min(phaseAng(i,:)))  % maximize phase angle
end

max(phaseAngRange)
