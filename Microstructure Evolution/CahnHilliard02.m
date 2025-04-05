clear all;

clc;


%% domain size
Ny = 100;
Nx = 100;

Nstp = 2001;

%% arrays
mu = zeros(Ny, Nx);
phi = zeros(Ny, Nx);
Lap = zeros(Ny, Nx);

%% parameters
dx = 1;
dy = 1;
dt = 0.03;

W = 1.0;
K = 0.64*1;
M = 1.0;

% Modified initial conditions for metastable region
% Setting average concentration to 0.25 with small random fluctuations
phi = (rand(Ny,Nx)-0.5)*0.05 + 0.25;

% Add a few nucleation seeds to trigger phase separation
% Create a few small circular regions with higher concentration
for i = 1:3
    center_x = 25 + 25*(i-1);
    center_y = 50;
    radius = 5;
    
    for y = 1:Ny
        for x = 1:Nx
            if ((x-center_x)^2 + (y-center_y)^2 <= radius^2)
                phi(y,x) = 0.9; % High concentration seed
            end
        end
    end
end

tm = 0.0;

%% time evolution
for iter = 1:2001
    
    % loop over grid points
    for i = 2:Ny-1
        for j = 2:Nx-1
            
            % Laplace of order parameter
            Lap(i,j) = (phi(i+1,j) + phi(i-1,j) + phi(i,j+1) + phi(i,j-1) - 4*phi(i,j))/(dx^2);
            
            % chemical potential       
            mu(i,j) = W*(2*phi(i,j)*(1-phi(i,j))*(1-2*phi(i,j))) - K*Lap(i,j);
                  
        end
    end

    % periodic boundary condition
    mu(1,:) = mu(Ny-1,:);
    mu(Ny,:) = mu(2,:);
    
    mu(:,1) = mu(:,Nx-1);
    mu(:,Nx) = mu(:,2);  


    % loop over grid points
    for i = 2:Ny-1
        for j = 2:Nx-1
            
            % Laplace of chemical potential
            Lap(i,j) = (mu(i+1,j) + mu(i-1,j) + mu(i,j+1) + mu(i,j-1) - 4*mu(i,j))/(dx^2);
                  
        end
    end

    % update the order parameter using Euler method
    for i = 2:Ny-1
        for j = 2:Nx-1
            
            phi(i,j) = phi(i,j) + dt*M*Lap(i,j);
            
        end
    end
    
    % periodic boundary condition
    phi(1,:) = phi(Ny-1,:);
    phi(Ny,:) = phi(2,:);
    
    phi(:,1) = phi(:,Nx-1);
    phi(:,Nx) = phi(:,2);
    
    tm = tm + dt;
    
    % Save snapshots at specific times
    if iter == 100 || iter == 500 || iter == 2000
        figure
        surf(phi)
        title(['Time = ' num2str(tm)])
        pbaspect([Nx Ny Nx])
        colorbar
        axis([1 Nx 1 Ny -0.05 1.05])
        view(2)
        drawnow
        % Uncomment the next line to save figures automatically
        % saveas(gcf, ['metastable_phi_0.25_time_' num2str(tm) '.png'])
    end
    
    % visualization during running
    if mod(iter,10) == 1
        surf(phi)
        title(['Time = ' num2str(tm)])
        pbaspect([Nx Ny Nx])
        colorbar
        axis([1 Nx 1 Ny -0.05 1.05])
        view(2)
        pause(0.1)
    end
end