function [processedData,timeData,settings] = readData( obj,doPrint )
% Reads data from SRS SR430

% Get instrument settings
settings = SR430.getSettings( obj );

%% Import Data

if doPrint
    fprintf( 'Importing data...\n' )
end

% Get Interface
g = obj.Interface;
fclose(g);

% Original Buffer Size
origBufferSize = g.InputBufferSize;

% Buffer size must match exactly the number of bytes that are returned plus
% the last line feed.
newBufferSize = settings.BinsPerRecord*2;

% Close the interface
fclose(g);
% Set new buffer size
g.InputBufferSize = newBufferSize;

% Reestablish connection
%g = gpib('ni',0,8);
%obj = icdevice('srs_sr430.mdd', g);
connect(obj);

% Read data
data = invoke( obj, 'readData' );

% Close the interface
fclose(g);
% Reset Buffer Size
g.InputBufferSize = origBufferSize;

if doPrint
    fprintf( '\tImported %g data points\n', numel( data )/2 )
end

%% Process the data
% The data is sent low byte first in 16 bit format. However reading 16 bit
% doesnt work, so the data is interpreted as unsigned 8 bit and then
% converted from decimal to 8 bit binary. After that the binary data is
% interpreted as unsigned 16 bit.

% Include fake data at the end so that you get 8bits from the next function
data(end+1) = -18;
data(end+1) = 1;

% Convert to binary
bin8 = dec2bin(typecast(int8(data),'uint8'));
% Flip
bin8flip = fliplr( bin8 );
% Preallocate 16 bit char matrix
bin16flip = repmat(char(0),size( bin8,1 )/2,16);

% Concentrate to 16 bit
for i=1:size(bin8,1)/2
    bin16flip(i,:) = horzcat( bin8flip(i*2-1,:), bin8flip(i*2,:) );
end
% Flip another time
bin16 = fliplr( bin16flip );
% Convert to decimal
dec = bin2dec( bin16 );

dec(end) = [];

% Define Processed data
processedData = dec';

% Make the time data from the bin width
w = settings.BinWidth;
timeData = w:w:w*numel( processedData );

end