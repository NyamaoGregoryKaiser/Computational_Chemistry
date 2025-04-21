clear all
clc

%% 2D square domain
Ly = 3.0;
Lx = 3.0;

%% discretization in the y and x directions
Ny = 100;
Nx = 100;

%% grid spacing and time step size
dx = Lx/Nx;
dy = Ly/Ny;
dt = 0.00015;  % Modified as per lab document
Nstp = 5001;   %3001;

%% parameters
epsP = 0.012;
M_phi = 500;
L = 2;
alph = 0.9;
gamma = 10.0;
Tm = 1.0;
wp = 1/4;

%% 
ws = 0.008;
wl = 0.04;

epsC = 0.0015;

%% 2D arrays
phi = zeros(Ny ,Nx);
mu = zeros(Ny, Nx);
LapP = zeros(Ny, Nx);
E = zeros(Ny, Nx);
T = -5*ones(Ny, Nx);
LapT = zeros(Ny, Nx);

hf = zeros(Ny, Nx);
dhf = zeros(Ny, Nx);
muC = zeros(Ny, Nx);
LapC = zeros(Ny, Nx);
M_C = zeros(Ny, Nx);

%% initial condition
for i = 1:Ny
    intf = randi([-1 1]) + 6;
    for j = 1:Nx
        if j < intf
            phi(i,j) = 1;
        else
            phi(i,j) = 0;
        end
    end
end

Con = rand(Ny,Nx)*0.01 + 0.495;

tm = 0.0;

