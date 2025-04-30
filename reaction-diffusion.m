% Tumor Growth Model Simulation
% This code simulates a reaction-diffusion model for tumor growth
% with dependency on nutrient concentration

clear all; close all; clc;

%% Parameters
L = 10;                 % Domain size
N = 100;                % Number of grid points
dx = L/N;               % Grid spacing
dt = 0.01;              % Time step
tmax = 10;              % Maximum simulation time
nsteps = round(tmax/dt);% Number of time steps

% Model parameters
Mu = 0.1;               % Tumor cell mobility/diffusion coefficient
Mn = 0.5;               % Nutrient mobility/diffusion coefficient
E = 0.01;               % Surface tension coefficient
D = 0.5;               % Interaction coefficient
gamma = 0.1;            % Consumption rate
P0 = 1.0;               % Base pressure coefficient
sigma = 1.0;            % Characteristic scale
delta_P0 = 0.5;         % Pressure variation coefficient

% Chemical potential parameters
mu_u = 0.2;             % Tumor chemical potential
mu_n = 0.8;             % Nutrient chemical potential

%% Initialize grid and fields
x = linspace(0, L, N);
y = linspace(0, L, N);
[X, Y] = meshgrid(x, y);

% Initialize tumor distribution (u) - circular tumor in center
u = zeros(N, N);
center = L/2;
radius = L/10;
u = exp(-((X-center).^2 + (Y-center).^2)/(radius^2));

% Initialize nutrient distribution (n) - higher at boundaries
n = ones(N, N);
% Make nutrients lower in the center where the tumor is initially
n = n - 0.5*exp(-((X-center).^2 + (Y-center).^2)/(2*radius^2));

% Set up figure for visualization
figure('Position', [100, 100, 1000, 400]);

%% Main simulation loop
for step = 1:nsteps
    % Store previous values
    u_prev = u;
    n_prev = n;
    
    % Compute gradients and laplacians using finite differences
    [du_dx, du_dy] = gradient(u, dx);
    [dn_dx, dn_dy] = gradient(n, dx);
    laplacian_u = del2(u)/(dx^2);
    
    % Compute chemical potential terms
    df_du = 4*u.*(u-0.5).*(u-1.0);  % Derivative of free energy
    
    % Compute interaction term (simplified representation of χ_u·n)
    chi_u_n = D * u .* n;
    
    % Update tumor concentration (u)
    du_dt = Mu * del2(df_du - E*laplacian_u + D*(-chi_u_n))/(dx^2) + gamma*u;
    u = u_prev + dt * du_dt;
    
    % Update nutrient concentration (n)
    dn_dt = Mn * del2(D*(-chi_u_n) + n/sigma)/(dx^2) - gamma*u.*n;
    n = n_prev + dt * dn_dt;
    
    % Enforce boundary conditions
    u(1,:) = u(2,:); u(N,:) = u(N-1,:); 
    u(:,1) = u(:,2); u(:,N) = u(:,N-1);
    
    n(1,:) = 1; n(N,:) = 1; 
    n(:,1) = 1; n(:,N) = 1;
    
    % Ensure non-negative values
    u = max(0, min(1, u));
    n = max(0, min(1, n));
    
    % Visualization (every 50 steps)
    if mod(step, 50) == 0
        % Tumor concentration
        subplot(1, 2, 1);
        imagesc(x, y, u);
        title(['Tumor Concentration, t = ', num2str(step*dt)]);
        colorbar;
        axis square;
        
        % Nutrient concentration
        subplot(1, 2, 2);
        imagesc(x, y, n);
        title(['Nutrient Concentration, t = ', num2str(step*dt)]);
        colorbar;
        axis square;
        
        drawnow;
    end
end

%% Final visualization with more detailed plots
figure('Position', [100, 100, 800, 800]);

% Tumor concentration
subplot(2, 2, 1);
imagesc(x, y, u);
title('Final Tumor Concentration');
colorbar;
axis square;

% Nutrient concentration
subplot(2, 2, 2);
imagesc(x, y, n);
title('Final Nutrient Concentration');
colorbar;
axis square;

% 3D view of tumor
subplot(2, 2, 3);
surf(X, Y, u, 'EdgeColor', 'none');
title('3D View of Tumor');
xlabel('x'); ylabel('y'); zlabel('Concentration');
axis square;

% Cross-section plot
subplot(2, 2, 4);
mid = round(N/2);
plot(x, u(mid,:), 'r-', 'LineWidth', 2); hold on;
plot(x, n(mid,:), 'b--', 'LineWidth', 2);
title('Cross-section at y = L/2');
xlabel('x'); ylabel('Concentration');
legend('Tumor', 'Nutrient');
grid on;
axis square;

% Add a colormap that's good for visualization
colormap(jet);