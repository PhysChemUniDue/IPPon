function setMass( mass, range )
% SETMASS Sets the mass of the QMS311
%   SETMASS( MASS, RANGE ) sets the device to the mass specified by
%   'mass' in atomic mass units. The 'range' has to be specified and can
%   have values of 100 or 300.

% Calculate output Voltage
outputVoltage = QMS311.calcOutputVoltage( mass, range );

% fprintf( 'Setting mass to %g u (Range: %d u) ...\n', mass, range );

% Create Data Acquisition session
s = daq.createSession( 'ni' );

% Set duration (2 ms seems to be minimum time)
s.DurationInSeconds = 4e-3;
% Set Rate in Hz
s.Rate = 10000;
% Log unitl abort
s.IsContinuous = false;

% Calculate number of scans
numScans = s.Rate*s.DurationInSeconds;

% Open output channel to set mass
CD = load( 'Settings/ChannelDefinitions.mat' );
addAnalogOutputChannel( s, CD.QMSSet.Board, CD.QMSSet.Channel, 'Voltage' );

% Create an array of the desired Voltage which is sent to the analog
% output.
outputData = zeros(numScans, 1) + outputVoltage;
queueOutputData( s, outputData );

% Start sending
s.startBackground

% fprintf( '\tDone.\n')

end