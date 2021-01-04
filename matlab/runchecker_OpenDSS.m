% This funcion runs the OpenDSS engine using the COM Intrerface
%function [index] =  model_setup_OpenDSS(x,neval)
function [mtpr,minminS,tpr,S,Nxx,DVs] = runchecker_OpenDSS(x,neval,qmax,Rf)
global Rg Ipx S3a S3b S3c  pf3a pf3b pf3c k1 k2 k3 Mmax compile_path
nr=6;
% qmax=45;
% neval=1;
index=[5,1,1,1,3,6,1,4;
       1,2,3,2,1,4,2,5;
       3,3,5,3,2,5,3,6;
       4,1,2,1,3,5,2,4;
       6,2,4,2,1,6,3,5;
       2,3,6,3,2,4,1,6];
    iter3=1;  
  iter2=1;  
for kk=1:neval
if kk==neval/4
fprintf('Progress: 25%%')
elseif kk==neval/2
fprintf(', 50%%')
elseif kk==3*neval/4
fprintf(', 75%%')    
elseif kk==neval
fprintf(', 100%%\n')
end
L3(kk,1)=unifrnd(2.0000e-05,1-2.0000e-05);%
L3(kk,2)=unifrnd(2.5000e-05,1-2.5000e-05);%
L3(kk,3)=unifrnd(1.6667e-05,1-1.6667e-05);%
% lb=0.9;
% L3(kk,1)=unifrnd(lb,lb);%
% L3(kk,2)=unifrnd(lb,lb);%
% L3(kk,3)=unifrnd(lb,lb);%
% 
L14=50*L3(kk,1); 
L25=40*L3(kk,2); 
L36=60*L3(kk,3); 
L42=50*(1-L3(kk,1)); 
L53=40*(1-L3(kk,2));  
L61=60*(1-L3(kk,3));
DSSObj = actxserver('OpenDSSEngine.DSS');
if ~DSSObj.Start(0)
disp('Unable to start the OpenDSS Engine');
return
end
DSSText = DSSObj.Text; % Used for all text interfacing from matlab to opendss
DSSCircuit = DSSObj.ActiveCircuit; % active circuit
% Write Path where Master and its associated files are stored and compile as per following command
DSSText.Command=compile_path;
DSSText.Command='New Reactor.SourceGround  Phases=1 Bus1=n1.4 Bus2=n1.0 R=00.00001 X=0';
DSSText.Command='New Reactor.Load2Ground  Phases=1 Bus1=n2.4 Bus2=n2.0 R=00.00001 X=0';
DSSText.Command='New Reactor.Load3Ground  Phases=1 Bus1=n3.4 Bus2=n3.0 R=00.00001 X=0';
DSSText.Command=strcat('New Reactor.Load4Ground Phases=1 Bus1=n4.4 Bus2=n4.0 R=',num2str(Rg),' X=0');
DSSText.Command=strcat('New Reactor.Load5Ground Phases=1 Bus1=n5.4 Bus2=n5.0 R=',num2str(Rg),' X=0');
DSSText.Command=strcat('New Reactor.Load6Ground Phases=1 Bus1=n6.4 Bus2=n6.0 R=',num2str(Rg),' X=0');
DSSText.Command='set voltagebases=[69]'; 
DSSText.Command='calcvoltagebases';
DSSText.Command=strcat('new line.line14 geometry=4wire12 length=',num2str(L14),' units=km bus1=n1.1.2.3.4 bus2=n4.1.2.3.4  Rho=100');
DSSText.Command=strcat('new line.line42 geometry=4wire12 length=',num2str(L42),' units=km bus1=n4.1.2.3.4 bus2=n2.1.2.3.4  Rho=100');
DSSText.Command=strcat('new line.line25 geometry=4wire23 length=',num2str(L25),' units=km bus1=n2.1.2.3.4 bus2=n5.1.2.3.4  Rho=100');
DSSText.Command=strcat('new line.line53 geometry=4wire23 length=',num2str(L53),' units=km bus1=n5.1.2.3.4 bus2=n3.1.2.3.4  Rho=100');
DSSText.Command=strcat('new line.line36 geometry=4wire13 length=',num2str(L36),' units=km bus1=n3.1.2.3.4 bus2=n6.1.2.3.4  Rho=100');
DSSText.Command=strcat('new line.line61 geometry=4wire13 length=',num2str(L61),' units=km bus1=n6.1.2.3.4 bus2=n1.1.2.3.4  Rho=100');
DSSText.Command=strcat('New fault.Falla1   Bus1= n4.3   Bus2=n4.4 r=',num2str(Rf));
DSSText.Command=strcat('New Load.n3.1 Phases=1  Bus1=n3.1   kVA=',num2str(S3a),' pf=0.9  kV=69 conn=wye  vminpu=0.1 vmaxpu=1.9');
DSSText.Command=strcat('New Load.n3.2 Phases=1  Bus1=n3.2   kVA=',num2str(S3b),' pf=0.95 kV=69  conn=wye  vminpu=0.1 vmaxpu=1.9');
DSSText.Command=strcat('New Load.n3.3 Phases=1  Bus1=n3.3   kVA=',num2str(S3c),' pf=0.85 kV=69 conn=wye vminpu=0.1 vmaxpu=1.9');
DSSText.Command='solve';
DSSSolution = DSSCircuit.Solution;
DSSLines = DSSObj.ActiveCircuit.Lines;
DSSActiveCktElement = DSSObj.ActiveCircuit.ActiveCktElement;
i = DSSCircuit.Lines.First;
while i > 0
I(i,:) = DSSActiveCktElement.Currents;
i  = DSSCircuit.Lines.Next;
end
%Structure of I
%           |I1_1x I1_1y I1_2x I1_2y I1_3x I1_3y I1_4x I1_4y I1_1x I1_1y I1_2x I1_2y I1_3x I1_3y I1_4x I1_4y	
%Line.LINE14
%Line.LINE42
%Line.LINE25
%Line.LINE53
%Line.LINE36
%Line.LINE61
 
