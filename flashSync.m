function [ waitTime,s ] = flashSync( s )
%FLASHSYNC - Synchronizes the with the flashlamp trigger to determine the
%time to wait between each shot. This is because the flashlamp fires with a
%lower repetition rate than the q-switch is triggered which is at 20 Hz
%(fires every 50 ms). So after the flashlamp fires we wait for the
%flashlamp to fire again minus a specified time T
%(which is specified below) before we wait for the q-switch trigger.
% s is the daq session object.

% Time to wait for q-switch after flashlamp fired in s
T = 0.040;

% Reset the counter
resetCounters(s)

% Prepare array for periods between flashlamp shots
flashlampTime = zeros( 1,9 );
% Add shot index
i=1;
% Start timing
tic
while i<10
    % Loop until flashlamp fired
    if inputSingleScan(s) > i-1
        % Time beteween start and now
        flashlampTime(i) = toc;
        % Increment
        i = i+1;
    end
end

% Time between each shot
flashlampPeriods = diff(flashlampTime);
% Mean Period
meanFlashlampPeriod = mean( flashlampPeriods );
% Determine time to wait
waitTime = meanFlashlampPeriod - T;

fprintf( 'Polaris flashlamp fires with %.3f Hz.\n Setting time to wait after each data acquisition from SR430 to %.3f s.\n', 1/meanFlashlampPeriod, waitTime )

% Set fixed sync time with flashlamp trigger
resetCounters(s)
while inputSingleScan(s) < 1
    % Wait for flashlamp to fire
end

end

