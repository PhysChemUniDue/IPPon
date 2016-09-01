% IPPON - INFRARED PROMOTED PHOTODESORPTION
% 

%% Experiment Parameters

% NShots sets the numer of shots wich are accumulated before loading the
% data from the SR430 and switching the shutter status.
NShots = 1;

% Ntotal is the total amount of shots which are accumulated for both
% shutter states.
Ntotal = 500;

%% QMS311 Parameters

% Mass to scan in amu
mass = 28.3;

% Range (can be set to 100 or 300 amu at the control unit)
range = 100;

% Set the mass of the QMS311
QMS311.setMass( mass,range )

%% SR430 Scaler Parameters

% Connect to the unit
[g,obj] = SR430.connect( 0 );

% BinClock sets or reads the bin clock time base. 0 selects 
% internal, while 1 selects external. When set to external, the EXT BIN CLK
% input determines the width of each bin.
obj.BinClock = 0;

% BinsPerRecord sets or reads the bins per record. The record length is 
% programmed in 1k (1024) steps. The parameter is an integer from 1 to 16. 
% If the parameter is 1, the record length is 1k (1024). If it is 2, the 
% record length is 2k (2048), and so on. The maximum value is 16 for a 
% maximum record length of 16k (16,384).
obj.BinsPerRecord = 2;

% BinWidth selects the internal time base bin width. 0 corresponds to a bin
% width of 5 ns, 1 corresponds to 40 ns. The bin width is then doubled each
% time to a maximum value of 10.486 ms at a value of 19.
obj.BinWidth = 6;

% DiscrSlope selects the discriminator slope. 0 selects positive or rising 
% slope, while 1 selects negative or falling slope.
obj.DiscrSlope = 0;

% DiscrThreshLevel sets or reads the discriminator threshold level. Minimum
% Value is -0.300 V, maximum value is 0.300 V. Increment is 0.0002 V.
obj.DiscrThreshLevel = -0.02;

% RecordsPerScan sets or reads the records per scan. The records per scan 
% is the number of records which will be accumulated. The records/scan may 
% be programmed from 0 ? i ? 65535. When set to 0, accumulation will 
% continue indefinitely.
obj.RecordsPerScan = NShots;

% TriggerLevel sets or reads the trigger threshold level where -2.000 ? x 
% ? 2.000. The resolution is .001V.
obj.TriggerLevel = 0.348;

% TriggerOffset sets or reads the trigger offset. The trigger offset may be 
% programmed from 0 to 16320 in increments of 16. The value of i is rounded 
% to the nearest multiple of 16.
obj.TriggerOffset = 0;

% TriggerSlope selects the trigger slope. 0 selects positive or rising 
% slope, while 1 selects negative or falling slope.
obj.TriggerSlope = 0;

% Disconnect from the unit
SR430.disconnect( g,obj,0 );

%% Start the experiment

% Execute main function
[data,p] = mainFunction( Nshots, Ntotal );