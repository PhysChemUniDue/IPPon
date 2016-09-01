function [] = saveData( data, settings, doPrint, dialog, Path )
% Saves the data from the SR430. Get the data with SR430.READDATA.

% v1.0 - 04.12.15
%

if doPrint
    fprintf( 'Saving data...\n' )
end

% Make the time data from the bin width
w = settings.BinWidth;
timeData = w:w:w*size( data,2 );

if dialog
    % Open put file dialog
    [FileName,PathName,FilterIndex] = uiputfile('*.csv','Save Data');
    if ~FilterIndex
        fprintf( '\tCancelled by user.\n' )
        return
    end
    
    Path = [PathName FileName];
end
% Open file
fileID = fopen( Path ,'w' );

% Make file header with current time and setting information
header = sprintf( ...
    ['%% STANFORD RESEARCH SYSTEMS - SR430\n' ...
    '%% Date\t%s\n' ...
    '%% Trigger Level\t%g\n' ...
    '%% Trigger Slope\t%g\n', ...
    '%% Trigger Offset\t%g\n', ...
    '%% Bin Width (ns)\t%g\n', ...
    '%% Bins Per Record\t%g\n', ...
    '%% Bin Clock\t%g\n', ...
    '%% Records Per Scan\t%g\n', ...
    '%% Discriminator Threshold\t%g\n', ...
    '%% Discriminator Slope\t%g\n'], ...
    datestr( clock ), ...
    settings.TriggerLevel, settings.TriggerSlope, settings.TriggerOffset, ...
    settings.BinWidth, settings.BinsPerRecord, settings.BinClock, ...
    settings.RecordsPerScan, ...
    settings.DiscrThreshLevel, settings.DiscrSlope);
fprintf( fileID, '%s\n', header );

% Specify data to write (timeData and data are both 1xn arrays and have to
% be transformed before writing them to a file)
D = [timeData; data]';

% Write data to file
dlmwrite( Path, D, '-append', 'delimiter', '\t' )

% Close file
fclose( fileID );

if doPrint
    fprintf( '\tSaved data to %s\n', Path )
end

end