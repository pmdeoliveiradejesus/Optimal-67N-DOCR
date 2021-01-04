% This funcion runs the OpenDSS engine using the COM Intrerface
function [index] =  model_setup_OpenDSS(L)
global Rf Rg Ipx S3a S3b S3c  pf3a pf3b pf3c k1 k2 k3 Mmax compile_path
L14=50*L(1); 
L25=40*L(2); 
L36=60*L(3); 
L42=50*(1-L(1)); 
L53=40*(1-L(2));  
L61=60*(1-L(3)); 
DSSObj = actxserver('OpenDSSEngine.DSS');
if ~DSSObj.Start(0)
disp('Unable to start the OpenDSS Engine');
return
end
DSSText = DSSObj.Text; % Used for all text interfacing from matlab to opendss
DSSCircuit = DSSObj.ActiveCircuit; % active circuit
% Write Path where Master and its associated files are stored and compile as per following command
 DSSText.Command=compile_path;
 DSSText.Command='New Reactor.SourceGround  Phases=1 Bus1=n1.4 Bus2=n1.0 R=00.000001 X=0';
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
Io=complex(I(:,1)+I(:,3)+I(:,5),I(:,2)+I(:,4)+I(:,6));
IoB=complex(I(:,9)+I(:,11)+I(:,13),I(:,10)+I(:,12)+I(:,14));
index(1,1)=abs(Io(1))/1000;
index(1,3)=angle(Io(1))*180/pi;
index(4,1)=abs(IoB(2))/1000;
index(4,3)=angle(IoB(2))*180/pi;
index(1,2)=abs(Io(5))/1000;
index(1,4)=angle(Io(5))*180/pi;
index(4,2)=abs(IoB(4))/1000;
index(4,4)=angle(IoB(4))*180/pi;



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
index(2,1)=abs(Io(3))/1000;
index(2,3)=angle(Io(3))*180/pi;
index(5,1)=abs(IoB(4))/1000;
index(5,3)=angle(IoB(4))*180/pi;
index(2,2)=abs(Io(1))/1000;
index(2,4)=angle(Io(1))*180/pi;
index(5,2)=abs(IoB(6))/1000;
index(5,4)=angle(IoB(6))*180/pi;

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
index(3,1)=abs(Io(5))/1000;
index(3,3)=angle(Io(5))*180/pi;
index(6,1)=abs(IoB(6))/1000;
index(6,3)=angle(IoB(6))*180/pi;
index(3,2)=abs(Io(3))/1000;
index(3,4)=angle(Io(3))*180/pi;
index(6,2)=abs(IoB(2))/1000;
index(6,4)=angle(IoB(2))*180/pi;

for k=1:6
if index(k,1)/Ipx < Mmax
index(k,5)=k1/((index(k,1)/Ipx)^(k2)+k3);
else    
index(k,5)=k1/(Mmax^(k2)+k3);
end
if index(k,2)/Ipx < Mmax
index(k,6)=k1/((index(k,2)/Ipx)^(k2)+k3);
else    
index(k,6)=k1/(Mmax^(k2)+k3);
end
end