function I = solve_pv_current(V, p, G, T)
% Solves the implicit single-diode equation for current I
% at a given voltage V using Newton-Raphson iteration
%
% V  : terminal voltage [V]
% p  : parameter struct
% G  : irradiance [W/m²]
% T  : temperature [K]

    q  = 1.60218e-19;
    k  = 1.38065e-23;
    
    Vt  = p.n * p.Ns * k * T / q;
    Iph = p.Isc * (G / p.G_ref);       % Photocurrent scales with G
    Io  = compute_io(p, T);
    
    I = Iph;   % Initial guess: start at short-circuit current
    
    for iter = 1:200
        exp_term = exp((V + I * p.Rs) / Vt);
        
        % Residual f(I) = 0
        f  = I - Iph + Io*(exp_term - 1) + (V + I*p.Rs)/p.Rsh;
        
        % Derivative df/dI
        df = 1 + Io * p.Rs * exp_term / Vt + p.Rs / p.Rsh;
        
        dI = f / df;
        I  = I - dI;
        
        if abs(dI) < 1e-9
            break
        end
    end
    
    I = max(0, I);   % Current cannot be negative
end