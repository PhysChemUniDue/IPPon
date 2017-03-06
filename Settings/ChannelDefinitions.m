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






%% Configure Digital IOs
% The subsystem index for digital IO on the board is 3
DigitalIO = 3;

%% Shutter Control
% Controls the shutter

% Define channel index
DigitalIOID = 0;
% Set Channel
% Set channel IDs (index + 1 because Matlab indices start with 1 while the
% board starts with 0)
Shutter.Channel = ...
    Device02.Subsystems(DigitalIO).ChannelNames{DigitalIOID + 1};
Shutter.Board = Device02.ID;


%% Second Shutter


DigitalIOID = 1;

Shutter2.Channel = ...
    Device02.Subsystems(DigitalIO).ChannelNames{DigitalIOID + 1};
Shutter2.Board = Device02.ID;






%% Save as file
% Save the settings in a .mat file in the same folder
save( [pwd '/ChannelDefinitions.mat'], ...
    'QMSSet', ...
    'Shutter', ...
    'Shutter2', ...
    'Temperature' )

%% Cleanup
clear

%% Output notifier
open ChannelDefinitions.mat