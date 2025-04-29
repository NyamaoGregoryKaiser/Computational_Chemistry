%% Adaptive Time Stepping for Tumor Growth Model
% This script implements a finite difference method with adaptive time stepping
% to solve a system of PDEs modeling tumor growth

clear all; close all; clc;

%% Parameters
% Domain parameters
Lx = 5;                  % Domain length in x-direction
Ly = 5;                  % Domain length in y-direction
Nx = 100;                % Number of grid points in x
Ny = 100;                % Number of grid points in y
dx = Lx/Nx;              % Grid spacing in x
dy = Ly/Ny;              % Grid spacing in y
x = linspace(0, Lx, Nx); % x-coordinates
y = linspace(0, Ly, Ny); % y-coordinates
[X, Y] = meshgrid(x, y); % Grid

% Model parameters
M_u = 1.0;               % Mobility coefficient for u
M_n = 1.0;               % Mobility coefficient for n
E = 0.01;                % Surface tension coefficient
D = 0.5;                 % Diffusion coefficient
gamma = 0.1;             % Reaction/source term coefficient
chi_u = 0.5;             % Chemotaxis coefficient
sigma = 1.0;             % Parameter in chemical potential
P0 = 1.0;                % Base proliferation rate
dP0 = 0.2;               % Proliferation rate modifier
mu_n = 1.0;              % Chemical potential parameter for n
mu_u = 0.5;              % Chemical potential parameter for u

% Simulation parameters
t_final = 10.0;          % Final time
dt_init = 1e-4;          % Initial time step
dt_min = 1e-6;           % Minimum allowed time step
dt_max = 1e-2;           % Maximum allowed time step
tol = 1e-3;              % Tolerance for adaptive stepping
safety_factor = 0.8;     % Safety factor for time step adjustment
plot_interval = 20;      % Plot every n steps

%% Initial conditions
% Initialize u with a Gaussian pulse at the center
u = zeros(Ny, Nx);
n = ones(Ny, Nx);        % Initial nutrient distribution (uniform)

% Create a tumor seed in the center
center_x = Lx/2;
center_y = Ly/2;
radius = min(Lx, Ly)/10;
for i = 1:Ny
    for j = 1:Nx
        dist = sqrt((x(j) - center_x)^2 + (y(i) - center_y)^2);
        u(i,j) = exp(-dist^2/(radius^2));
    end
end

% Setup for free energy functional
f = @(u) 0.25*u.^2.*(1-u).^2;  % Double-well potential
df_du = @(u) 0.5*u.*(1-u).*(1-2*u);  % Derivative of the free energy w.r.t. u

%% Setup arrays for storing results
t = 0;
step = 0;
dt = dt_init;

% Create figures for visualization
figure(1); clf;
h_u = subplot(1,2,1);
h_n = subplot(1,2,2);
colormap(jet);

% For recording the evolution of dt
dt_history = [];
t_history = [];

