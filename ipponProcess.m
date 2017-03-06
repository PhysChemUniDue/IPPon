function ipponProcess( data, Ntotal )
%IPPONPROCESS - Visualize acquired data from IPPon experiment

% Sum up all the counts for each single shot
countsSum = zeros( Ntotal,2 );
for j=1:3
    % Loop throught shutter states
    for i=1:Ntotal/3
        % Loop through shot number
        
        countsSum(i,j) = sum( data(:,i,j) );
        
    end
    
end

countsAccu = squeeze( sum( data, 2 ) );

% Generate time data from bin width
dt = ScalerSettings.BinWidth;
timeData = dt:dt:dt*ScalerSettings.BinsPerRecord;

figure;
hold on
p(1) = stairs( timeData*1e-3, countsAccu(:,2) - countsAccu(:,1) );
p(1).DisplayName = 'Shutter Open';
p(2) = stairs( timeData*1e-3, countsAccu(:,3) - countsAccu(:,1) );
p(2).DisplayName = 'Shutter Closed';
xlabel( 'Time [$\mu$s]' )
ylabel( 'Counts' )
title( 'Accumulated Signal without Background' )
legend( 'show' )

figure; 
hold on
p(3:5) = plot( countsSum, 'o' );
xlabel( 'Shot Number' )
ylabel( 'Total Counts' )
title( 'Integral per Shot' )

figure
p(5) = stairs( timeData*1e-3, countsAccu(:,2) - countsAccu(:,3) );
xlabel( 'Time  [us]' )
ylabel( 'Counts' )
title( 'Difference Spectrum' )


fprintf( 'Number of shots per shutter state: %g\n', Ntotal )
fprintf( 'Total counts with shutter open: %g\n', sum( sum( data(:,:,3) ) ) )
fprintf( 'Total counts with shutter closed: %g\n', sum( sum( data(:,:,2) ) ) )

end

