clear all;
clc;

%% disxretization
Ny = 128;
Nx = 128;
Nstp = 10001;

%% simulation parameters
Omg = 2.9;
kap = 1.5;
dx = 1.0;
dt = 1.0e-2;
Mob = 1.0;

%% Case 1
C11 = 157.9*20;
C12 = 113.7*20;
C44 = 70.5*20;

%% Case 2
% C11 = 347.6*10;
% C12 = 121.8*10;
% C44 = 81.5*10;

%% arrays
phi = zeros(Ny,Nx);
df_fp = zeros(Ny,Nx);
Lap = zeros(Ny,Nx);
mu = zeros(Ny,Nx);

u = zeros(Ny,Nx);
v = zeros(Ny,Nx);

eps0_xx = 0.02;
eps0_yy = 0.02;

eps_xx = zeros(Ny,Nx);
eps_yy = zeros(Ny,Nx);

b_x = zeros(Ny,Nx);
b_y = zeros(Ny,Nx);

RHS_x = zeros(Ny,Nx);
RHS_y = zeros(Ny,Nx);

ResU = zeros(Ny,Nx);
ResV = zeros(Ny,Nx);

dW_dp = zeros(Ny,Nx);


%% initial condition
phi(2:Ny-1,2:Nx-1) = rand(Ny-2,Nx-2)*0.2 + 0.3;
phi(1,:) = phi(Ny-1,:);
phi(Ny,:) = phi(2,:);
phi(:,1) = phi(:,Nx-1);
phi(:,Nx) = phi(:,2);


