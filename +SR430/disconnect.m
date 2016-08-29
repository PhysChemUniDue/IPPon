function disconnect( g,obj,doPrint )
% Disconnects from Stanford Research Systems - SR430 Averager/Scaler
%
%   DISCONNECT(g,obj,doPrint) where g is the gpib device, obj the device
%   object. doPrint (1 or 0) detemines if the status is printed to the
%   command window.
%

%% Disconnect and delete the object

if doPrint
    fprintf( 'Disconnecting...\n' )
end
disconnect(obj);
delete( [obj g] )
if doPrint
    fprintf( '\tDone.\n' )
end

end