Io=complex(I(:,1)+I(:,3)+I(:,5),I(:,2)+I(:,4)+I(:,6));
IoB=complex(I(:,9)+I(:,11)+I(:,13),I(:,10)+I(:,12)+I(:,14));
index(1,9)=abs(Io(1))/1000;
index(1,17)=angle(Io(1))*180/pi;
index(4,9)=abs(IoB(2))/1000;
index(4,17)=angle(IoB(2))*180/pi;
index(1,10)=abs(Io(5))/1000;
index(1,18)=angle(Io(5))*180/pi;
index(4,10)=abs(IoB(4))/1000;
index(4,18)=angle(IoB(4))*180/pi;

ii = DSSCircuit.Lines.First;
while ii > 0
V(ii,:) = DSSActiveCktElement.Voltages;
ii  = DSSCircuit.Lines.Next;
end
% Structure of V
% N1 | v1ax v1ay v1bx v1by v1cx v1cy v1nx v1ny  v4ax v4ay v4bx v4by v4cx v4cy v4nx v4ny 
% N4 | v4ax v4ay v4bx v4by v4cx v4cy v4nx v4ny  v2ax v2ay v2bx v2by v2cx v2cy v2nx v2ny 
% N2 | v2ax v2ay v2bx v2by v2cx v2cy v2nx v2ny  v5ax v5ay v5bx v5by v5cx v5cy v5nx v5ny  
% N5 | v5ax v5ay v5bx v5by v5cx v5cy v5nx v5ny  v3ax v3ay v3bx v3by v3cx v3cy v3nx v3ny
% N3 | v3ax v3ay v3bx v3by v3cx v3cy v3nx v3ny  v6ax v6ay v6bx v6by v6cx v6cy v6nx v6ny
% N6 | v6ax v6ay v6bx v6by v6cx v6cy v6nx v6ny  v1ax v1ay v1bx v1by v1cx v1cy v1nx v1ny 
Va=abs(complex(V(:,1),V(:,2))-complex(V(:,7),V(:,8)));
Vb=abs(complex(V(:,3),V(:,4))-complex(V(:,7),V(:,8)));
Vc=abs(complex(V(:,5),V(:,6))-complex(V(:,7),V(:,8)));
Vabc1=[Va;Vb;Vc];

DSSObj = actxserver('OpenDSSEngine.DSS');
if ~DSSObj.Start(0),
disp('Unable to start the OpenDSS Engine');
return
end
DSSText = DSSObj.Text; % Used for all text interfacing from matlab to opendss
DSSCircuit = DSSObj.ActiveCircuit; % active circuit
% Write Path where Master and its associated files are stored and compile as per following command
DSSText.Command=compile_path;
 DSSText.Command='New Reactor.SourceGround  Phases=1 Bus1=n1.4 Bus2=n1.0 R=00.00001 X=0';
 DSSText.Command='New Reactor.Load2Ground  Phases=1 Bus1=n2.4 Bus2=n2.0 R=00.00001 X=0';
 DSSText.Command='New Reactor.Load3Ground  Phases=1 Bus1=n3.4 Bus2=n3.0 R=00.00001 X=0';
