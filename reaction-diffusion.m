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
M_tumor = 1.0;           % Mobility coefficient for tumor cells
M_nutrient = 1.0;        % Mobility coefficient for nutrient
E = 0.01;                % Surface tension coefficient
D_nutrient = 0.5;        % Nutrient diffusion coefficient
consume_rate = 0.1;      % Rate at which tumor cells consume nutrients
chi = 0.5;               % Chemotaxis coefficient (tumor attraction to nutrient)
sigma = 1.0;             % Parameter in chemical potential
P_base = 1.0;            % Base proliferation rate
P_mod = 0.2;             % Proliferation rate modifier
mu_nutrient = 1.0;       % Chemical potential parameter for nutrient
mu_tumor = 0.5;          % Chemical potential parameter for tumor

% Simulation parameters
t_final = 10.0;          % Final time
dt_init = 1e-4;          % Initial time step
dt_min = 1e-6;           % Minimum allowed time step
dt_max = 1e-2;           % Maximum allowed time step
tol = 1e-3;              % Tolerance for adaptive stepping
safety_factor = 0.8;     % Safety factor for time step adjustment
plot_interval = 20;      % Plot every n steps

%% Initial conditions
% Initialize tumor with a Gaussian pulse at the center
tumor_density = zeros(Ny, Nx);
nutrient_conc = ones(Ny, Nx);   % Initial nutrient distribution (uniform)

% Create a tumor seed in the center
center_x = Lx/2;
center_y = Ly/2;
radius = min(Lx, Ly)/10;
for i = 1:Ny
    for j = 1:Nx
        dist = sqrt((x(j) - center_x)^2 + (y(i) - center_y)^2);
        tumor_density(i,j) = exp(-dist^2/(radius^2));
    end
end

% Setup for free energy functional
f = @(u) 0.25*u.^2.*(1-u).^2;  % Double-well potential
df_du = @(u) 0.5*u.*(1-u).*(1-2*u);  % Derivative of the free energy w.r.t. tumor density

%% Setup arrays for storing results
t = 0;
step = 0;
dt = dt_init;

% Create figures for visualization
figure(1); clf;
h_tumor = subplot(1,2,1);
h_nutrient = subplot(1,2,2);
colormap(jet);

% For recording the evolution of dt
dt_history = [];
t_history = [];

