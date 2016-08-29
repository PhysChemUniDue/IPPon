function [settings] = getSettings( obj )
% Connects to the Stanford Research Systems - SR430 Averager/Scaler
%
%   [settings] = GETSETTINGS( obj ) returns the settings of the SR430 as
%       a structure. Obj is the device object.
%
%   Fields:
%   TriggerLevel (in V)
%   TriggerSlope
%   TriggerOffset
%   BinWidth (in ns)
%   BinsPerRecord
%   BinClock
%   RecordsPerScan
%   DiscrSlope
%   DiscrThreshold
%

%
% v1.0 - 04.12.15
%

%% Get settings
settings.TriggerLevel = obj.TriggerLevel;
settings.TriggerSlope = obj.TriggerSlope;
settings.TriggerOffset = obj.TriggerOffset;
settings.BinWidth = invoke(obj,'getBinWidth');
settings.BinsPerRecord = obj.BinsPerRecord*1024;
settings.BinClock = obj.BinClock;
settings.RecordsPerScan = obj.RecordsPerScan;
settings.DiscrSlope = obj.DiscrSlope;
settings.DiscrThreshLevel = obj.DiscrThreshLevel;

end