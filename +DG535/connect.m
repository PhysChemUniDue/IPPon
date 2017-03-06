function [g, obj] = connect()
% Connects to the Stanford Research Systems - SR430 Averager/Scaler
%
%   obj = CONNECT(  ) returns the device object obj.

%% Parameter Definitions

% Set board vendor
vendor = 'ni';
% Set board index
boardIndex = 0;
% Set primary address (Can be changed via the SR430 interface)
primAddress = 15;
% Set instrument driver
instrDriver = 'srs_dg535.mdd';


%% Establish connection

% Create GPIB object
g = gpib(vendor,boardIndex,primAddress);
% Create device object
obj = icdevice(instrDriver, g);
% Connect to the device
connect(obj);

end