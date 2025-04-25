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
for iter = 1:4001
    
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
        % 5-point stencil for Laplacian: (f(i+1,j) + f(i-1,j) + f(i,j+1) + f(i,j-1) - 4*f(i,j))/(dx^2)
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
    
    %% visualization
    if mod(iter,20) == 1
        figure(1)
        val(1:Ny,1:Nx) = sum(eta(1:Ny,1:Nx,1:noG).^2,3);
        surf(val)
        shading interp
        view(2)
        pbaspect([Nx,Ny,Ny])
        colorbar
        title(['Time step: ', num2str(iter)])
        
        % Save snapshots at specified iterations
        if iter == 200 || iter == 1000 || iter == 3000
            snapname = sprintf('grain_growth_snapshot_iter_%d.png', iter);
            saveas(gcf, snapname);
        end
        
        pause(0.02)
    end
   
end

%% additional plots for individual grains if needed
% for p = 1:noG
%     figure(100+p)
%     surf(eta(:,:,p))
%     shading interp
%     view(2)
%     pbaspect([Nx,Ny,Ny])
% end