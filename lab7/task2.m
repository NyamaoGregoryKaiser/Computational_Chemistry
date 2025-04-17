clear all
clc;

%% 2D rectangular domain (modified as suggested)
Ly = 9.0;
Lx = 3.0;  % Changed as suggested for directional solidification

%% discretization in the y and x directions
py = 300;
px = 100;  % Adjusted to maintain aspect ratio

%% grid spacing and time step size
dx = Lx/px;
dy = Ly/py;
dt = 0.0001;
Nstp = 5001;

%% parameters
epsB = 0.010;
Mob = 1.0/0.0003;
K = 0.8;    % K value for Fig 5(1)
alph = 0.9;
gamma = 10.0;
Tm = 1.0;

%% anisotropy parameters for Fig 7
delta = 0.0;   % No anisotropy for Fig 5(1), set to non-zero for Fig 7
j = 4;         % 4-mode anisotropy
theta0 = 0;    % Preferred directions align with x and y axes

%% 2D arrays
phi = zeros(py, px);
phi_old = zeros(py, px);
mu = zeros(py, px);
LapP = zeros(py, px);
E = zeros(py, px);
T = zeros(py, px);
LapT = zeros(py, px);
epsilon = zeros(py, px);  % For anisotropy
epsilon_dtheta = zeros(py, px);  % Derivative of epsilon w.r.t theta

%% initial condition - solid on the left side of domain
for i = 1:py
    for j = 1:px
        % Initialize supercooled temperature field
        T(i,j) = 0.0;
        
        % Initialize solid on left side with slight perturbation
        if j <= 5
            phi(i,j) = 1.0;
        elseif j <= 10
            % Add some random perturbation at the interface
            if mod(i, 15) == 0  % Adding periodic perturbation
                phi(i,j) = 0.5 + 0.5*rand();
            end
        end
    end
end

tm = 0.0;

%% time iteration
for iter = 1:Nstp
    % Store previous phi for latent heat calculation
    phi_old = phi;
    
    %% Calculate anisotropy for each point
    for i = 2:py-1
        for j = 2:px-1
            % Calculate gradient components
            px_grad = (phi(i,j+1) - phi(i,j-1))/(2*dx);
            py_grad = (phi(i+1,j) - phi(i-1,j))/(2*dy);
            grad_norm = sqrt(px_grad^2 + py_grad^2);
            
            % Calculate angle theta (avoid division by zero)
            if grad_norm > 1e-10
                theta = atan2(-py_grad, -px_grad);
                epsilon(i,j) = 1 + delta * cos(j*(theta - theta0));
                epsilon_dtheta(i,j) = -delta * j * sin(j*(theta - theta0));
            else
                epsilon(i,j) = 1;
                epsilon_dtheta(i,j) = 0;
            end
        end
    end
    
    %% order parameter field
    %% calculate latent heat term
    E(2:py-1, 2:px-1) = (alph/pi) * phi(2:py-1, 2:px-1) .* (1 - phi(2:py-1, 2:px-1)) .* atan(gamma * (Tm - T(2:py-1, 2:px-1)));
    
    %% chemical potential
    mu(2:py-1, 2:px-1) = 0.5 * phi(2:py-1, 2:px-1) .* (1 - phi(2:py-1, 2:px-1)) .* (1 - 2*phi(2:py-1, 2:px-1));
    
    %% Laplace of phi
    LapP(2:py-1, 2:px-1) = (phi(1:py-2,2:px-1) - 2*phi(2:py-1, 2:px-1) + phi(3:py,2:px-1))/dx^2 + ...
                           (phi(2:py-1,1:px-2) - 2*phi(2:py-1, 2:px-1) + phi(2:py-1,3:px))/dy^2;
    
    %% total chemical potential with anisotropy
    if delta == 0
        % Isotropic case (Fig 5-1)
        mu(2:py-1, 2:px-1) = mu(2:py-1, 2:px-1) + E(2:py-1, 2:px-1) - epsB^2*LapP(2:py-1, 2:px-1);
    else
        % Anisotropic case (Fig 7) - This is simplified; the full anisotropic term would require 
        % a more complex implementation of the gradient and curvature terms
        for i = 2:py-1
            for j = 2:px-1
                mu(i,j) = mu(i,j) + E(i,j) - epsB^2 * epsilon(i,j)^2 * LapP(i,j);
            end
        end
    end
    
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
        title(['Time = ' num2str(tm) ', K = ' num2str(K) ', delta = ' num2str(delta)])
        xlabel('x')
        ylabel('y')
        pbaspect([px py px])
        colormap(parula)
        colorbar
        drawnow
        
        figure(2)
        surf(T)
        view(2)
        title(['Temperature at t = ' num2str(tm)])
        xlabel('x')
        ylabel('y')
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
title(['Final Configuration at t = ' num2str(tm) ', K = ' num2str(K) ', delta = ' num2str(delta)])
xlabel('x')
ylabel('y')
pbaspect([px py px])
colormap(parula)
colorbar