function Io = compute_io(p, T)
% Computes diode reverse saturation current
% p   : parameter struct (expects p.Isc, p.Voc, p.n, p.Ns)
%       When called from plot_temp_family, p is already temperature-corrected
%       (p.Voc = Voc_T, p.Isc = Isc_T) so the datasheet-point approximation
%       below is evaluated at the operating point, not just STC.
% T   : operating temperature in Kelvin
%
% NOTE — Simplified model:
%   Io is derived from the single operating-point relation Io ≈ Isc / (exp(Voc/Vt) - 1)
%   This is a standard undergraduate approximation (Tamrakar et al., 2015).
%   It does not model the full exponential temperature dependence of Io (∝ T³·exp(-Eg/kT)).
%   Accuracy is sufficient for I-V curve shape and MPP estimation across the
%   temperature range 0–75°C used in this project.

    q  = 1.60218e-19;   % Electron charge [C]
    k  = 1.38065e-23;   % Boltzmann constant [J/K]
    
    Vt = p.n * p.Ns * k * T / q;   % Thermal voltage [V]
    
    % Io derived from Voc and Isc at STC using the simplified relation
    Io = p.Isc / (exp(p.Voc / Vt) - 1);
end