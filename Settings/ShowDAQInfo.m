% Load Channel Settings

settings = load( 'ChannelDefinitions.mat' );

fprintf( 'Configured Instruments:\n\n' )

% Get variable names of instruments (Output as cell array)
InstrumentNames = fieldnames( settings );
for i=1:numel( InstrumentNames )
    
    fprintf( 'Name: %s\n', InstrumentNames{i} )
    fprintf( '\tChannel: %s\n', settings.(InstrumentNames{i}).Channel )
    fprintf( '\tBoard: %s\n\n', settings.(InstrumentNames{i}).Board )
    
end