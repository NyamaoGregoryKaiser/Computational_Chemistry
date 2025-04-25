clear all
clc;

%% materials parameters
alp = 1;
bet = 1;
gam = 1;
kap = 2;
L = 1;

%% numerical parameters
Nx = 200;
Ny = 200; 
dx = 2.0;
dt = 0.04;

%% arrays
noG = 20;  %% 20 grains

% Initialize arrays
eta = rand(Ny,Nx,noG)*0.001; % Small random initial values simulating liquid state
muE = zeros(Ny,Nx,noG);
LpE = zeros(Ny,Nx,noG);
SoE2 = zeros(Ny,Nx);
val = zeros(Ny,Nx);

% Arrays to store time and average radius data
time_steps = [];
avg_radius = [];

%% Initial stages - run until timestep 1500
fprintf('Running initial stages up to time step 1500...\n');
for iter = 1:1500
    %% calculating chemical potential 
    SoE2(1:Ny,1:Nx) = sum(eta(1:Ny,1:Nx,1:noG).^2, 3);
    
    for p = 1:noG
        % Bulk free energy terms: alpha*eta*(eta^2-beta)
        muE(1:Ny,1:Nx,p) = alp*eta(1:Ny,1:Nx,p).*(eta(1:Ny,1:Nx,p).^2 - bet);
        
        % Cross terms: gamma*eta*sum(eta_j^2) for j≠i
        cross_term = SoE2(1:Ny,1:Nx) - eta(1:Ny,1:Nx,p).^2;
        muE(1:Ny,1:Nx,p) = muE(1:Ny,1:Nx,p) + gam*eta(1:Ny,1:Nx,p).*cross_term;
    end
    
    %% calculating Laplacian
    for p = 1:noG
        % 5-point stencil for Laplacian
        LpE(2:Ny-1,2:Nx-1,p) = (eta(3:Ny,2:Nx-1,p) + eta(1:Ny-2,2:Nx-1,p) + ...
                               eta(2:Ny-1,3:Nx,p) + eta(2:Ny-1,1:Nx-2,p) - ...
                               4*eta(2:Ny-1,2:Nx-1,p))/(dx^2);
    end
        
    %% total chemical potential of each grain
    muE(2:Ny-1,2:Nx-1,1:noG) = muE(2:Ny-1,2:Nx-1,1:noG) - kap*LpE(2:Ny-1,2:Nx-1,1:noG);
    
    %% update order parameters for grains
    eta(2:Ny-1,2:Nx-1,1:noG) = eta(2:Ny-1,2:Nx-1,1:noG) - dt*L*muE(2:Ny-1,2:Nx-1,1:noG);
    
    %% boundary conditions (periodic)
    eta(1,2:Nx-1,1:noG) = eta(Ny-1,2:Nx-1,1:noG);
    eta(Ny,2:Nx-1,1:noG) = eta(2,2:Nx-1,1:noG);
    eta(1:Ny,1,1:noG) = eta(1:Ny,Nx-1,1:noG);
    eta(1:Ny,Nx,1:noG) = eta(1:Ny,2,1:noG);
    
    % Display progress
    if mod(iter,500) == 0
        fprintf('Completed time step %d\n', iter);
    end
end

fprintf('Starting main simulation and tracking from time step 1501 to 6001...\n');

