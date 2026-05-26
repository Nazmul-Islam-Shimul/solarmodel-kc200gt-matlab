function plot_iv_family(p)
% Plots I-V and P-V curves for 5 irradiance levels
% Architecture: Compute all physics first, then visualize (no duplicate solver calls)

    G_levels = [200, 400, 600, 800, 1000];  % W/m²
    T        = 298.15;                       % 25°C in Kelvin — fixed for irradiance sweep
    N_pts    = 500;                          % Resolution

    colors = [0.71 0.84 0.96;
              0.52 0.72 0.92;
              0.22 0.54 0.87;
              0.09 0.37 0.64;
              0.05 0.27 0.45];

  
    % 1. COMPUTATION PHASE — solver runs only 2,500 times total

    V_all    = cell(1, length(G_levels));
    I_all    = cell(1, length(G_levels));
    P_all    = cell(1, length(G_levels));
    all_Pmax = zeros(1, length(G_levels));
    mpp_idx  = zeros(1, length(G_levels));

    for gi = 1:length(G_levels)
        G = G_levels(gi);
        V = linspace(0, p.Voc, N_pts);
        I = zeros(1, N_pts);

        for vi = 1:N_pts
            I(vi) = solve_pv_current(V(vi), p, G, T);
        end

        valid        = I >= 0;
        V_all{gi}    = V(valid);
        I_all{gi}    = I(valid);
        P_all{gi}    = V(valid) .* I(valid);

        [all_Pmax(gi), mpp_idx(gi)] = max(P_all{gi});
    end

   
    % 2. VISUALIZATION PHASE — pure plotting, no physics calls
 
    figure('Name','I-V and P-V Curves — Irradiance Sweep',...
           'Color','white','Position',[100 100 1100 480]);

    % --- Left subplot: I-V curves ---
    ax1 = subplot(1,2,1);
    hold on; grid on; box on;

    for gi = 1:length(G_levels)
        plot(V_all{gi}, I_all{gi}, 'Color', colors(gi,:), 'LineWidth', 1.8,...
             'DisplayName', sprintf('G = %d W/m²', G_levels(gi)));

        idx = mpp_idx(gi);
        plot(V_all{gi}(idx), I_all{gi}(idx), 'o', 'Color', colors(gi,:),...
             'MarkerFaceColor', colors(gi,:), 'MarkerSize', 6,...
             'HandleVisibility','off');
    end

    xlabel('Voltage V (V)', 'FontSize', 12);
    ylabel('Current I (A)', 'FontSize', 12);
    title('I-V Characteristics', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location','southwest','FontSize',10);
    xlim([0, p.Voc * 1.05]);
    ylim([0, p.Isc * 1.1]);
    set(ax1, 'FontSize', 11);

    % Right subplot: P-V curves ---
    ax2 = subplot(1,2,2);
    hold on; grid on; box on;

    for gi = 1:length(G_levels)
        plot(V_all{gi}, P_all{gi}, 'Color', colors(gi,:), 'LineWidth', 1.8,...
             'DisplayName', sprintf('G = %d W/m²', G_levels(gi)));

        idx  = mpp_idx(gi);
        Pmax = all_Pmax(gi);
        plot(V_all{gi}(idx), Pmax, 'o', 'Color', colors(gi,:),...
             'MarkerFaceColor', colors(gi,:), 'MarkerSize', 6,...
             'HandleVisibility','off');

        % Bug 3 Fix: relative offset instead of hardcoded -2
        text(V_all{gi}(idx) + 0.3, Pmax * 1.03, sprintf('%.0fW', Pmax),...
             'FontSize', 9, 'Color', colors(gi,:));
    end

    xlabel('Voltage V (V)', 'FontSize', 12);
    ylabel('Power P (W)', 'FontSize', 12);
    title('P-V Characteristics', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location','northwest','FontSize',10);
    xlim([0, p.Voc * 1.05]);
    ylim([0, max(all_Pmax) * 1.15]);  % Bug 4 Fix: dynamic ylim, was missing entirely
    set(ax2, 'FontSize', 11);

    sgtitle('KC200GT PV Module — Single-Diode Model (T = 25°C)',...
            'FontSize', 14, 'FontWeight', 'bold');

    saveas(gcf, 'figures/iv_irradiance_sweep.png');
    fprintf('Saved: figures/iv_irradiance_sweep.png\n');
end
