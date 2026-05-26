% =========================================================
% Project 1: PV Module I-V & P-V Curve Simulation
% Single-Diode Model — Newton-Raphson Solution
% Module: KC200GT Polycrystalline (200 W)
% Author: Nazmul Islam Shimul, Petroleum & Mining Engineering, JUST
% =========================================================

clc; clear; close all;

% Load parameters
p = params_KC200GT();

% Create output folder if it doesn't exist
if ~exist('figures','dir'), mkdir('figures'); end

fprintf('=== PV Module Simulation ===\n');
fprintf('Module: KC200GT | Ns=%d cells | Prated=%.0f W\n\n', p.Ns, p.Pmax);

% --- Run irradiance family ---
fprintf('Plotting I-V/P-V irradiance sweep...\n');
plot_iv_family(p);

% --- Run temperature family ---
fprintf('Plotting I-V/P-V temperature sweep...\n');
plot_temp_family(p);

% --- Print key parameters at STC ---
fprintf('\n--- STC Results (G=1000, T=25°C) ---\n');
G_stc = 1000;    % Standard Test Condition irradiance [W/m²]
T_stc = 298.15;  % Standard Test Condition temperature [K] (25°C)
V_range = linspace(0, p.Voc, 1000);
I_range = arrayfun(@(v) solve_pv_current(v, p, G_stc, T_stc), V_range);
P_range = V_range .* I_range;
[Pmax, idx] = max(P_range);
FF = Pmax / (p.Isc * p.Voc) * 100;

fprintf('Pmax  = %.2f W\n', Pmax);
fprintf('Vmpp  = %.2f V\n', V_range(idx));
fprintf('Impp  = %.2f A\n', I_range(idx));
fprintf('FF    = %.2f %%\n', FF);
fprintf('Voc   = %.2f V\n', p.Voc);
fprintf('Isc   = %.2f A\n', p.Isc);