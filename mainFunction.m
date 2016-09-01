function [data,p] = mainFunction( Nshots, Ntotal )
%MAINFUNCTION( Nshots, Ntotal ) Starts the IR promoted photodesorption 
%experiment
%   Nshots: Number of shots that are accumulated per cycle
%   Ntotal: Number of cycles
%   
%   data: Outputs experimental raw data
%   p: Outputs plots

%% Open put-file dialog

[FileName,PathName,FilterIndex] = ...
    uiputfile( '*.csv', 'Save Data to File' );

if ~FilterIndex
    % User pressed cancel button
    disp( 'No file selected.' )
    disp( 'Cancelled Experiment' )
    data = [];
    return
end

%% Prepare SR430

% Reset Instruments
instrreset

% Establish connection to SR430
[~,obj] = SR430.connect( 0 );

% Clear previous measurements
invoke( obj, 'clear' );

% Set number of shots
obj.RecordsPerScan = Nshots;

% Get the settings of the SR430 - We need this to generate a time data
% array for live plotting during the measurement
ScalerSettings = SR430.getSettings( obj );
% Get the bin width
dt = ScalerSettings.BinWidth;
% Calculate the bin time Array
timeData = dt:dt:ScalerSettings.BinsPerRecord*dt;

% Set initial value for scan status
scanStatus = 0;

% Initialize data matrix
data = zeros( obj.BinsPerRecord*1024, Ntotal, 2, 'int16' ) * nan;

% Initialize trigger time array
triggerTime = zeros( 1, Ntotal*2 )*nan;

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

%% Prepare figure for live plot
countsAccu = squeeze( sum( data, 2 ) );
figure;
for i=1:2
    subplot(2,1,i)
    lp(i) = stairs( timeData*1e-6, countsAccu(:,i) );
    xlabel( 'Time [ms]' )
    ylabel( 'Counts' )
    if i==1
        title( 'Shutter Closed' )
    else
        title( 'Shutter Open' )
    end
end

%% Main Loop

% Create a waitbar
h = waitbar( 0, 'Initializing...' );

for i=1:0.5:Ntotal+1
    
    % Change Shutter Status
    if ShutterStatus == 1
        % If the shutter is open, close it
        ShutterStatus = 0;
    else
        % Otherwise open the shutter
        ShutterStatus = 1;
    end
    
    % Apply shutter status
    outputSingleScan( s, ShutterStatus )
    
    % Start Scan
    invoke( obj, 'startScan' );
    
    for k=1:2
        % Update live data
        
        % Accumulate counts
        countsAccu = squeeze( sum( data, 2 ) );
        
        lp(k).YData = countsAccu(:,k);
        
    end
    
    waitbar( i/Ntotal, h, 'Ready...' )
    
    tic
    while scanStatus < Nshots        
        % Wait until scans are finished
        
        % Get current number of scans
        scanStatus = invoke( obj, 'scanStatus' );
        % Pausing seems to prevent a timeout of the GPIB connection. Might
        % also be related to the readout malfunction case (see below).
        pause(0.001)
        
    end
    triggerTime(floor( i )*2-(1-ShutterStatus)) = toc;
    
    waitbar( i/Ntotal, h, 'Get Data...' )
    
    % Read data
    [dataAdd] = SR430.readData( obj,ScalerSettings.BinsPerRecord,0 );
    if numel( dataAdd ) ~= ScalerSettings.BinsPerRecord
        dataAdd = zeros( 1, ScalerSettings.BinsPerRecord );
        disp( 'Readout malfunction' )
    end
    data(:,floor( i ),ShutterStatus+1) = dataAdd;

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
SR430.saveData( data(:,:,1), ScalerSettings, 0, 0, [PathName, 'so_', FileName] )
SR430.saveData( data(:,:,2), ScalerSettings, 0, 0, [PathName, 'sc_', FileName] )

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
dt = ScalerSettings.BinWidth;
timeData = dt:dt:dt*ScalerSettings.BinsPerRecord;

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

pause(2)
close( h )

end

