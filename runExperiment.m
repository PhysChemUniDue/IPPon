function runExperiment( mass, range, Nshots, Ntotal )
%RUNEXPERIMENT( mass, range ) Starts the IR promoted photodesorption 
%experiment
%   mass: Mass of the particle in amu that shall be detected by the QMS
%   range: Mass range that is set at the QMS control unit (100 or 300 amu)
%   Nshots: Number of shots that are accumulated per cycle
%   Ntotal: Number of cycles

%% Open put-file dialog

[FileName,PathName,FilterIndex] = ...
    uiputfile( '*.csv', 'Save Data to File' );

if ~FilterIndex
    % User pressed cancel button
    disp( 'No file selected.' )
    disp( 'Cancelled Experiment' )
    return
end


%% Set the mass of the QMS

fprintf( 'Setting QMS311 mass to %g u...\n', mass )
QMS311.setMass( mass,range )
fprintf( '\tDone.\n' )

%% Prepare SR430

% Reset Instruments
instrreset

% Establish connection to SR430
[~,obj] = SR430.connect( 0 );

% Clear previous measurements
invoke( obj, 'clear' );

% Set number of shots
obj.RecordsPerScan = Nshots;

% Set initial value for scan status
scanStatus = 0;

% Initialize data matrix
data = zeros( obj.BinsPerRecord*1024, Ntotal, 2, 'int16' ) * nan;

triggerTime = zeros( 1, Ntotal )*nan;

%% Initial shutter status
% Shutter status equals 1 is open state 0 is closed. Shutter status is
% changed at the beginning of the main loop, so the measurement starts with
% the shutter closed.
ShutterStatus = 1;

%% Create data acquisition session for shutter control

% Create new session
s = daq.createSession( 'ni' );

% Load Channel Definitions
load( [pwd, '/Settings/ChannelDefinitions.mat'] )

% Add Digital Output channel for the shutter
addDigitalChannel( s, Shutter.Board, Shutter.Channel, 'OutputOnly' );

%% Main Loop

% Create a waitbar
h = waitbar( 0, 'Initializing...' );

for i=1:Ntotal
    
    % Change Shutter Status
    if ShutterStatus == 1
        % If the shutter is open, close it
        ShutterStatus = 0;
    else
        % Otherwise open the shutter
        ShutterStatus = 1;
        % Reset the counter to it's previous value, so that both for the
        % blind measurement and the actual measurement there are Nshots
        % data points. In addition we do not want to skip entries in the
        % data matrix.
        i = i-1;
    end
    
    % Apply shutter status
    outputSingleScan( s, ShutterStatus )
    
    % Start Scan
    invoke( obj, 'startScan' );    
    
    waitbar( i/Ntotal, h, 'Ready...' )
    
    tic
    while scanStatus < Nshots        
        % Wait until scans are finished
        
        % Get current number of scans
        scanStatus = invoke( obj, 'scanStatus' );
        
    end
    triggerTime(i) = toc;
    
    waitbar( i/Ntotal, h, 'Get Data...' )
    
    % Read data
    [data(:,i,ShutterStatus+1),~,settings] = SR430.readData( obj,0 );
    
    % Connect and Clear SR430
    invoke( obj, 'clear' );
    
    % Reset scan status
    scanStatus = 0;
    
end

%% Close the shutter when finished
outputSingleScan( s,0 )

%% Save

waitbar( i/Ntotal, h, 'Saving...' )

% Save data
SR430.saveData( data(:,:,1), settings, 0, 0, [PathName, 'so_', FileName] )
SR430.saveData( data(:,:,2), settings, 0, 0, [PathName, 'sc_', FileName] )

% Disconnect
disconnect(obj);
% Delete all interface objects
instrreset

% Save all the variables as matlab binary
save( [PathName, FileName, '_ExperimentalData.mat' ])

%% Display experimental results

waitbar( i/Ntotal, h, 'Processing...' )

% Sum up all the counts for each singe shot
countsSum = zeros( Ntotal,2 );
for j=1:2
    % Loop throught shutter states
    for i=1:Ntotal
        % Loop through shot number
        
        countsSum(i,j) = sum( data(:,i,j) );
        
    end
    
end

countsAccu = squeeze( sum( data, 2 ) );

% Generate time data from bin width
dt = settings.BinWidth;
timeData = dt:dt:dt*settings.BinsPerRecord;

figure;hold on
p(1) = stairs( timeData, countsAccu(:,1) );
p(1).DisplayName = 'Shutter Open';
p(2) = stairs( timeData, countsAccu(:,2) );
p(2).DisplayName = 'Shutter Closed';
xlabel( 'Time [ms]' )
ylabel( 'Counts' )
title( 'Accumulated Signal' )
legend( 'show' )

figure; hold on
p(3:4) = plot( countsSum, 'o' );
xlabel( 'Shot Number' )
ylabel( 'Total Counts' )
title( 'Integral per Shot' )

figure
p(5) = plot( triggerTime, 'o-' );
p(5).DisplayName = 'Trigger Time';
xlabel( 'Shot Number' )
ylabel( 'Time Waited for Trigger [s]' )
title( 'Trigger Time' )

%% Output dialog
waitbar( i/Ntotal, h, 'Done.' )
disp('Experiment Done!')

end