for iter = 1: Nstp
    
    %% chemical potential
    df_dp(2:Ny-1,2:Nx-1) = Omg*(1.0-2*phi(2:Ny-1,2:Nx-1)) + ...
        log(phi(2:Ny-1,2:Nx-1)./(1.0-phi(2:Ny-1,2:Nx-1)));
    
    %% Laplace of phi
    Lap(2:Ny-1,2:Nx-1) = (phi(3:Ny-0,2:Nx-1) + phi(1:Ny-2,2:Nx-1) + ...
                          phi(2:Ny-1,3:Nx-0) + phi(2:Ny-1,1:Nx-2) - ...
                          4*phi(2:Ny-1,2:Nx-1))/dx^2;
    
    %% body force (misfit) in x direction                  
    b_x(2:Ny-1,2:Nx-1) = (C11*eps0_xx + C12*eps0_yy)*(phi(2:Ny-1,3:Nx-0) - phi(2:Ny-1,1:Nx-2))/(2*dx);

    %% body force (misfit) in y direction    
    b_y(2:Ny-1,2:Nx-1) = (C12*eps0_xx + C11*eps0_yy)*(phi(3:Ny-0,2:Nx-1) - phi(1:Ny-2,2:Nx-1))/(2*dx);
        
    %% solve elasticity
    norm_U = 1.0;
    norm_V = 1.0;
    cnt = 1;
    while norm_U > 0.01 | norm_V > 0.01 
        
        RHS_x(2:Ny-1,2:Nx-1) = b_x(2:Ny-1,2:Nx-1) - ...
            (C12+C44)*((v(3:Ny-0,3:Nx-0)-v(1:Ny-2,3:Nx-0))/(2*dx) - ...
                      (v(3:Ny-0,1:Nx-2)-v(1:Ny-2,1:Nx-2))/(2*dx))/(2*dx);
                  
        RHS_y(2:Ny-1,2:Nx-1) = b_y(2:Ny-1,2:Nx-1) - ...
            (C12+C44)*((u(3:Ny-0,3:Nx-0)-u(1:Ny-2,3:Nx-0))/(2*dx) - ...
                      (u(3:Ny-0,1:Nx-2)-u(1:Ny-2,1:Nx-2))/(2*dx))/(2*dx);    
                  
        %% solve for u and v           
        u(2:Ny-1,2:Nx-1) = (RHS_x(2:Ny-1,2:Nx-1)*dx^2 - ...
            C11*(u(2:Ny-1,3:Nx-0)+u(2:Ny-1,1:Nx-2)) - ...
            C44*(u(3:Ny-0,2:Nx-1)+u(1:Ny-2,2:Nx-1)))/(-2*C11-2*C44);
        
        v(2:Ny-1,2:Nx-1) = (RHS_y(2:Ny-1,2:Nx-1)*dx^2 - ...
            C44*(v(2:Ny-1,3:Nx-0)+v(2:Ny-1,1:Nx-2)) - ...
            C11*(v(3:Ny-0,2:Nx-1)+v(1:Ny-2,2:Nx-1)))/(-2*C44-2*C11);  
        
        %% periodic BC
        u(1,:) = u(Ny-1,:);
        u(Ny,:) = u(2,:);
        u(:,1) = u(:,Nx-1);
        u(:,Nx) = u(:,2); 

        v(1,:) = v(Ny-1,:);
        v(Ny,:) = v(2,:);
        v(:,1) = v(:,Nx-1);
        v(:,Nx) = v(:,2);

        RHS_x(2:Ny-1,2:Nx-1) = b_x(2:Ny-1,2:Nx-1) - ...
            (C12+C44)*((v(3:Ny-0,3:Nx-0)-v(1:Ny-2,3:Nx-0))/(2*dx) - ...
                      (v(3:Ny-0,1:Nx-2)-v(1:Ny-2,1:Nx-2))/(2*dx))/(2*dx);
                  
        RHS_y(2:Ny-1,2:Nx-1) = b_y(2:Ny-1,2:Nx-1) - ...
            (C12+C44)*((u(3:Ny-0,3:Nx-0)-u(1:Ny-2,3:Nx-0))/(2*dx) - ...
                      (u(3:Ny-0,1:Nx-2)-u(1:Ny-2,1:Nx-2))/(2*dx))/(2*dx);      
        
        %% calculate the residual to determine whether the solution is reached.
        ResU(2:Ny-1,2:Nx-1) = ...
            C11*(u(2:Ny-1,3:Nx-0)-2*u(2:Ny-1,2:Nx-1)+u(2:Ny-1,1:Nx-2))/dx^2 + ...
            C44*(u(3:Ny-0,2:Nx-1)-2*u(2:Ny-1,2:Nx-1)+u(1:Ny-2,2:Nx-1))/dx^2 - ...
            RHS_x(2:Ny-1,2:Nx-1);
        
        ResV(2:Ny-1,2:Nx-1) = ...
            C44*(v(2:Ny-1,3:Nx-0)-2*v(2:Ny-1,2:Nx-1)+v(2:Ny-1,1:Nx-2))/dx^2 + ...
            C11*(v(3:Ny-0,2:Nx-1)-2*v(2:Ny-1,2:Nx-1)+v(1:Ny-2,2:Nx-1))/dx^2 - ...
            RHS_y(2:Ny-1,2:Nx-1);

        norm_U = norm(ResU(2:Ny-1,2:Nx-1),2)/((Ny-2)*(Nx-2));
        norm_V = norm(ResV(2:Ny-1,2:Nx-1),2)/((Ny-2)*(Nx-2));  
        
        cnt = cnt + 1;
        
        if cnt > 500
            break;
        end
    end
    
    %% calculate the strains
    eps_xx(2:Ny-1,2:Nx-1) = (u(2:Ny-1,3:Nx-0)-u(2:Ny-1,1:Nx-2))/(2*dx);
    eps_yy(2:Ny-1,2:Nx-1) = (v(3:Ny-0,2:Nx-1)-v(1:Ny-2,2:Nx-1))/(2*dx);
    
    %% strain potential
    dW_dp(2:Ny-1,2:Nx-1) = C11*(eps_xx(2:Ny-1,2:Nx-1)*eps0_xx + eps_yy(2:Ny-1,2:Nx-1)*eps0_yy) + ...
                          C12*(eps_xx(2:Ny-1,2:Nx-1)*eps0_yy + eps_yy(2:Ny-1,2:Nx-1)*eps0_xx) - ...
                          0.5*C11*(eps0_xx^2 + eps0_yy^2) - C12*eps0_xx*eps0_yy;
                            
    %% total chemical potential
    mu(2:Ny-1,2:Nx-1) = df_dp(2:Ny-1,2:Nx-1) - kap*Lap(2:Ny-1,2:Nx-1) + dW_dp(2:Ny-1,2:Nx-1);
    
    %% periodic BC
    mu(1,:) = mu(Ny-1,:);
    mu(Ny,:) = mu(2,:);
    mu(:,1) = mu(:,Nx-1);
    mu(:,Nx) = mu(:,2); 
    
    %% Laplace of chemical potential for Cahn-Hilliard equation
    Lap(2:Ny-1,2:Nx-1) = (mu(3:Ny-0,2:Nx-1) + mu(1:Ny-2,2:Nx-1) + ...
                          mu(2:Ny-1,3:Nx-0) + mu(2:Ny-1,1:Nx-2) - ...
                        4*mu(2:Ny-1,2:Nx-1))/dx^2;    
    
    
    %% time update
    phi(2:Ny-1,2:Nx-1) = phi(2:Ny-1,2:Nx-1) + dt*Mob*Lap(2:Ny-1,2:Nx-1);
    %% periodic BC
    phi(1,:) = phi(Ny-1,:);
    phi(Ny,:) = phi(2,:);
    phi(:,1) = phi(:,Nx-1);
    phi(:,Nx) = phi(:,2); 
    
    %% visualization
    if mod(iter,100) == 1
        surf(phi)
        title([num2str(iter)])
        view(2)
        colorbar
        pbaspect([Ny Nx Nx])
        pause(0.05)
    end
