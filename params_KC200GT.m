
% Source: Kyocera KC200GT datasheet
% STC: G = 1000 W/m², T = 25°C, AM1.5

function p = params_KC200GT()
    p.Isc  = 8.21;    % Short-circuit current [A]
    p.Voc  = 32.9;    % Open-circuit voltage [V]
    p.Impp = 7.61;    % Current at MPP [A]
    p.Vmpp = 26.3;    % Voltage at MPP [V]
    p.Pmax = 200.143;     % Rated power [W]
    p.Ns   = 54;      % Number of cells in series
    p.n    = 1.3;     % Diode ideality factor
    p.Rs   = 0.221;    % Series resistance [Ohm]
    p.Rsh  = 415.0;     % Shunt resistance [Ohm]
    p.Tref = 298.15;  % Reference temperature [K] (25°C)
    p.G_ref= 1000;    % Reference irradiance [W/m²]
end