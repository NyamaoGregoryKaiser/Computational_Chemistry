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

% initial conditions
phi = (rand(Ny,Nx)-0.5)*0.02 + 0.5;
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
    
    % visualization
    if mod(iter,10) == 1
        surf(phi)
        title([num2str(tm)])
        pbaspect([Nx Ny Nx])
        colorbar
        axis([1 Nx 1 Ny -0.05 1.05])
        
        view(2)
        
        pause(0.1)
    end
   
end