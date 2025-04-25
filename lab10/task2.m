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
noG = 20;  %% <== 20 grains

eta = rand(Ny,Nx,noG)*0.001; % Small random initial values simulating liquid state
muE = zeros(Ny,Nx,noG);
LpE = zeros(Ny,Nx,noG);
SoE2 = zeros(Ny,Nx);
val = zeros(Ny,Nx);

%% time evolution
for iter = 1:3001
    
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
    
    %% visualization of progress
    if mod(iter,500) == 1
        fprintf('Processing time step %d...\n', iter);
    end
end

%% Identify and analyze grains at time step 3001
val = sum(eta.^2, 3); % Sum of squared order parameters
% Create a threshold to identify grains (regions where val is high)
threshold = 0.5; % This threshold may need adjustment based on your specific simulation
binary_image = val > threshold;

% Label connected regions (grains)
CC = bwconncomp(binary_image);
stats = regionprops(CC, 'Area', 'Centroid');

% Calculate grain radii assuming circular grains: A = πr²
grain_areas = [stats.Area];
grain_radii = sqrt(grain_areas / pi);

% Display the microstructure with labeled grains
figure(1);
imshow(binary_image);
title('Identified Grains at Time Step 3001');
hold on;

% Mark the centroids of identified grains
centroids = cat(1, stats.Centroid);
plot(centroids(:,1), centroids(:,2), 'r*');
hold off;

% Create histogram of grain radii with 30 bins
figure(2);
histogram(grain_radii, 30, 'FaceColor', [0.3 0.6 0.9], 'EdgeColor', 'k');
xlabel('Grain Radius (grid units)');
ylabel('Frequency');
title('Grain Size Distribution at Time Step 3001');
grid on;

% Calculate and display statistics
mean_radius = mean(grain_radii);
median_radius = median(grain_radii);
std_radius = std(grain_radii);

fprintf('Number of grains identified: %d\n', length(grain_radii));
fprintf('Mean grain radius: %.2f\n', mean_radius);
fprintf('Median grain radius: %.2f\n', median_radius);
fprintf('Standard deviation of grain radii: %.2f\n', std_radius);

% Create a normalized histogram (probability density)
figure(3);
h = histogram(grain_radii, 30, 'Normalization', 'probability', 'FaceColor', [0.3 0.6 0.9], 'EdgeColor', 'k');
xlabel('Grain Radius (grid units)');
ylabel('Probability');
title('Normalized Grain Size Distribution at Time Step 3001');
grid on;

% Save the histogram figure
saveas(figure(2), 'grain_size_distribution_3001.png');