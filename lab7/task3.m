clear all
clc;

%% 2D rectangular domain
Ly = 9.0;
Lx = 3.0;  % For directional solidification

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
K = 0.8;
alph = 0.9;
gamma = 10.0;
Tm = 1.0;

%% anisotropy parameters
% Choose one of the following modes:
anisotropy_mode = 'dendrite'; % Options: 'dendrite', 'snowflake', 'none'

if strcmp(anisotropy_mode, 'dendrite')
    delta = 0.04;   % Anisotropy strength for dendrites
    j = 4;          % 4-folder anisotropy for dendrites
elseif strcmp(anisotropy_mode, 'snowflake')
    delta = 0.04;   % Anisotropy strength for snowflakes
    j = 6;          % 6-folder anisotropy for snowflakes
else
    delta = 0.0;    % No anisotropy
    j = 4;          % Default value (not used)
end

theta0 = 0;    % Preferred directions align with x and y axes

%% 2D arrays
phi = zeros(py, px);
phi_old = zeros(py, px);
mu = zeros(py, px);
LapP = zeros(py, px);
E = zeros(py, px);
T = zeros(py, px);
LapT = zeros(py, px);
epsilon = zeros(py, px);           % Anisotropic gradient energy coefficient
epsilon_dtheta = zeros(py, px);    % Derivative of epsilon w.r.t theta
px_grad = zeros(py, px);           % x-component of phi gradient
py_grad = zeros(py, px);           % y-component of phi gradient
grad_norm = zeros(py, px);         % Magnitude of phi gradient
theta = zeros(py, px);             % Interface normal angle
nx = zeros(py, px);                % x-component of normal vector
ny = zeros(py, px);                % y-component of normal vector

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
snapshot_count = 0;
snapshot_interval = floor(Nstp/4);  % Take 4 snapshots during simulation