%% Main simulation - timesteps 1501 to 6001
for iter = 1501:6001
    %% calculating chemical potential 
    SoE2(1:Ny,1:Nx) = sum(eta(1:Ny,1:Nx,1:noG).^2, 3);
    
    for p = 1:noG
        % Bulk free energy terms: alpha*eta*(eta^2-beta)
        muE(1:Ny,1:Nx,p) = alp*eta(1:Ny,1:Nx,p).*(eta(1:Ny,1:Nx,p).^2 - bet);
        
        % Cross terms: gamma*eta*sum(eta_j^2) for j≠i
        cross_term = SoE2(1:Ny,1:Nx) - eta(1:Ny,1:Nx,p).^2;
        muE(1:Ny,1:Nx,p) = muE(1:Ny,1:Nx,p) + gam*eta(1:Ny,1:Nx,p).*cross_term;
    end
    
    %% calculating Laplacian
    for p = 1:noG
        % 5-point stencil for Laplacian
        LpE(2:Ny-1,2:Nx-1,p) = (eta(3:Ny,2:Nx-1,p) + eta(1:Ny-2,2:Nx-1,p) + ...
                               eta(2:Ny-1,3:Nx,p) + eta(2:Ny-1,1:Nx-2,p) - ...
                               4*eta(2:Ny-1,2:Nx-1,p))/(dx^2);
    end
        
    %% total chemical potential of each grain
    muE(2:Ny-1,2:Nx-1,1:noG) = muE(2:Ny-1,2:Nx-1,1:noG) - kap*LpE(2:Ny-1,2:Nx-1,1:noG);
    
    %% update order parameters for grains
    eta(2:Ny-1,2:Nx-1,1:noG) = eta(2:Ny-1,2:Nx-1,1:noG) - dt*L*muE(2:Ny-1,2:Nx-1,1:noG);
    
    %% boundary conditions (periodic)
    eta(1,2:Nx-1,1:noG) = eta(Ny-1,2:Nx-1,1:noG);
    eta(Ny,2:Nx-1,1:noG) = eta(2,2:Nx-1,1:noG);
    eta(1:Ny,1,1:noG) = eta(1:Ny,Nx-1,1:noG);
    eta(1:Ny,Nx,1:noG) = eta(1:Ny,2,1:noG);
    
    %% Calculate grain areas and radii at each tracking step
    if mod(iter,100) == 0 || iter == 1501 || iter == 6001
        % Calculate total function phi to identify grains
        val(1:Ny,1:Nx) = sum(eta(1:Ny,1:Nx,1:noG).^2, 3);
        
        % Create a binary image to identify grains
        threshold = 0.5;
        binary_image = val > threshold;
        
        % Label connected regions (grains)
        CC = bwconncomp(binary_image);
        stats = regionprops(CC, 'Area');
        
        % Calculate grain radii assuming circular grains: A = πr²
        grain_areas = [stats.Area];
        grain_radii = sqrt(grain_areas / pi);
        
        % Calculate average radius
        avg_r = mean(grain_radii);
        
        % Store time step and average radius
        time_steps = [time_steps; iter];
        avg_radius = [avg_radius; avg_r];
        
        fprintf('Time step %d: Average radius = %.4f\n', iter, avg_r);
        
        % Optional visualization at selected time steps
        if mod(iter,1000) == 0 || iter == 1501 || iter == 6001
            figure(1)
            surf(val)
            shading interp
            view(2)
            pbaspect([Nx,Ny,Ny])
            colorbar
            title(['Time step: ', num2str(iter), ', Avg Radius: ', num2str(avg_r)])
            drawnow
        end
    end
end

%% Plot the evolution of average grain radius
figure(2)
plot(time_steps, avg_radius, 'b-o', 'LineWidth', 2)
hold on
grid on
xlabel('Time Step')
ylabel('Average Grain Radius')
title('Evolution of Average Grain Radius (Time Steps 1501-6001)')

% Fit the data to parabolic growth law: R² = kt + C
% This is based on the research paper which found m ≈ 2
x = time_steps;
y = avg_radius.^2;
p = polyfit(x, y, 1);
k = p(1);
C = p(2);
fit_radius = sqrt(k*time_steps + C);

% Plot the fitted curve
plot(time_steps, fit_radius, 'r--', 'LineWidth', 1.5)
legend('Simulation Data', ['Fitted Curve: R² = ' num2str(k) '*t + ' num2str(C)])

% Display the fitted growth law
fprintf('\nFitted growth law: R² = %.4e*t + %.4f\n', k, C);