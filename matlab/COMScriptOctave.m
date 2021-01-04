
DSSObj = actxserver('OpenDSSEngine.DSS');
if ~DSSObj.Start(0)
disp('Unable to start the OpenDSS Engine');
return
end
DSSObj.ActiveCircuit.Solution.Solve()
DSSText = DSSObj.Text; % Used for all text interfacing from matlab to opendss
DSSCircuit = DSSObj.ActiveCircuit; % active circuit
% Write Path where Master and its associated files are stored and compile as per following command
 DSSText.Command='Compile (C:\Users\VaioPC\OpenDSSTutorial\ODOCR_ANSI67N\GridModel.dss)';
 DSSText.Command='New Reactor.SourceGround  Phases=1 Bus1=n1.4 Bus2=n1.0 R=00.000001 X=0';
 DSSText.Command='New Reactor.Load2Ground  Phases=1 Bus1=n2.4 Bus2=n2.0 R=00.00001 X=0';
 DSSText.Command='New Reactor.Load3Ground  Phases=1 Bus1=n3.4 Bus2=n3.0 R=00.00001 X=0';
DSSText.Command='New Reactor.Load4Ground Phases=1 Bus1=n4.4 Bus2=n4.0 R=0.00001 X=0';
DSSText.Command='New Reactor.Load5Ground Phases=1 Bus1=n5.4 Bus2=n5.0 R=0.00001 X=0';
DSSText.Command='New Reactor.Load6Ground Phases=1 Bus1=n6.4 Bus2=n6.0 R=0.00001 X=0';
DSSText.Command='set voltagebases=[69]'; 
DSSText.Command='calcvoltagebases';
DSSText.Command='new line.line14 geometry=4wire12 length=25 units=km bus1=n1.1.2.3.4 bus2=n4.1.2.3.4  Rho=100';
DSSText.Command='new line.line42 geometry=4wire12 length=25 units=km bus1=n4.1.2.3.4 bus2=n2.1.2.3.4  Rho=100';
DSSText.Command='new line.line25 geometry=4wire23 length=25 units=km bus1=n2.1.2.3.4 bus2=n5.1.2.3.4  Rho=100';
DSSText.Command='new line.line53 geometry=4wire23 length=25 units=km bus1=n5.1.2.3.4 bus2=n3.1.2.3.4  Rho=100';
DSSText.Command='new line.line36 geometry=4wire13 length=25 units=km bus1=n3.1.2.3.4 bus2=n6.1.2.3.4  Rho=100';
DSSText.Command='new line.line61 geometry=4wire13 length=25 units=km bus1=n6.1.2.3.4 bus2=n1.1.2.3.4  Rho=100';
DSSText.Command='New fault.Falla1   Bus1= n4.3   Bus2=n4.4 r=0.00001';
DSSText.Command='solve';
DSSSolution = DSSCircuit.Solution;
DSSLines = DSSObj.ActiveCircuit.Lines;
DSSActiveCktElement = DSSObj.ActiveCircuit.ActiveCktElement;
i = DSSCircuit.Lines.First;
while i > 0
I(i,:) = DSSActiveCktElement.Currents();
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