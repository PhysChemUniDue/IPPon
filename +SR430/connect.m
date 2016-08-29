function [g,obj] = connect( doPrint )
% Connects to the Stanford Research Systems - SR430 Averager/Scaler
%
%   [g,obj] = CONNECT( doPrint ) returns the gpib object g and the device
%   object obj. doPrint (1 or 0) detemines if the status is printed to the
%   command window.
%

%% Parameter Definitions

% Set board vendor
vendor = 'ni';
% Set board index
boardIndex = 0;
% Set primary address (Can be changed via the SR430 interface)
primAddress = 8;
% Set instrument driver
instrDriver = 'srs_sr430.mdd';


%% Establish connection

if doPrint
    fprintf( 'Connecting to SRS SR430...\n' )
end

% Create GPIB object
g = gpib(vendor,boardIndex,primAddress);
% Create device object
obj = icdevice(instrDriver, g);
% Connect to the device
connect(obj);

if doPrint
    fprintf( '\tDone.\n' )
end

end