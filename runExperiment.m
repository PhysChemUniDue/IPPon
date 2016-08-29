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
% Shutter status equals 1 is open state 2 is closed
ShutterStatus = 1;

%% Create data acquisition session for shutter control

% Create new session
s = daq.createSession( 'ni' );
% Continuous session
s.IsContinuous = true;

% Listener for feeding new output data
lh(1) = addlistener( s, 'DataRequired', ...
    @(src,event) feedShutter( event ) );

%% Main Loop

for i=1:Ntotal
    
    % Change Shutter Status
    if ShutterStatus == 1
        ShutterStatus = 2;
    else
        ShutterStatus = 1;
    end
    
    % Apply shutter status
    feedShutter( event )
    
    % Start Scan
    invoke( obj, 'startScan' );
    
    fprintf( 'Ready...\t' )
    
    while scanStatus < Nshots
        tic
        % Wait until scans are finished
        
        % Get current number of scans
        scanStatus = invoke( obj, 'scanStatus' );
        
    end
    triggerTime(i) = toc;
    
    fprintf( '%g/%g\n', i, Ntotal )
    
    % Read data
    [data(:,i,ShutterStatus),~,settings] = sr430_readData( obj,0 );
    
    % Connect and Clear SR430
    connect( obj )
    invoke( obj, 'clear' );
    
    % Reset scan status
    scanStatus = 0;
    
end

%% Save

% Save data
SR430.saveData( data(:,:,1), settings, 0, 0, [PathName, 'so_', FileName] )
SR430.saveData( data(:,:,2), settings, 0, 0, [PathName, 'sc_', FileName] )

% Disconnect
disconnect(obj);
% Delete all interface objects
instrreset

% Save all the variables as matlab binary
save( [FolderName, FileName, '_ExperimentalData.mat' ])

%% Display experimental results

% Sum up all the counts for each singe shot
for j=1:2
    % Loop throught shutter states
    for i=1:Ntotal
        % Loop through shot number
        
        countsSum(i,j) = sum( data(:,i,j) );
        
    end
    
end

countsAccu = squeeze( sum( data, 2 ) );

figure;hold on
p(1) = stairs( timeData, countsAccu(:,1) );
p(1).DisplayName = 'Shutter Open';
p(2) = stairs( timeData, countsAccu(:,2) );
p(2).DisplayName = 'Shutter Closed';
xlabel( 'Time [ms]' )
ylabel( 'Counts' )
title( 'Accumulated Signal' )
legend( 'show' )

figure
p(3) = plot( countsSum, 'o' );
xlabel( 'Shot Number' )
ylabel( 'Total Counts' )
title( 'Integral per Shot' )

figure
p(4) = plot( triggerTime, 'o-' );
xlabel( 'Shot Number' )
ylabel( 'Time Waited for Trigger [s]' )
title( 'Trigger Time' )

%% Output dialog
disp('Experiment Done!')

%%
%%%%%%%%%%%%%%%%%%%%%%
% Subfunctions
%%%%%%%%%%%%%%%%%%%%%%

    function feedShutter( ~ )
        % Give shutter new data
        
        % Generate output data
        if ShutterStatus == 1
            outputData = ones( 1000, 1 )*5;
        else
            outputData = zeros( 1000, 1 );
        end
        
        % Queue output data
        queueOutputData( s, outputData )
        
    end

end

