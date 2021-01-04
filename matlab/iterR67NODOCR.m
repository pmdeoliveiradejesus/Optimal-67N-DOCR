% Optimal oordination of DOCR (67 NEUTRAL)  
% Paulo M. De Oliveira, pm.deoliveiradejes@uniandes.edu.co
% https://power.uniandes.edu.co/
% Los Andes University
% First version: July 15, 2020 
% Runs the optimization problem for several Rf and Pickup currents
clc
close all
clear all
 disp('Optimal Directional Overcurrent Relays Coordination Problem.')
 disp('ODOCR (67 Neutral)  ')
 disp('Version 1.1 (c) 2020')
 disp('Power and Energy Group - https://power.uniandes.edu.co/')
 disp('Universidad de los Andes, Colombia')
 disp('*************************************************************')
 disp('Wait!')
 warning('off')
 Mmax=30.0; % Maximum allowable multiplier  (Icc/Ip)
 nIpoints=5;
 nRpoints=500;
for jjj=1:nIpoints% Ip currents from 50 A to 50 A in steps of 1 A 
for kkk=1:nRpoints % Fault Resistances from 1 to 50 ohms in steps of 1 ohms
    kkk;
clearvars -except sol jjj kkk Ipx  D1 D2 D3 D4 D5 D6 Mmax nIpoints nRpoints result
global Dmin Co nr Rg Rf Ipx S3a S3b S3c pf3a pf3b pf3c  k1 k2 k3 Mmax
time00=cputime;
%% Case study
LoadDatabase;
Rf=(kkk-1)/10;%Fault resistance (ohms)
Ipx=0.03+(jjj-1)*.005;
%%
%% Build the relay coordination model (B matrix)
      iter=1;     
for kk=1:n
[index2]=model_setup_OpenDSS(L(kk,:));
index(:,09)=index2(:,1);
index(:,10)=index2(:,2);
index(:,17)=index2(:,3);
index(:,18)=index2(:,4);
index(:,13)=index2(:,5);
index(:,14)=index2(:,6);
%% Normal configuration constraints
if kk==1
    for k=1:length(index(:,14))
         if abs(index(k,17)-index(k,18)) < qmax
              if index(k,13) > 0
             if index(k,14) > 0
Aneq(iter,index(k,3))=-index(k,13);
Aneq(iter,index(k,1))=index(k,14);
Imain(iter,1)=index(k,13-4);
Iback(iter,1)=index(k,14-4);
iter=iter+1;
end
end
end
end
else
for k=1:length(index(:,14))     

     if abs(index(k,17)-index(k,18)) < qmax
          if index(k,13) > 0
         if index(k,14) > 0
Aneq(iter,index(k,3))=-index(k,13);
Aneq(iter,index(k,1))=index(k,14);
Imain(iter,1)=index(k,13-4);
Iback(iter,1)=index(k,14-4);
 iter=iter+1;
         end
          end
          end
 end
end 
mm=length(index(:,14));     
%% Objective function: only primary times for near faults
jj=1;
for i=1:nr
   jj=find(index(:,3)==i);
   fx(kk,i)=index(jj(1),13);
end
end      
% Ezzanine objective funtion. only near faults
for k=1:2:nr  
fe(k)=fx(1,k);
end
for k=2:2:nr  
fe(k)=fx(2,k);
end     
%% SPROT
for k=1:nr
 f(k)=.5*fx(1,k)+.5*fx(2,k);
