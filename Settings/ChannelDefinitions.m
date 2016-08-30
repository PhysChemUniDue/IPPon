%%% CHANNEL DEFINITIONS %%%%

% Cleanup
clc,clear,close all

% Get all devices
try
    devices = daq.getDevices;
catch
    disp( 'DAQ toolbox missing!' )
    return
end

%% BOARD 1
% National Instruments PCI-6024E

% Get device
Device01 = devices(1);
Device02 = devices(2);

%% Configure analog inputs
% The subsystem index for analog inputs on the board is 1
AnalogIn = 1;

%% Thermocouple In
% Reads temperature at sample in UHV chamber in the range of 0 - 10
% V.

% Define channel index
AnalogInID = 3;
% Set channel ID (index + 1 because Matlab indices start with 1 while the
% board starts with 0)
Temperature.Channel = ...
    Device02.Subsystems(AnalogIn).ChannelNames{AnalogInID + 1};
Temperature.Board = Device02.ID;

%% Delta Elektronika SM7020 Current Monitor
% Monitors the Current output of the SM 7020.

% Define channel index
AnalogInID = 5;
% Set channel ID (index + 1 because Matlab indices start with 1 while the
% board starts with 0)
SM7020_Iin.Channel = ...
    Device02.Subsystems(AnalogIn).ChannelNames{AnalogInID + 1};
SM7020_Iin.Board = Device02.ID;





%% Configure analog outputs
% The subsystem index for analog inputs on the board is 1
AnalogOut = 2;

%% Mass Spectrometer QMS311
% Voltage output sets the mass for the QMS 311

% Define channel index
AnalogOutID = 1;
% Set Channel
% Set channel IDs (index + 1 because Matlab indices start with 1 while the
% board starts with 0)
QMSSet.Channel = ...
    Device02.Subsystems(AnalogOut).ChannelNames{AnalogOutID + 1};
QMSSet.Board = Device02.ID;

%% Shutter Control
% Controls the output voltage of the Delta Elektronika SM 7020 (range for
% remote controlling is 0 - 5 V)

% Define channel index
AnalogOutID = 0;
% Set Channel
% Set channel IDs (index + 1 because Matlab indices start with 1 while the
% board starts with 0)
Shutter.Channel = ...
    Device02.Subsystems(AnalogOut).ChannelNames{AnalogOutID + 1};
Shutter.Board = Device02.ID;

%% Save as file
% Save the settings in a .mat file in the same folder
save( [pwd '/Settings/ChannelDefinitions.mat'], ...
    'QMSSet', ...
    'Shutter', ...
    'Temperature' )

%% Cleanup
clear

%% Output notifier
open ChannelDefinitions.mat