DSSText.Command=strcat('New Reactor.Load4Ground Phases=1 Bus1=n4.4 Bus2=n4.0 R=',num2str(Rg),' X=0');
DSSText.Command=strcat('New Reactor.Load5Ground Phases=1 Bus1=n5.4 Bus2=n5.0 R=',num2str(Rg),' X=0');
DSSText.Command=strcat('New Reactor.Load6Ground Phases=1 Bus1=n6.4 Bus2=n6.0 R=',num2str(Rg),' X=0');
DSSText.Command='set voltagebases=[69]'; 
DSSText.Command='calcvoltagebases';
DSSText.Command=strcat('new line.line14 geometry=4wire12 length=',num2str(L14),' units=km bus1=n1.1.2.3.4 bus2=n4.1.2.3.4  Rho=100');
DSSText.Command=strcat('new line.line42 geometry=4wire12 length=',num2str(L42),' units=km bus1=n4.1.2.3.4 bus2=n2.1.2.3.4  Rho=100');
DSSText.Command=strcat('new line.line25 geometry=4wire23 length=',num2str(L25),' units=km bus1=n2.1.2.3.4 bus2=n5.1.2.3.4  Rho=100');
DSSText.Command=strcat('new line.line53 geometry=4wire23 length=',num2str(L53),' units=km bus1=n5.1.2.3.4 bus2=n3.1.2.3.4  Rho=100');
DSSText.Command=strcat('new line.line36 geometry=4wire13 length=',num2str(L36),' units=km bus1=n3.1.2.3.4 bus2=n6.1.2.3.4  Rho=100');
DSSText.Command=strcat('new line.line61 geometry=4wire13 length=',num2str(L61),' units=km bus1=n6.1.2.3.4 bus2=n1.1.2.3.4  Rho=100');
DSSText.Command=strcat('New fault.Falla2   Bus1= n5.3   Bus2=n5.4 r=',num2str(Rf));
DSSText.Command=strcat('New Load.n3.1 Phases=1  Bus1=n2.1   kVA=',num2str(S3a),' pf=',num2str(pf3a),' kV=69 conn=wye  vminpu=0.1 vmaxpu=1.9');
DSSText.Command=strcat('New Load.n3.2 Phases=1  Bus1=n2.2   kVA=',num2str(S3b),' pf=',num2str(pf3b),' kV=69  conn=wye  vminpu=0.1 vmaxpu=1.9');
DSSText.Command=strcat('New Load.n3.3 Phases=1  Bus1=n2.3   kVA=',num2str(S3c),' pf=',num2str(pf3c),' kV=69 conn=wye vminpu=0.1 vmaxpu=1.9');
DSSText.Command='solve';
DSSSolution = DSSCircuit.Solution;
DSSLines = DSSObj.ActiveCircuit.Lines;
DSSActiveCktElement = DSSObj.ActiveCircuit.ActiveCktElement;
i = DSSCircuit.Lines.First;
while i > 0
I(i,:) = DSSActiveCktElement.Currents;
i  = DSSCircuit.Lines.Next;
end
Io=complex(I(:,1)+I(:,3)+I(:,5),I(:,2)+I(:,4)+I(:,6));
IoB=complex(I(:,9)+I(:,11)+I(:,13),I(:,10)+I(:,12)+I(:,14));
index(2,9)=abs(Io(3))/1000;
index(2,17)=angle(Io(3))*180/pi;
index(5,9)=abs(IoB(4))/1000;
index(5,17)=angle(IoB(4))*180/pi;
index(2,10)=abs(Io(1))/1000;
index(2,18)=angle(Io(1))*180/pi;
index(5,10)=abs(IoB(6))/1000;
index(5,18)=angle(IoB(6))*180/pi;
ii = DSSCircuit.Lines.First;
while ii > 0
V(ii,:) = DSSActiveCktElement.Voltages;
ii  = DSSCircuit.Lines.Next;
end
% Structure of V
% N1 | v1ax v1ay v1bx v1by v1cx v1cy v1nx v1ny  v4ax v4ay v4bx v4by v4cx v4cy v4nx v4ny 
% N4 | v4ax v4ay v4bx v4by v4cx v4cy v4nx v4ny  v2ax v2ay v2bx v2by v2cx v2cy v2nx v2ny 
% N2 | v2ax v2ay v2bx v2by v2cx v2cy v2nx v2ny  v5ax v5ay v5bx v5by v5cx v5cy v5nx v5ny  
% N5 | v5ax v5ay v5bx v5by v5cx v5cy v5nx v5ny  v3ax v3ay v3bx v3by v3cx v3cy v3nx v3ny
% N3 | v3ax v3ay v3bx v3by v3cx v3cy v3nx v3ny  v6ax v6ay v6bx v6by v6cx v6cy v6nx v6ny
% N6 | v6ax v6ay v6bx v6by v6cx v6cy v6nx v6ny  v1ax v1ay v1bx v1by v1cx v1cy v1nx v1ny 
Va=abs(complex(V(:,1),V(:,2))-complex(V(:,7),V(:,8)));
Vb=abs(complex(V(:,3),V(:,4))-complex(V(:,7),V(:,8)));
Vc=abs(complex(V(:,5),V(:,6))-complex(V(:,7),V(:,8)));
Vabc2=[Va;Vb;Vc];