%% Main time loop
while t < t_final
    % Store previous solution for error estimation
    tumor_old = tumor_density;
    nutrient_old = nutrient_conc;
    
    % Calculate spatial derivatives using finite differences
    % Implement periodic boundary conditions
    
    % Laplacian of tumor_density - ∇²tumor_density
    laplacian_tumor = zeros(size(tumor_density));
    for i = 1:Ny
        im1 = mod(i-2,Ny) + 1; % i-1 with periodic boundary
        ip1 = mod(i,Ny) + 1;   % i+1 with periodic boundary
        
        for j = 1:Nx
            jm1 = mod(j-2,Nx) + 1; % j-1 with periodic boundary
            jp1 = mod(j,Nx) + 1;   % j+1 with periodic boundary
            
            % 5-point stencil for Laplacian
            laplacian_tumor(i,j) = (tumor_density(im1,j) + tumor_density(ip1,j) + ...
                               tumor_density(i,jm1) + tumor_density(i,jp1) - ...
                               4*tumor_density(i,j))/(dx^2);
        end
    end
    
    % Compute df/du - derivative of free energy with respect to tumor density
    dfdu = df_du(tumor_density);
    
    % Compute chemical potential term for tumor
    chem_pot_tumor = dfdu - E * laplacian_tumor - D_nutrient * (-chi * nutrient_conc);
    
    % Compute ∇(M_tumor * ∇(df/du - E∇²tumor + D·(-χ·nutrient)))
    flux_tumor = zeros(size(tumor_density));
    for i = 1:Ny
        im1 = mod(i-2,Ny) + 1;
        ip1 = mod(i,Ny) + 1;
        
        for j = 1:Nx
            jm1 = mod(j-2,Nx) + 1;
            jp1 = mod(j,Nx) + 1;
            
            % Calculate gradient of chemical potential using central differences
            dmu_dx = (chem_pot_tumor(i,jp1) - chem_pot_tumor(i,jm1))/(2*dx);
            dmu_dy = (chem_pot_tumor(ip1,j) - chem_pot_tumor(im1,j))/(2*dy);
            
            % Calculate divergence of M_tumor * gradient of chemical potential
            flux_x_right = M_tumor * (chem_pot_tumor(i,jp1) - chem_pot_tumor(i,j))/dx;
            flux_x_left = M_tumor * (chem_pot_tumor(i,j) - chem_pot_tumor(i,jm1))/dx;
            flux_y_down = M_tumor * (chem_pot_tumor(ip1,j) - chem_pot_tumor(i,j))/dy;
            flux_y_up = M_tumor * (chem_pot_tumor(i,j) - chem_pot_tumor(im1,j))/dy;
            
            flux_tumor(i,j) = (flux_x_right - flux_x_left)/dx + (flux_y_down - flux_y_up)/dy;
        end
    end
    
    % Similar computations for nutrient
    % Calculate D_nutrient*(-chi * nutrient) + nutrient/sigma term
    nutrient_term = D_nutrient*(-chi * nutrient_conc) + nutrient_conc/sigma;
    
    flux_nutrient = zeros(size(nutrient_conc));
    for i = 1:Ny
        im1 = mod(i-2,Ny) + 1;
        ip1 = mod(i,Ny) + 1;
        
        for j = 1:Nx
            jm1 = mod(j-2,Nx) + 1;
            jp1 = mod(j,Nx) + 1;
            
            % Calculate gradient of nutrient_term using central differences
            dn_term_dx = (nutrient_term(i,jp1) - nutrient_term(i,jm1))/(2*dx);
            dn_term_dy = (nutrient_term(ip1,j) - nutrient_term(im1,j))/(2*dy);
            
            % Calculate divergence of M_nutrient * gradient of nutrient_term
            flux_x_right = M_nutrient * (nutrient_term(i,jp1) - nutrient_term(i,j))/dx;
            flux_x_left = M_nutrient * (nutrient_term(i,j) - nutrient_term(i,jm1))/dx;
            flux_y_down = M_nutrient * (nutrient_term(ip1,j) - nutrient_term(i,j))/dy;
            flux_y_up = M_nutrient * (nutrient_term(i,j) - nutrient_term(im1,j))/dy;
            
            flux_nutrient(i,j) = (flux_x_right - flux_x_left)/dx + (flux_y_down - flux_y_up)/dy;
        end
    end
    
    % Calculate growth term (proliferation rate)
    proliferation = P_base * tumor_density .* sigma .* (mu_nutrient - mu_tumor);
    
    % Update equations using forward Euler method
    tumor_new = tumor_density + dt * (flux_tumor + consume_rate * tumor_density + proliferation);
    nutrient_new = nutrient_conc + dt * (flux_nutrient - consume_rate * tumor_density);
    
    % Ensure physical bounds
    tumor_new = max(0, min(1, tumor_new));  % Ensure tumor density is between 0 and 1
    nutrient_new = max(0, nutrient_new);    % Ensure nutrient concentration is non-negative
    
    % Error estimation for adaptive time stepping
    error_tumor = norm(tumor_new - tumor_old, 'fro') / norm(tumor_old + eps, 'fro');
    error_nutrient = norm(nutrient_new - nutrient_old, 'fro') / norm(nutrient_old + eps, 'fro');
    error = max(error_tumor, error_nutrient);
    
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
        tumor_density = tumor_new;
        nutrient_conc = nutrient_new;
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
            
            % Plot tumor density
            subplot(h_tumor);
            imagesc(x, y, tumor_density);
            title(sprintf('Tumor Density at t = %.3f', t));
            axis equal tight;
            colorbar;
            
            % Plot nutrient concentration
            subplot(h_nutrient);
            imagesc(x, y, nutrient_conc);
            title(sprintf('Nutrient Concentration at t = %.3f', t));
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
imagesc(x, y, tumor_density);
title('Final Tumor Density');
axis equal tight;
colorbar;

subplot(2,2,2);
imagesc(x, y, nutrient_conc);
title('Final Nutrient Concentration');
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
surf(X, Y, tumor_density, 'EdgeColor', 'none');
title('3D Visualization of Tumor');
xlabel('x');
ylabel('y');
zlabel('Density');
colormap(jet);