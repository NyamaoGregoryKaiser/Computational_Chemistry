clear all;
clc;

%% Domain size
Ny = 100;
Nx = 100;
Nstp = 2001;

%% Arrays
mu = zeros(Ny, Nx);
phi = zeros(Ny, Nx);
Lap = zeros(Ny, Nx);

%% Parameters
dx = 1;
dy = 1;
dt = 0.03;

W = 1.0;
K = 0.64 * 1;
M = 1.0;

%% Initial condition: random fluctuation
phi = (rand(Ny, Nx) - 0.5) * 0.02 + 0.5;

%% Add a nucleus in the center
radius = 5;  % Radius of the nucleus
center_x = round(Nx / 2);
center_y = round(Ny / 2);

for i = 1:Ny
    for j = 1:Nx
        if (i - center_y)^2 + (j - center_x)^2 < radius^2
            phi(i, j) = 0.9;  % Higher order parameter to simulate nucleus
        end
    end
end

tm = 0.0;

%% Time evolution
for iter = 1:Nstp
    % Loop over grid points to compute Laplacian of phi
    for i = 2:Ny-1
        for j = 2:Nx-1
            Lap(i,j) = (phi(i+1,j) + phi(i-1,j) + phi(i,j+1) + phi(i,j-1) - 4*phi(i,j)) / (dx^2);
            mu(i,j) = W * (2 * phi(i,j) * (1 - phi(i,j)) * (1 - 2 * phi(i,j))) - K * Lap(i,j);
        end
    end

    % Periodic boundary condition for mu
    mu(1,:) = mu(Ny-1,:);
    mu(Ny,:) = mu(2,:);
    mu(:,1) = mu(:,Nx-1);
    mu(:,Nx) = mu(:,2);  

    % Compute Laplacian of mu
    for i = 2:Ny-1
        for j = 2:Nx-1
            Lap(i,j) = (mu(i+1,j) + mu(i-1,j) + mu(i,j+1) + mu(i,j-1) - 4 * mu(i,j)) / (dx^2);
        end
    end

    % Update phi using Euler method
    for i = 2:Ny-1
        for j = 2:Nx-1
            phi(i,j) = phi(i,j) + dt * M * Lap(i,j);
        end
    end

    % Periodic boundary condition for phi
    phi(1,:) = phi(Ny-1,:);
    phi(Ny,:) = phi(2,:);
    phi(:,1) = phi(:,Nx-1);
    phi(:,Nx) = phi(:,2);

    tm = tm + dt;

    % Save 3 snapshots
    if iter == 1 || iter == 1001 || iter == 2001
        surf(phi)
        title(['Time = ', num2str(tm)])
        pbaspect([Nx Ny Nx])
        colorbar
        axis([1 Nx 1 Ny -0.05 1.05])
        view(2)

        filename = ['snapshot_' num2str(iter) '.png'];
        saveas(gcf, filename);
    end
end