end
%% Setup the optimization problem
x0=zeros(nr,1); %startup
% LP solver
time0=cputime;
LB=ones(nr,1)*Dmin;
UB=[]; 
Aeq=[];
beq=[];
bneq=ones(length(Aneq(:,1)),1)*Co;
% Optimization problem: min f st. Aneq > bneq
%if length(Aneq(1,:))==6
options = optimoptions('linprog','Algorithm','interior-point','display','off');
[x,FVAL,EXITFLAG]=linprog(f,-Aneq,-bneq,Aeq,beq,LB,UB,x0,options);
% else
% FVAL=0;
% x=[.1 .1 .1 .1 .1 .1];
%  EXITFLAG = 1;
% end
elapsedtime=cputime-time0;
sol(kkk,jjj)=FVAL;
D1(kkk,jjj)=x(1);
D2(kkk,jjj)=x(2);
D3(kkk,jjj)=x(3);
D4(kkk,jjj)=x(4);
D5(kkk,jjj)=x(5);
D6(kkk,jjj)=x(6);
result(kkk,:)=[Rf,FVAL,min(Aneq*x),x'];
end
end

% Plot the objective function for different Ips
Rfx=1:1:nRpoints;% define x axis 
Rfx=Rfx/10;% define x axis 
figure('Color','w','units','normalized','outerposition',[0 0 1 1],'name','Sensitivity Analysis - Objective Fuction','numbertitle','off')
plot(Rfx,sol)
set(gca,'FontSize',12)
mtitle=title('Optimal total clearing time of  6 relays ANSI 67N as a function of $R_f$ and $I_p$ ($R_g$=0 ohms, No loads)', 'FontSize', 12);
set(mtitle,'Interpreter','latex');
xaxis = xlabel({'Fault impedance $R_f$ (ohms)'}, 'FontSize', 12);
set(xaxis,'Interpreter','latex');
yaxis = ylabel('Objective Function $OF$ (seconds)', 'FontSize', 12);
set(yaxis,'Interpreter','latex');
leg = legend({'$I_p$=30A';'$I_p$=35A';'$I_p$=40A';'$I_p$=45A';'$I_p$=50A'}, 'FontSize', 12, 'Location','best');
set(leg,'Interpreter','latex');
legend boxoff 
% Plot the TD setings for different Ips
figure('Color','w','units','normalized','outerposition',[0 0 1 1],'name','Sensitivity Analysis - Time Dial Settings','numbertitle','off')
mtitle=title('Optimal TDS of 6 ANSI 67N relays as a function of $R_f$ and $I_p$ ($R_g$=0 ogms, No loads)', 'FontSize', 12);
set(mtitle,'Interpreter','latex');
subplot(2,3,1)
plot(Rfx,D1)
set(gca,'FontSize',12)
title('TDS relay 1', 'FontSize', 12)
xaxis = xlabel({'Fault impedance $R_f$ (ohms)'}, 'FontSize', 12);
set(xaxis,'Interpreter','latex');
ylabel('TDS_1', 'FontSize', 12)

subplot(2,3,2)
plot(Rfx,D2)
set(gca,'FontSize',12)
title('TDS relay 2', 'FontSize', 12)
xaxis = xlabel({'Fault impedancee $R_f$ (ohms)'}, 'FontSize', 12);
set(xaxis,'Interpreter','latex');
ylabel('TDS_2', 'FontSize', 12)

subplot(2,3,3)
plot(Rfx,D3)
set(gca,'FontSize',12)
title('TDS relay 3', 'FontSize', 12)
xaxis = xlabel({'Fault impedance $R_f$ (ohms)'}, 'FontSize', 12);
set(xaxis,'Interpreter','latex');
ylabel('TDS_3', 'FontSize', 12)

subplot(2,3,4)
plot(Rfx,D4)
set(gca,'FontSize',12)
title('TDS relay 4', 'FontSize', 12)
xaxis = xlabel({'Fault impedance $R_f$ (ohms)'}, 'FontSize', 12);
set(xaxis,'Interpreter','latex');
ylabel('TDS_4', 'FontSize', 12)

subplot(2,3,5)
plot(Rfx,D5)
set(gca,'FontSize',12)
title('TDS relay 5', 'FontSize', 12)
xaxis = xlabel({'Fault impedance $R_f$ (ohms)'}, 'FontSize', 12);
set(xaxis,'Interpreter','latex');
ylabel('TDS_5', 'FontSize', 12)

subplot(2,3,6)
plot(Rfx,D6)
set(gca,'FontSize',12)
title('TDS relay 6', 'FontSize', 12)
xaxis = xlabel({'Fault impedance $R_f$ (ohms)'}, 'FontSize', 12);
set(xaxis,'Interpreter','latex');
ylabel('TDS_6', 'FontSize', 12)
leg = legend({'$I_p$=30A';'$I_p$=35A';'$I_p$=40A';'$I_p$=45A';'$I_p$=50A'}, 'FontSize', 12, 'Location','best');
set(leg,'Interpreter','latex');
legend boxoff 