%% Main time loop
while t < t_final
    % Store previous solution for error estimation
    u_old = u;
    n_old = n;
    
    % Calculate spatial derivatives using finite differences
    % Implement periodic boundary conditions
    
    % Laplacian of u - ∇²u
    laplacian_u = zeros(size(u));
    for i = 1:Ny
        im1 = mod(i-2,Ny) + 1; % i-1 with periodic boundary
        ip1 = mod(i,Ny) + 1;   % i+1 with periodic boundary
        
        for j = 1:Nx
            jm1 = mod(j-2,Nx) + 1; % j-1 with periodic boundary
            jp1 = mod(j,Nx) + 1;   % j+1 with periodic boundary
            
            % 5-point stencil for Laplacian
            laplacian_u(i,j) = (u(im1,j) + u(ip1,j) + u(i,jm1) + u(i,jp1) - 4*u(i,j))/(dx^2);
        end
    end
    
    % Compute df/du
    dfdu = df_du(u);
    
    % Compute chemical potential term for u
    mu = dfdu - E * laplacian_u - D * (-chi_u * n);
    
    % Compute ∇(M_u * ∇(df/du - E∇²u + D·(-χ_u·n)))
    flux_u = zeros(size(u));
    for i = 1:Ny
        im1 = mod(i-2,Ny) + 1;
        ip1 = mod(i,Ny) + 1;
        
        for j = 1:Nx
            jm1 = mod(j-2,Nx) + 1;
            jp1 = mod(j,Nx) + 1;
            
            % Calculate gradient of mu using central differences
            dmu_dx = (mu(i,jp1) - mu(i,jm1))/(2*dx);
            dmu_dy = (mu(ip1,j) - mu(im1,j))/(2*dy);
            
            % Calculate divergence of M_u * gradient of mu
            flux_x_right = M_u * (mu(i,jp1) - mu(i,j))/dx;
            flux_x_left = M_u * (mu(i,j) - mu(i,jm1))/dx;
            flux_y_down = M_u * (mu(ip1,j) - mu(i,j))/dy;
            flux_y_up = M_u * (mu(i,j) - mu(im1,j))/dy;
            
            flux_u(i,j) = (flux_x_right - flux_x_left)/dx + (flux_y_down - flux_y_up)/dy;
        end
    end
    
    % Similar computations for n
    % Calculate D*(-chi_u * n) + n/sigma term
    n_term = D*(-chi_u * n) + n/sigma;
    
    flux_n = zeros(size(n));
    for i = 1:Ny
        im1 = mod(i-2,Ny) + 1;
        ip1 = mod(i,Ny) + 1;
        
        for j = 1:Nx
            jm1 = mod(j-2,Nx) + 1;
            jp1 = mod(j,Nx) + 1;
            
            % Calculate gradient of n_term using central differences
            dn_term_dx = (n_term(i,jp1) - n_term(i,jm1))/(2*dx);
            dn_term_dy = (n_term(ip1,j) - n_term(im1,j))/(2*dy);
            
            % Calculate divergence of M_n * gradient of n_term
            flux_x_right = M_n * (n_term(i,jp1) - n_term(i,j))/dx;
            flux_x_left = M_n * (n_term(i,j) - n_term(i,jm1))/dx;
            flux_y_down = M_n * (n_term(ip1,j) - n_term(i,j))/dy;
            flux_y_up = M_n * (n_term(i,j) - n_term(im1,j))/dy;
            
            flux_n(i,j) = (flux_x_right - flux_x_left)/dx + (flux_y_down - flux_y_up)/dy;
        end
    end
    
    % Calculate delta_u (growth term)
    delta_u = P0 * u .* sigma .* (mu_n - mu_u);
    
    % Update equations using forward Euler method
    u_new = u + dt * (flux_u + gamma * u + delta_u);
    n_new = n + dt * (flux_n - gamma * u);
    
    % Ensure physical bounds
    u_new = max(0, min(1, u_new));  % Ensure u is between 0 and 1
    n_new = max(0, n_new);          % Ensure n is non-negative
    
    % Error estimation for adaptive time stepping
    error_u = norm(u_new - u_old, 'fro') / norm(u_old + eps, 'fro');
    error_n = norm(n_new - n_old, 'fro') / norm(n_old + eps, 'fro');
    error = max(error_u, error_n);
    
    % Adjust time step based on error
    if error > tol
        % Reduce time step
        dt_new = max(safety_factor * dt * sqrt(tol/error), dt_min);
        
        if dt_new < dt
            % If we need to reduce the time step, reject this step and try again
            dt = dt_new;
            fprintf('Step rejected, reducing dt to %e at t = %f\n', dt, t);
            continue;
        end
    else
        % Accept step and update solution
        u = u_new;
        n = n_new;
        t = t + dt;
        step = step + 1;
        
        % Record dt and t
        dt_history = [dt_history, dt];
        t_history = [t_history, t];
        
        % Possibly increase time step for next iteration
        dt_new = min(safety_factor * dt * sqrt(tol/error), dt_max);
        dt = dt_new;
        
        % Visualization
        if mod(step, plot_interval) == 0
            fprintf('Step %d: t = %f, dt = %e\n', step, t, dt);
            
            % Plot u
            subplot(h_u);
            imagesc(x, y, u);
            title(sprintf('Tumor Density (u) at t = %.3f', t));
            axis equal tight;
            colorbar;
            
            % Plot n
            subplot(h_n);
            imagesc(x, y, n);
            title(sprintf('Nutrient Concentration (n) at t = %.3f', t));
            axis equal tight;
            colorbar;
            
            drawnow;
        end
    end
    
    % Check if we're close to the final time
    if t + dt > t_final
        dt = t_final - t;
    end
end

%% Final visualization
figure(2);
subplot(2,2,1);
imagesc(x, y, u);
title('Final Tumor Density (u)');
axis equal tight;
colorbar;

subplot(2,2,2);
imagesc(x, y, n);
title('Final Nutrient Concentration (n)');
axis equal tight;
colorbar;

subplot(2,2,3);
plot(t_history, dt_history);
title('Time Step Evolution');
xlabel('Time');
ylabel('dt');
set(gca, 'YScale', 'log');

% For a 3D visualization of tumor
subplot(2,2,4);
surf(X, Y, u, 'EdgeColor', 'none');
title('3D Visualization of Tumor');
xlabel('x');
ylabel('y');
zlabel('Density');
colormap(jet);