%% time iteration
for iter = 1:Nstp
    % Store previous phi for latent heat calculation
    phi_old = phi;
    
    %% Calculate gradient components and normal vector for anisotropy
    for i = 2:py-1
        for j = 2:px-1
            % Calculate gradient components using central difference
            px_grad(i,j) = (phi(i,j+1) - phi(i,j-1))/(2*dx);
            py_grad(i,j) = (phi(i+1,j) - phi(i-1,j))/(2*dy);
            grad_norm(i,j) = sqrt(px_grad(i,j)^2 + py_grad(i,j)^2);
            
            % Calculate normal vector components and angle theta
            if grad_norm(i,j) > 1e-10
                % Normal vector components (pointing from liquid to solid)
                nx(i,j) = -px_grad(i,j)/grad_norm(i,j);
                ny(i,j) = -py_grad(i,j)/grad_norm(i,j);
                
                % Calculate angle using atan2 for proper quadrant
                theta(i,j) = atan2(ny(i,j), nx(i,j));
                
                % Calculate anisotropic gradient energy coefficient and its derivative
                epsilon(i,j) = 1 + delta * cos(j*(theta(i,j) - theta0));
                epsilon_dtheta(i,j) = -delta * j * sin(j*(theta(i,j) - theta0));
            else
                nx(i,j) = 0;
                ny(i,j) = 0;
                theta(i,j) = 0;
                epsilon(i,j) = 1;
                epsilon_dtheta(i,j) = 0;
            end
        end
    end
    
    %% order parameter field
    %% calculate latent heat term
    E(2:py-1, 2:px-1) = (alph/pi) * phi(2:py-1, 2:px-1) .* (1 - phi(2:py-1, 2:px-1)) .* atan(gamma * (Tm - T(2:py-1, 2:px-1)));
    
    %% chemical potential (free energy derivative)
    mu(2:py-1, 2:px-1) = 0.5 * phi(2:py-1, 2:px-1) .* (1 - phi(2:py-1, 2:px-1)) .* (1 - 2*phi(2:py-1, 2:px-1));
    
    %% Laplace of phi (used for isotropic term)
    LapP(2:py-1, 2:px-1) = (phi(1:py-2,2:px-1) - 2*phi(2:py-1, 2:px-1) + phi(3:py,2:px-1))/dy^2 + ...
                           (phi(2:py-1,1:px-2) - 2*phi(2:py-1, 2:px-1) + phi(2:py-1,3:px))/dx^2;
    
    %% Apply anisotropic interface energy contribution to chemical potential
    for i = 2:py-1
        for j = 2:px-1
            % Base chemical potential (from free energy derivative)
            mu_base = mu(i,j) + E(i,j);
            
            if delta > 0 && grad_norm(i,j) > 1e-10
                % Isotropic contribution (with anisotropic coefficient)
                iso_term = -epsB^2 * epsilon(i,j)^2 * LapP(i,j);
                
                % Anisotropic correction terms from the paper's equation
                % ∂/∂x(εε′)∂φ/∂y - ∂/∂y(εε′)∂φ/∂x
                
                % Calculate cross derivatives
                if j > 2 && j < px-1 && i > 2 && i < py-1
                    % Calculate ∂/∂x(εε′)
                    eps_eps_prime_x = (epsilon(i,j+1) * epsilon_dtheta(i,j+1) - epsilon(i,j-1) * epsilon_dtheta(i,j-1)) / (2*dx);
                    
                    % Calculate ∂/∂y(εε′)
                    eps_eps_prime_y = (epsilon(i+1,j) * epsilon_dtheta(i+1,j) - epsilon(i-1,j) * epsilon_dtheta(i-1,j)) / (2*dy);
                    
                    % Anisotropic correction terms
                    aniso_term = epsB^2 * (eps_eps_prime_x * py_grad(i,j) - eps_eps_prime_y * px_grad(i,j));
                else
                    aniso_term = 0;
                end
                
                % Total chemical potential including anisotropic effects
                mu(i,j) = mu_base + iso_term + aniso_term;
            else
                % Isotropic case
                mu(i,j) = mu_base - epsB^2 * LapP(i,j);
            end
        end
    end
    
    %% temperature field
    %% Laplace of temperature
    LapT(2:py-1, 2:px-1) = (T(1:py-2, 2:px-1) - 2*T(2:py-1, 2:px-1) + T(3:py, 2:px-1))/dy^2 + ...
                           (T(2:py-1, 1:px-2) - 2*T(2:py-1, 2:px-1) + T(2:py-1, 3:px))/dx^2;
                       
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
        title(['Time = ' num2str(tm) ', K = ' num2str(K) ', delta = ' num2str(delta) ...
              ', j = ' num2str(j) ' (' anisotropy_mode ')'])
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
    
    % Save snapshots at regular intervals
    if mod(iter, snapshot_interval) == 0 || iter == Nstp
        snapshot_count = snapshot_count + 1;
        figure(2 + snapshot_count)
        surf(phi)
        view(2)
        title(['Snapshot ' num2str(snapshot_count) ' at t = ' num2str(tm) ...
              ', K = ' num2str(K) ', delta = ' num2str(delta) ...
              ', j = ' num2str(j) ' (' anisotropy_mode ')'])
        xlabel('x')
        ylabel('y')
        pbaspect([px py px])
        colormap(parula)
        colorbar
        saveas(gcf, ['snapshot_' anisotropy_mode '_' num2str(snapshot_count) '.png'])
    end
end

% Display final configuration
figure(10)
surf(phi)
view(2)
title(['Final Configuration at t = ' num2str(tm) ', K = ' num2str(K) ...
      ', delta = ' num2str(delta) ', j = ' num2str(j) ' (' anisotropy_mode ')'])
xlabel('x')
ylabel('y')
pbaspect([px py px])
colormap(parula)
colorbar
saveas(gcf, ['final_' anisotropy_mode '.png'])