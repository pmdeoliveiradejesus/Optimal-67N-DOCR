
global Dmin Co nr Rg S3a S3b S3c pf3a pf3b pf3c k1 k2 k3 compile_path
%% OpenDSS compile path, you must include your path here!
compile_path='Compile (C:\Users\VaioPC\OneDrive - Universidad de los Andes\Optimal-67N-DOCR-coordination\IEEE-IAS\matlab\GridModel.dss)';
% Optimal DOCR coordination problem - Dataset pm.deoliveira@uniandes.edu.co
% ---------------------------------------
% Modified 3 bus test system --> Optimal coordination of directional 
% overcurrent relays in interconnected power systems, 
% IEEE Transactions on Power Delivery, Volume 3, No. 3, July 1988
%             N1   L1    N2
%        G1---|-R1-*--R2-|---G2
%             R6   N4    R3
%               \      /
%          L3 N6 *    * N5 L2
%                 \  /
%                 R5 R4
%                  -- N3
%                  |__ G3
%
% relays R i=1,2,3,4,5,6
% lines L k=1,2,3
% nodes N j=1,2,3,4,5,6
%         <-back-><-main-><-back-----><---main->
%      relayi faultk i  k  nsend nrec nsend nrec
% index=[	5	 1	 1	1	3      6    1	4;
% 	        4	 1	 2	1	3      5    2   4;
% 	        1	 2   3	2	1      4    2	5;
% 	        6	 2	 4	2	1      6    3	5;
% 	        3	 3	 5	3	2      5    3	6;
% 	        2	 3	 6	3	2      4    1	6];
%Coordination matrix
%|----|bk - mn|bk - mn|
%      i k i k  nodes
index=[5,1,1,1,3,6,1,4;
       1,2,3,2,1,4,2,5;
       3,3,5,3,2,5,3,6;
       4,1,2,1,3,5,2,4;
       6,2,4,2,1,6,3,5;
       2,3,6,3,2,4,1,6];
%%  
% Near end and near far fault location (1 meter from relay i)
L= [
2.0000e-05  2.5000e-05 1.6667e-05 
 1-2.0000e-05  1-2.5000e-05 1-1.6667e-05 
 ];
n=length(L(:,1));
qmax=45;% Max angle between backup and principal sc currents regardes as same direction
%% Relay data %%%%%%
Co=.2;% allowable coordination interval (seconds)
%Relay curve settings, Standard Inverse (SI) IEC 60255
k1=.14;k2=0.02;k3=-1;

Dmin=0.1; % minimal dial setting
nr=6;
% Load at bus 3 kVA
S3a=000; 
S3b=000; 
S3c=000;
pf3a=000.8; 
pf3b=000.8; 
pf3c=000.8;
Rg=0.000001;% Ground pole resistance in ohms