DSSObj = actxserver('OpenDSSEngine.DSS');
if ~DSSObj.Start(0),
disp('Unable to start the OpenDSS Engine');
return
end
DSSText = DSSObj.Text; % Used for all text interfacing from matlab to opendss
DSSCircuit = DSSObj.ActiveCircuit; % active circuit
% Write Path where Master and its associated files are stored and compile as per following command
DSSText.Command=compile_path;
 DSSText.Command='New Reactor.SourceGround  Phases=1 Bus1=n1.4 Bus2=n1.0 R=00.00001 X=0';
 DSSText.Command='New Reactor.Load2Ground  Phases=1 Bus1=n2.4 Bus2=n2.0 R=00.00001 X=0';
 DSSText.Command='New Reactor.Load3Ground  Phases=1 Bus1=n3.4 Bus2=n3.0 R=00.00001 X=0';
DSSText.Command=strcat('New Reactor.Load4Ground Phases=1 Bus1=n4.4 Bus2=n4.0 R=',num2str(Rg),' X=0');
DSSText.Command=strcat('New Reactor.Load5Ground Phases=1 Bus1=n5.4 Bus2=n5.0 R=',num2str(Rg),' X=0');
DSSText.Command=strcat('New Reactor.Load6Ground Phases=1 Bus1=n6.4 Bus2=n6.0 R=',num2str(Rg),' X=0');
DSSText.Command='set voltagebases=[69]'; 
DSSText.Command='calcvoltagebases';
DSSText.Command=strcat('new line.line14 geometry=4wire12 length=',num2str(L14),' units=km bus1=n1.1.2.3.4 bus2=n4.1.2.3.4  Rho=100');
DSSText.Command=strcat('new line.line42 geometry=4wire12 length=',num2str(L42),' units=km bus1=n4.1.2.3.4 bus2=n2.1.2.3.4  Rho=100');
DSSText.Command=strcat('new line.line25 geometry=4wire23 length=',num2str(L25),' units=km bus1=n2.1.2.3.4 bus2=n5.1.2.3.4  Rho=100');
DSSText.Command=strcat('new line.line53 geometry=4wire23 length=',num2str(L53),' units=km bus1=n5.1.2.3.4 bus2=n3.1.2.3.4  Rho=100');
DSSText.Command=strcat('new line.line36 geometry=4wire13 length=',num2str(L36),' units=km bus1=n3.1.2.3.4 bus2=n6.1.2.3.4  Rho=100');
DSSText.Command=strcat('new line.line61 geometry=4wire13 length=',num2str(L61),' units=km bus1=n6.1.2.3.4 bus2=n1.1.2.3.4  Rho=100');
DSSText.Command=strcat('New fault.Falla3   Bus1= n6.3   Bus2=n6.4 r=',num2str(Rf));
DSSText.Command=strcat('New Load.n3.1 Phases=1  Bus1=n2.1   kVA=',num2str(S3a),' pf=0.9  kV=69 conn=wye  vminpu=0.1 vmaxpu=1.9');
DSSText.Command=strcat('New Load.n3.2 Phases=1  Bus1=n2.2   kVA=',num2str(S3b),' pf=0.95   kV=69  conn=wye  vminpu=0.1 vmaxpu=1.9');
DSSText.Command=strcat('New Load.n3.3 Phases=1  Bus1=n2.3   kVA=',num2str(S3c),' pf=0.85  kV=69 conn=wye vminpu=0.1 vmaxpu=1.9');
DSSText.Command='solve';
DSSSolution = DSSCircuit.Solution;
DSSLines = DSSObj.ActiveCircuit.Lines;
DSSActiveCktElement = DSSObj.ActiveCircuit.ActiveCktElement;
i = DSSCircuit.Lines.First;
while i > 0
I(i,:) = DSSActiveCktElement.Currents;
i  = DSSCircuit.Lines.Next;
end
Io=complex(I(:,1)+I(:,3)+I(:,5),I(:,2)+I(:,4)+I(:,6));
IoB=complex(I(:,9)+I(:,11)+I(:,13),I(:,10)+I(:,12)+I(:,14));
index(3,9)=abs(Io(5))/1000;
index(3,17)=angle(Io(5))*180/pi;
index(6,9)=abs(IoB(6))/1000;
index(6,17)=angle(IoB(6))*180/pi;
index(3,10)=abs(Io(3))/1000;
index(3,18)=angle(Io(3))*180/pi;
index(6,10)=abs(IoB(2))/1000;
index(6,18)=angle(IoB(2))*180/pi;
ii = DSSCircuit.Lines.First;
while ii > 0
V(ii,:) = DSSActiveCktElement.Voltages;
ii  = DSSCircuit.Lines.Next;
end
% Structure of V
% N1 | v1ax v1ay v1bx v1by v1cx v1cy v1nx v1ny  v4ax v4ay v4bx v4by v4cx v4cy v4nx v4ny 
% N4 | v4ax v4ay v4bx v4by v4cx v4cy v4nx v4ny  v2ax v2ay v2bx v2by v2cx v2cy v2nx v2ny 
% N2 | v2ax v2ay v2bx v2by v2cx v2cy v2nx v2ny  v5ax v5ay v5bx v5by v5cx v5cy v5nx v5ny  
% N5 | v5ax v5ay v5bx v5by v5cx v5cy v5nx v5ny  v3ax v3ay v3bx v3by v3cx v3cy v3nx v3ny
% N3 | v3ax v3ay v3bx v3by v3cx v3cy v3nx v3ny  v6ax v6ay v6bx v6by v6cx v6cy v6nx v6ny
% N6 | v6ax v6ay v6bx v6by v6cx v6cy v6nx v6ny  v1ax v1ay v1bx v1by v1cx v1cy v1nx v1ny 
Va=abs(complex(V(:,1),V(:,2))-complex(V(:,7),V(:,8)));
Vb=abs(complex(V(:,3),V(:,4))-complex(V(:,7),V(:,8)));
Vc=abs(complex(V(:,5),V(:,6))-complex(V(:,7),V(:,8)));
Vabc3=[Va;Vb;Vc];
for k=1:6
if index(k,9)/Ipx < Mmax
index(k,13)=k1/((index(k,9)/Ipx)^(k2)+k3);
else
index(k,13)=k1/((Mmax)^(k2)+k3);    
end
if index(k,10)/Ipx < Mmax
index(k,14)=k1/((index(k,10)/Ipx)^(k2)+k3);
else
index(k,14)=k1/((Mmax)^(k2)+k3);    
end
end