%% time iteration
for iter = 1:Nstp
    
    %% interpolation functions
    hf(2:Ny-1,2:Nx-1) = phi(2:Ny-1,2:Nx-1).^2 .* (3 - 2*phi(2:Ny-1,2:Nx-1));
    dhf(2:Ny-1,2:Nx-1) = 6*phi(2:Ny-1,2:Nx-1).*(1 - phi(2:Ny-1,2:Nx-1));
    
    %% order parameter field
    %% calculate latent heat term
    E(2:Ny-1, 2:Nx-1) = (alph/pi)*atan(gamma*(T(2:Ny-1, 2:Nx-1) - Tm)).*dhf(2:Ny-1,2:Nx-1);
    
    %% chemical potential
    mu(2:Ny-1, 2:Nx-1) = wp*2*(phi(2:Ny-1, 2:Nx-1).* (1.0-phi(2:Ny-1, 2:Nx-1))).*(1.0-2*phi(2:Ny-1, 2:Nx-1)) + ...
        dhf(2:Ny-1,2:Nx-1).*(ws*Con(2:Ny-1,2:Nx-1).^2.*(1-Con(2:Ny-1,2:Nx-1)).^2) - dhf(2:Ny-1,2:Nx-1).*wl.*(0.5-Con(2:Ny-1,2:Nx-1)).^4;
    
    %% Laplace of phi
    LapP(2:Ny-1, 2:Nx-1) = (phi(1:Ny-2,2:Nx-1) - 2*phi(2:Ny-1, 2:Nx-1) + phi(3:Ny-0,2:Nx-1))/dx^2 + ...
                           (phi(2:Ny-1,1:Nx-2) - 2*phi(2:Ny-1, 2:Nx-1) + phi(2:Ny-1,3:Nx-0))/dy^2;
    
    %% total chemical potential
    mu(2:Ny-1, 2:Nx-1) = mu(2:Ny-1, 2:Nx-1) + 1/6*E(2:Ny-1, 2:Nx-1) - epsP^2*LapP(2:Ny-1, 2:Nx-1);  
    
    
    %% concentration field
    muC(2:Ny-1, 2:Nx-1) = hf(2:Ny-1,2:Nx-1).*2*ws.*Con(2:Ny-1,2:Nx-1).*(1-Con(2:Ny-1,2:Nx-1)).*(1-2*Con(2:Ny-1,2:Nx-1)) - ...
                          4*(1-hf(2:Ny-1,2:Nx-1)).*wl.*(0.5-Con(2:Ny-1,2:Nx-1)).^3;
    
    %% Laplace of Con     
    LapC(2:Ny-1, 2:Nx-1) = (Con(1:Ny-2,2:Nx-1) - 2*Con(2:Ny-1, 2:Nx-1) + Con(3:Ny-0,2:Nx-1))/dx^2 + ...
                           (Con(2:Ny-1,1:Nx-2) - 2*Con(2:Ny-1, 2:Nx-1) + Con(2:Ny-1,3:Nx-0))/dy^2;
                       
    muC(2:Ny-1, 2:Nx-1) = muC(2:Ny-1, 2:Nx-1) - epsC^2*LapC(2:Ny-1, 2:Nx-1);
    
    muC(1,:) = muC(Ny-1 ,:);
    muC(Ny,:) = muC(2,:);
    muC(:,1) = muC(:,2);
    muC(:,Nx) = muC(:,Nx-1);   
    
    %% Laplace of muC
    M_C(2:Ny-1,2:Nx-1) = 40*dhf(2:Ny-1,2:Nx-1) + 0.05;
    LapC(2:Ny-1, 2:Nx-1) = (muC(1:Ny-2,2:Nx-1) - 2*muC(2:Ny-1, 2:Nx-1) + muC(3:Ny-0,2:Nx-1))/dx^2 + ...
                           (muC(2:Ny-1,1:Nx-2) - 2*muC(2:Ny-1, 2:Nx-1) + muC(2:Ny-1,3:Nx-0))/dy^2;
    
    %% temperature field
    %% Laplace of temperature
    LapT(2:Ny-1, 2:Nx-1) = (T(1:Ny-2,2:Nx-1) - 2*T(2:Ny-1, 2:Nx-1) + T(3:Ny-0,2:Nx-1))/dx^2 + ...
                           (T(2:Ny-1,1:Nx-2) - 2*T(2:Ny-1, 2:Nx-1) + T(2:Ny-1,3:Nx-0))/dy^2;
                       
    %% update order parameter                 
    phi(2:Ny-1, 2:Nx-1) = phi(2:Ny-1, 2:Nx-1) - dt* M_phi *mu(2:Ny-1, 2:Nx-1);
    
    %% update concentration 
    Con(2:Ny-1, 2:Nx-1) = Con(2:Ny-1, 2:Nx-1) + dt* M_C(2:Ny-1, 2:Nx-1) .* LapC(2:Ny-1, 2:Nx-1);
    
    %% update temperature
    T(2:Ny-1, 2:Nx-1) = T(2:Ny-1, 2:Nx-1) + dt* LapT(2:Ny-1, 2:Nx-1) - dt*L*M_phi*mu(2:Ny-1, 2:Nx-1);
    
    %% boundary conditions; no-flux
    phi(1,:) = phi(Ny-1 ,:);
    phi(Ny,:) = phi(2,:);
    phi(:,1) = phi(:,2);
    phi(:,Nx) = phi(:,Nx-1);
 
    Con(1,:) = Con(Ny-1 ,:);
    Con(Ny,:) = Con(2,:);
    Con(:,1) = Con(:,2);
    Con(:,Nx) = Con(:,Nx-1);    
    
    T(1,:) = T(Ny-1,:);
    T(Ny,:) = T(2,:);
    T(:,1) = T(:,2);
    T(:,Nx) = T(:,Nx-1);   
    
    %% time
    tm = tm + dt;
    
    % visualization
    if mod(iter,20) == 1
        
        figure(1)
        surf(phi)
        view(2)
        caxis([-0.02 1.02])
        title([num2str(tm) '  ' num2str(iter)])
        pbaspect([Nx Ny Nx])
        colormap(parula)
        colorbar
        shading interp
 
        
        figure(2)
        surf(T)
        view(2)
        pbaspect([Nx Ny Nx])
        colormap(hot)
        colorbar
        shading interp;
        
        figure(3)
        surf(Con)
        view(2)
        caxis([-0.02 1.02])
        pbaspect([Nx Ny Nx])
        colormap(jet)
        colorbar
        shading interp;        
        
    end
    
end