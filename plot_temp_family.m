function plot_temp_family(p)
% Plots I-V and P-V curves for 5 temperature levels using cell arrays
% Optimized architecture: Computes all physics first, visualizes second.

    T_celsius = [0, 25, 40, 50, 75];        % Operating temperatures in °C
    G         = 1000;                       % Fixed irradiance [W/m²]
    N_pts     = 500;                        % Resolution

    beta_Voc  = -0.123;    % V/°C 
    alpha_Isc =  0.00318;  % A/°C 

    % Pre-compute maximum open-circuit voltage for x-axis headroom
    Voc_max = p.Voc + beta_Voc * (min(T_celsius) - 25);

    % Pre-allocate Cell Arrays for Data Storage ---
    V_all    = cell(1, length(T_celsius));
    I_all    = cell(1, length(T_celsius));
    P_all    = cell(1, length(T_celsius));
    all_Pmax = zeros(1, length(T_celsius));
    mpp_idx  = zeros(1, length(T_celsius));

  
    % 1. COMPUTATION PHASE (Runs Newton-Raphson only 2,500 times)

    for ti = 1:length(T_celsius)
        T_kelvin = T_celsius(ti) + 273.15;
        
        Voc_T = p.Voc + beta_Voc  * (T_celsius(ti) - 25);
        Isc_T = p.Isc + alpha_Isc * (T_celsius(ti) - 25);
        
        p_T     = p;
        p_T.Voc = Voc_T;
        p_T.Isc = Isc_T;

        V = linspace(0, Voc_T * 1.05, N_pts); 
        I = zeros(1, N_pts);

        for vi = 1:N_pts
            I(vi) = solve_pv_current(V(vi), p_T, G, T_kelvin);
        end

        valid = I >= 0;
        V_all{ti} = V(valid);
        I_all{ti} = I(valid);
        P_all{ti} = V(valid) .* I(valid);

        % Track MPP values and array positions for clean labeling later
        [all_Pmax(ti), mpp_idx(ti)] = max(P_all{ti});
    end

  
    % 2. VISUALIZATION PHASE (No physics equations, pure plotting)
 
    colors = [0.20 0.60 1.00;   
              0.93 0.69 0.13;   
              0.85 0.33 0.10;   
              0.70 0.10 0.10;   
              0.40 0.00 0.00];  

    figure('Name','I-V and P-V Curves — Temperature Sweep',...
           'Color','white','Position',[120 120 1100 480]);

    % --- Left Subplot: I-V Curves ---
    ax1 = subplot(1,2,1); hold on; grid on; box on;
    for ti = 1:length(T_celsius)
        plot(V_all{ti}, I_all{ti}, 'Color', colors(ti,:), 'LineWidth', 1.8,...
             'DisplayName', sprintf('T = %d°C', T_celsius(ti)));

        % Plot max power point marker using stored index
        idx = mpp_idx(ti);
        plot(V_all{ti}(idx), I_all{ti}(idx), 'o', 'Color', colors(ti,:),...
             'MarkerFaceColor', colors(ti,:), 'MarkerSize', 6,...
             'HandleVisibility','off');
    end
    xlabel('Voltage V (V)', 'FontSize', 12);
    ylabel('Current I (A)', 'FontSize', 12);
    title('I-V Characteristics', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location','southeast','FontSize',10);
    xlim([0, Voc_max * 1.08]);
    ylim([0, max(cellfun(@max, I_all)) * 1.1]);
    set(ax1, 'FontSize', 11);

    % --- Right Subplot: P-V Curves ---
    ax2 = subplot(1,2,2); hold on; grid on; box on;
    for ti = 1:length(T_celsius)
        plot(V_all{ti}, P_all{ti}, 'Color', colors(ti,:), 'LineWidth', 1.8,...
             'DisplayName', sprintf('T = %d°C', T_celsius(ti)));

        % Label maximum wattage with Issue 2's dynamic styling
        idx = mpp_idx(ti);
        Pmax = all_Pmax(ti);
        plot(V_all{ti}(idx), Pmax, 'o', 'Color', colors(ti,:),...
             'MarkerFaceColor', colors(ti,:), 'MarkerSize', 6,...
             'HandleVisibility','off');

        text(V_all{ti}(idx) + 0.5, Pmax * 1.03, sprintf('%.0fW', Pmax),...
             'FontSize', 9, 'Color', colors(ti,:));
    end
    xlabel('Voltage V (V)', 'FontSize', 12);
    ylabel('Power P (W)', 'FontSize', 12);
    title('P-V Characteristics', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location','southwest','FontSize',10);
    xlim([0, Voc_max * 1.08]);
    ylim([0, max(all_Pmax) * 1.15]); % Issue 2 Fix: Dynamic dynamic y-limits
    set(ax2, 'FontSize', 11);

    sgtitle('KC200GT PV Module — Temperature Sweep (G = 1000 W/m²)',...
            'FontSize', 14, 'FontWeight', 'bold');

    saveas(gcf, 'figures/iv_temperature_sweep.png');
    fprintf('Saved: figures/iv_temperature_sweep.png\n');
end