%% Build the relay coordination model (B matrix)


   
    %% Normal configuration constraints
%if kk==1
 iter3=1;
    for k=1:length(index(:,14))
         if abs(index(k,17)-index(k,18)) < qmax
              if index(k,13) > 0
             if index(k,14) > 0
A(iter3,index(k,3))=-index(k,13);
A(iter3,index(k,1))=index(k,14);
Imain(iter3,1)=index(k,13-4);
Iback(iter3,1)=index(k,14-4);
iter3=iter3+1;
end
end
end
end
% else
% for k=1:length(index(:,14))     
% 
%      if abs(index(k,17)-index(k,18)) < qmax
%           if index(k,13) > 0
%          if index(k,14) > 0
% Aneq(iter,index(k,3))=-index(k,13);
% Aneq(iter,index(k,1))=index(k,14);
% Imain(iter,1)=index(k,13-4);
% Iback(iter,1)=index(k,14-4);
%  iter=iter+1;
%          end
%           end
%           end
%  end
% end
mm=length(index(:,14));


%% Objective function: only primary times for near faults
jx=1;
for i=1:nr
   jx=find(index(:,3)==i);
   fx(kk,i)=index(jx(1),13);
end
     
% for k=1:1:nr  
% f(k)=fx(1,k);
% end

% for k=2:2:nr  
% f(k)=fx(2,k);
% end
 

if length(A(1,:)) == 6
  S1=A*x;
  clear A
else
    S1=1;
    clear A
end
 
 for k=1:length(S1)
 S(iter2)=S1(k);
 iter2=iter2+1;
 end
% 
% 
 tpr(kk,1)=fx(kk,:)*x; 
 Vabc(:,kk)=[Vabc1;Vabc2;Vabc3]/(69000/sqrt(3));
end 
DVs=Vabc(:);
Nxx=length(S);
mtpr=mean(tpr);%SPROT
%minminS=min(minS);
minminS=(min(S));

