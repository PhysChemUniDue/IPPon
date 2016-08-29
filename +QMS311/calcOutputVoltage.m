function  outputVoltage = calcOutputVoltage( mass, range )
% CALCOUTPUTVOLTAGE Sets the mass of the QMG311
%   CALCOUTPUTVOLTAGE( MASS, RANGE )calculates the output voltage
%   which has to be sent to the QMG311 to set the specified
%   'mass' in atomic mass units. The 'range' has to be specified and can
%   have values of 100 or 300.

% Check if correct range is set. Otherwise set it to 100.
% if range ~= 100 || range ~= 300
%     range = 100;
% end

outputVoltage = mass*10/range;

end