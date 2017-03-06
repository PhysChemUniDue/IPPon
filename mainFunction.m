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

% Set initial shutter thingy
ShutterCounter = 1;

% Set shot counter
ShotCounter = 0;

% Initialize data matrix
data = zeros( obj.BinsPerRecord*1024, Ntotal, 3, 'int16' ) * nan;

%% Initial shutter status
% Shutter status equals 0 is open state 1 is closed. Shutter status is
% changed at the beginning of the main loop, so the measurement starts with
% the shutter closed.
ShutterStatus = [1 1];

%% Create data acquisition session for shutter control

% Create new session
s = daq.createSession( 'ni' );

% Load Channel Definitions
try
    load( [pwd, '/Settings/ChannelDefinitions.mat'] )
catch
    disp( 'Could not load the ChannelDefinitions.mat file. You need to be in the Experiments main folder.' )
    instrreset
    return
end

% Add Digital Output channel for the shutters
addDigitalChannel( s, Shutter.Board, Shutter.Channel, 'OutputOnly' );
addDigitalChannel( s, Shutter2.Board, Shutter2.Channel, 'OutputOnly' );
% Add counter channel for the Polaris Flashlamp Sync OUT
addCounterInputChannel(s,'Dev2','ctr0', 'EdgeCount');

%% Prepare figure for live plot
countsAccu = squeeze( sum( data, 2 ) );
figure;
for i=1:3
    subplot(3,1,i)
    lp(i) = stairs( timeData*1e-6, countsAccu(:,i) );
    xlabel( 'Time [ms]' )
    ylabel( 'Counts' )
    if i==1
        title( 'Background' )
    elseif i==2
        title( 'Shutter Closed' )
    elseif i==3
        title( 'Shutter Open' )
    end
end

%% Main Loop

% Create a waitbar
h = waitbar( 0, 'Initializing...' );

% Syncronize the measurement cycle via the Polaris flashlamp. We set a
% fixed time when the flashlamp fired (this is approximately at the same
% time the Q-Switch is triggered).
waitbar( 0, h, 'Synchronizing Flashlamp Trigger...' )

[waitTime,s] = flashSync(s);

% Start timing
tic

Ntotal = Ntotal*3;
for i=1:Ntotal
    % Measurement is here
    
    waitbar( i/Ntotal, h, 'Ready...' )
    
    % Change Shutter Status
    if ShutterCounter == 1
        % Start with UV open
        ShutterStatus = [0 1];
        ShutterCounter = 2;
        % Increment shot counter
        ShotCounter = ShotCounter+1;
    elseif ShutterCounter == 2
        % Background
        ShutterStatus = [0 0];
        ShutterCounter = 3;
    elseif ShutterCounter == 3
        % UV only again
        ShutterStatus = [0 1];
        ShutterCounter = 4;        
        % Increment shot counter
        ShotCounter = ShotCounter+1;
    elseif ShutterCounter == 4
        % With IR
        ShutterStatus = [1 1];
        ShutterCounter = 5;
        % Increment shot counter
        ShotCounter = ShotCounter-1;
    elseif ShutterCounter == 5
        % Background again
        ShutterStatus = [0 0];
        ShutterCounter = 6;        
        % Increment shot counter
        ShotCounter = ShotCounter+1;
    elseif ShutterCounter == 6
        % And IR
        ShutterStatus = [1 1];
        ShutterCounter = 1;        
        % Increment shot counter
        ShotCounter = ShotCounter+0;
    end
    
    % Apply shutter status
    outputSingleScan( s, ShutterStatus )
    
    for k=1:3
        % Update live data
        
        % Accumulate counts
        countsAccu = squeeze( sum( data, 2 ) );
        
        lp(k).YData = countsAccu(:,k);
        
    end
    
    while toc < waitTime
        % Wait for appropriate time to start scan
    end
    % Start Scan
    invoke( obj, 'startScan' );
    
    % Resync flashlamp
    resetCounters(s)
    while inputSingleScan(s) < 1
        % Wait for flashlamp to fire
    end
    tic
    
    while scanStatus < Nshots        
        % Wait until scans are finished
        
        % Get current number of scans
        scanStatus = invoke( obj, 'scanStatus' );
        % Pausing seems to prevent a timeout of the GPIB connection. Might
        % also be related to the readout malfunction case (see below).
        pause(10e-6)
        
    end
    
    waitbar( i/Ntotal, h, 'Getting Data...' )
    
    % Read data
    [dataAdd] = SR430.readData( obj,ScalerSettings.BinsPerRecord,0 );
    if numel( dataAdd ) ~= ScalerSettings.BinsPerRecord
        dataAdd = zeros( 1, ScalerSettings.BinsPerRecord );
        disp( 'Readout malfunction' )
    end
    data(:,ShotCounter,sum(ShutterStatus)+1) = dataAdd;

    % Connect and Clear SR430
    invoke( obj, 'clear' );
    
    % Reset scan status
    scanStatus = 0;
    
end

%% Close the shutters when finished
outputSingleScan( s,[0 0] )

%% Save

waitbar( i/Ntotal, h, 'Saving...' )

% Save data
SR430.saveData( data(:,:,3), ScalerSettings, 0, 0, [PathName, 'so_', FileName] )
SR430.saveData( data(:,:,2), ScalerSettings, 0, 0, [PathName, 'sc_', FileName] )
SR430.saveData( data(:,:,1), ScalerSettings, 0, 0, [PathName, 'bg_', FileName] )

% Disconnect
disconnect(obj);
% Delete all interface objects
instrreset

% Save all the variables as matlab binary
save( [PathName, FileName, '_ExperimentalData.mat' ])

%% Display experimental results

waitbar( i/Ntotal, h, 'Processing...' )

ipponProcess( data, Ntotal, ScalerSettings )

%% Close things

waitbar( i/Ntotal, h, 'Done.' )
disp('Experiment Done!')

pause(2)
close( h )

end