end

% Calculate stress for final configuration
eps_xy(2:Ny-1,2:Nx-1) = ((v(2:Ny-1,3:Nx-0)-v(2:Ny-1,1:Nx-2))/(2*dx) + ...
                         (u(3:Ny-0,2:Nx-1)-u(1:Ny-2,2:Nx-1))/(2*dx))/2;

%% stress
sigma_xx = zeros(Ny,Nx);
sigma_xx(2:Ny-1,2:Nx-1) = ...
    C11*(eps_xx(2:Ny-1,2:Nx-1)-phi(2:Ny-1,2:Nx-1)*eps0_xx) + ...
    C12*(eps_yy(2:Ny-1,2:Nx-1)-phi(2:Ny-1,2:Nx-1)*eps0_yy);

sigma_xx(1,:) = sigma_xx(Ny-1,:);
sigma_xx(Ny,:) = sigma_xx(2,:);
sigma_xx(:,1) = sigma_xx(:,Nx-1);
sigma_xx(:,Nx) = sigma_xx(:,2); 

sigma_yy = zeros(Ny,Nx);
sigma_yy(2:Ny-1,2:Nx-1) = ...
    C12*(eps_xx(2:Ny-1,2:Nx-1)-phi(2:Ny-1,2:Nx-1)*eps0_xx) + ...
    C11*(eps_yy(2:Ny-1,2:Nx-1)-phi(2:Ny-1,2:Nx-1)*eps0_yy);

sigma_yy(1,:) = sigma_yy(Ny-1,:);
sigma_yy(Ny,:) = sigma_yy(2,:);
sigma_yy(:,1) = sigma_yy(:,Nx-1);
sigma_yy(:,Nx) = sigma_yy(:,2); 

sigma_xy = zeros(Ny,Nx);
sigma_xy(2:Ny-1,2:Nx-1) = C44*2*eps_xy(2:Ny-1,2:Nx-1);

sigma_xy(1,:) = sigma_xy(Ny-1,:);
sigma_xy(Ny,:) = sigma_xy(2,:);
sigma_xy(:,1) = sigma_xy(:,Nx-1);
sigma_xy(:,Nx) = sigma_xy(:,2); 

sigma_vm = sqrt(0.5*((sigma_xx-sigma_yy).^2 + sigma_xx.^2 + sigma_yy.^2) + 3*sigma_xy.^2);

figure(2)
surf(sigma_vm)
title('von Mises Stress')
view(2)
colorbar