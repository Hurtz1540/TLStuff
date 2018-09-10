function [optPhaseAng] = DRRELSA(f,C1,v)

%freq = range of frequencies to be evaluated
%C1 = range of varacter capacitances to be evaluated 
%v(1) = radius = range of radii of RRs to be evaluated
%v(2) = theta1 = range of location of varacters from 5 to 175 degree

%f = [900E6:1E8:6E9];   % frequency spectrum in Hz
%f = [2.55024E9:100:2.55026E9];
%f = 6.2E9;
angle1 = v(2);  % angle of first varacter in radians
angle2 = angle1; % in radians
% r = 3; % in mm
r1 = v(1);  % in meters   % r/25.4;   % radius of ring resonator converted to inches (3 mm = 0.11811 in)
%r1 = radius./25.4;   % radius of ring resonator converted to inches (3 mm = 0.11811 in)
%C1 = 0.63E-12:0.01E-12:2.67E-12;   % capacitance of top varacter (Skyworks SMV1405-040LF 0.63 to 2.67 pF)
%C1 = 1.77E-12:0.01E-12:9.24E-12;   % SMV1413  1.77 to 9.24 pF
%C1 = 0.1E-12:0.1E-12:500E-12; %0.01to500pF
C2 = C1;    % capacitance of bottom varacter
w = 0.15748;    % slot width in inches (0.4 mm)
d = 0.01;   %dielectric width in inches (Rogers Corp ?RO4350? 10 mil thickness)
L1 = angle1*r1; %2.35619;   % length of RR from slot antenna to varacter in mm
L2 = (pi-angle1)*r1;   % length from first varacter to next RR in mm
L3 = angle2*r1;   % length of parallel section to l1
L4 = (pi-angle2)*r1;   % length of parallel section to l2
L5 = 2*(L1+L2);   % length of second RR from first RR 
er = 2.2;   % relative permativity for dielectric substrate (3ISH) RTDUROID 4350/5880
 
for indf = 1:numel(f)
    [Zc,lambdadet,~,~,~,~]=slotcalcscohn(f(indf),er,w,d);
     
    for indC = 1:numel(C1)                      
        B = 2*pi/lambdadet;    % Propagation constant (beta value) of transmission line
        Y1(indC) = j*2*pi*f(indf)*C1(indC);   % Admittance of top varacter
        Y2(indC) = Y1(indC);   % Admittance of bottom varacter
        ABCDSL1 = abcdTL(Zc,L1,B);  %[cos(B*L1), j*Zc*sin(B*L1); j*1/Zc*sin(B*L1), cos(B*L1)]; %ABCD parameters for RR's 1st segment of slot line
        ABCDV1 = abcdShunt(Y1(indC));  %[1, 0; Y1(indC), 1];   % ABCD parameters for varacter
        ABCDSL2 = abcdTL(Zc,L2,B); %[cos(B*L2), j*Zc*sin(B*L2); j*1/Zc*sin(B*L2), cos(B*L2)]; %ABCD parameters for RR's 2nd segment of slot line

        ABCDRR1top = ABCDSL1*ABCDV1*ABCDSL2;  % ABCD parameter for cascade of TL, varacter, TL2

        ABCDSL3 = abcdTL(Zc,L3,B); %[cos(B*L3), j*Zc*sin(B*L3); j*1/Zc*sin(B*L3), cos(B*L3)]; %ABCD parameters for 1st RR's 1st segment of slot line
        ABCDV2 = abcdShunt(Y2(indC)); %[1, 0; Y2(indC), 1];   % ABCD parameters for varacter
        ABCDSL4 = abcdTL(Zc,L4,B);%[cos(B*L4), j*Zc*sin(B*L4); j*1/Zc*sin(B*L4), cos(B*L4)]; %ABCD parameters for 1st RR's 2nd segment of slot line
     
        ABCDRR1bottom = ABCDSL3*ABCDV2*ABCDSL4;  % ABCD parameter for cascade of TL, varacter, TL2

        YRR1top = abcd2y(ABCDRR1top);  % convert top ABCD parameters to y parameters so that they add in parallel
        YRR1bottom = abcd2y(ABCDRR1bottom);  % convert bottom ABCD parameters to y parameters so that they add in parallel
        YRR1 = YRR1top + YRR1bottom;

        ABCDRR1 = y2abcd(YRR1);

        ABCDRR2 = [cos(B*L5), j*Zc*sin(B*L5); j*1/Zc*sin(B*L5), cos(B*L5)]; % ABCD parameters for 2nd RR length of slot line
     
        Yload(indf,indC) = ABCDtoYload(ABCDRR2);     % admittance of load (second RR)
        Zload(indf,indC) = 1/Yload(indf,indC);    % impedance of load (second RR)
        %Zin(indf) = ABCDtoZin(ABCDRR1,Zload);   % impedance looking into the the RRs
        Zin(indf,indC) = ABCDtoZin(ABCDRR1,Zload(indf,indC)); % impedance looking into the the RRs
                
        phaseAng(indf,indC) = angle(Zin(indf,indC));  % phase angle of Zin in radians
                                
    end
    
    optPhaseAng = 1/(max(phaseAng(indf,:))-min(phaseAng(indf,:)));  % maximize phase angle
    Zc(indf) = Zc;
       
end
