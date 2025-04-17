clear all
clc;

%% 2D square domain
Ly = 9.0;
Lx = 9.0;

%% discretization in the y and x directions
py = 300;
px = 300;

%% grid spacing and time step size
dx = Lx/px;
dy = Ly/py;
dt = 0.0001;
Nstp = 5001;

%% parameters
epsB = 0.010;
Mob = 1.0/0.0003;
K = 1.6;
alph = 0.9;
gamma = 10.0;
Tm = 1.0;

%% 2D arrays
phi = zeros(py, px);
phi_old = zeros(py, px);
mu = zeros(py, px);
LapP = zeros(py, px);
E = zeros(py, px);
T = zeros(py, px);
LapT = zeros(py, px);

%% initial condition
for i = 1:py
    for j = 1:px
        rad = sqrt((i-150)^2 + (j-150)^2);
        if rad < 5
            phi(i,j) = 1;
        elseif rad < 10
            phi(i,j) = rand(1);
        end
        % Initialize temperature field (supercooled)
        T(i,j) = 0.0;
    end
end

tm = 0.0;

%% time iteration
for iter = 1:Nstp
    % Store previous phi for latent heat calculation
    phi_old = phi;
    
    %% order parameter field
    %% calculate latent heat term
    E(2:py-1, 2:px-1) = (alph/pi) * phi(2:py-1, 2:px-1) .* (1 - phi(2:py-1, 2:px-1)) .* atan(gamma * (Tm - T(2:py-1, 2:px-1)));
    
    %% chemical potential
    mu(2:py-1, 2:px-1) = 0.5 * phi(2:py-1, 2:px-1) .* (1 - phi(2:py-1, 2:px-1)) .* (1 - 2*phi(2:py-1, 2:px-1));
    
    %% Laplace of phi
    LapP(2:py-1, 2:px-1) = (phi(1:py-2,2:px-1) - 2*phi(2:py-1, 2:px-1) + phi(3:py,2:px-1))/dx^2 + ...
                           (phi(2:py-1,1:px-2) - 2*phi(2:py-1, 2:px-1) + phi(2:py-1,3:px))/dy^2;
    
    %% total chemical potential
    mu(2:py-1, 2:px-1) = mu(2:py-1, 2:px-1) + E(2:py-1, 2:px-1) - epsB^2*LapP(2:py-1, 2:px-1);    
    
    %% temperature field
    %% Laplace of temperature
    LapT(2:py-1, 2:px-1) = (T(1:py-2, 2:px-1) - 2*T(2:py-1, 2:px-1) + T(3:py, 2:px-1))/dx^2 + ...
                           (T(2:py-1, 1:px-2) - 2*T(2:py-1, 2:px-1) + T(2:py-1, 3:px))/dy^2;
                       
    %% update order parameter                 
    phi(2:py-1, 2:px-1) = phi(2:py-1, 2:px-1) + dt * Mob * mu(2:py-1, 2:px-1);
    
    %% update temperature - including latent heat release
    T(2:py-1, 2:px-1) = T(2:py-1, 2:px-1) + dt * (LapT(2:py-1, 2:px-1) + K * (phi(2:py-1, 2:px-1) - phi_old(2:py-1, 2:px-1))/dt);
    
    %% boundary conditions; no-flux
    phi(1,:) = phi(2,:);
    phi(py,:) = phi(py-1,:);
    phi(:,1) = phi(:,2);
    phi(:,px) = phi(:,px-1);
    
    T(1,:) = T(2,:);
    T(py,:) = T(py-1,:);
    T(:,1) = T(:,2);
    T(:,px) = T(:,px-1);
    
    %% time
    tm = tm + dt;
    
    %% visualization
    if mod(iter,20) == 1
        
        figure(1)
        surf(phi)
        view(2)
        title(['Time = ' num2str(tm)])
        pbaspect([px py px])
        colormap(parula)
        colorbar
        drawnow
        
        figure(2)
        surf(T)
        view(2)
        title(['Temperature at t = ' num2str(tm)])
        pbaspect([px py px])
        colormap(hot)
        colorbar
        drawnow
    end
    
end

% Display final configuration
figure(3)
surf(phi)
view(2)
title(['Final Configuration at t = ' num2str(tm)])
pbaspect([px py px])
colormap(parula)
colorbar