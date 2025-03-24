%% DLA_02.m
% Diffusion-Limited Aggregation with Visit-Count Attachment
% New feature: A walker attaches only if its current site has been
% visited more than M times (i.e., it has been adjacent to an aggregated site
% more than M times).

clear all;
clc;

%% USER PARAMETERS
M = 100;             % Threshold for visits (set to 1, 100, 1000, or 2000)
includeSecond = 0;   % Set 0: first nearest neighbors only; 1: include second nearest neighbors

%% Set simulation parameters based on M
if M == 1
    nwk = 1200;      % number of walkers for M=1
    Nstp = 5001;     % number of Monte Carlo iterations for M=1
else
    nwk = 4800;      % use more walkers for larger M
    Nstp = 10001;    % and more iterations
end

%% Set the size of the 2D computational domain
ngp = 100;                                  % number of grid points in each direction
Lttc = linspace(1, 100, ngp);                % equally spaced grid positions
[Xmsh, Ymsh] = meshgrid(Lttc, Lttc);         % create the 2D meshgrid

%% Initialize Walker and Aggregation Variables
X = zeros(nwk, 2);          % positions of walkers
LD = ones(nwk, 1);          % status: 1 = active walker, 0 = attached (dead)
Agr = zeros(ngp, ngp);      % Aggregation matrix: 1 = aggregated site, 0 = empty

% New: VisitCount matrix records how many times a site has been “visited” 
% (i.e., when a walker is adjacent to an aggregated site)
VisitCount = zeros(ngp, ngp);

%% Set the Nucleus (Seed)
Agr(1:2, 48:52) = 1;        % mark a small rectangular seed region as aggregated
for k = 1:5                % initialize 5 walkers on the seed (already attached)
    LD(k) = 0;           
    X(k, :) = [47 + k, 2];
end

%% Monte Carlo Iterations
for iter = 1:Nstp
    
    % Add new walkers into the domain (each new walker enters from the top)
    if iter > 5 && iter <= nwk
        X(iter, 1) = randi([2, ngp-1]);  % random x-position
        X(iter, 2) = ngp - 1;             % enter from the top
    end
    
    % Determine number of walkers active in the simulation at this iteration
    if iter <= nwk
        tnw = iter;
    else
        tnw = nwk;
    end
    
    %% Loop Over All Walkers
    for i = 1:tnw
        % Get current walker position
        idx = X(i, 1);
        idy = X(i, 2);
        
        % Random walk update (only for active walkers)
        if LD(i) == 1
            rv = rand;
            if rv <= 0.23      % 23% chance upward
                idy = idy + 1;
            elseif rv <= 0.5   % 27% chance downward
                idy = idy - 1;
            elseif rv <= 0.75  % 25% chance left
                idx = idx - 1;
            else               % 25% chance right
                idx = idx + 1;
            end
            
            % Enforce vertical boundaries
            if idy < 2
                idy = 2;
            end
            if idy > ngp - 1
                idy = ngp - 1;
            end
            
            % Enforce periodic boundary conditions in the X direction
            if idx == 1
                idx = ngp - 1;
            end
            if idx == ngp
                idx = 2;
            end
            
            % Move the walker only if the new site is unoccupied
            if Agr(idy, idx) == 0
                X(i, :) = [idx, idy];
            end
        end
        
        %% Check for Potential Attachment
        % A walker is eligible to attach if it is adjacent to an aggregated site.
        attach_possible = false;
        
        % Check first nearest neighbors (West, East, South, North)
        if Agr(idy, idx - 1) == 1 || Agr(idy, idx + 1) == 1 || ...
           Agr(idy - 1, idx) == 1 || Agr(idy + 1, idx) == 1
            attach_possible = true;
        end
        
        % Optionally, include second nearest neighbors (diagonals)
        if includeSecond
            if Agr(idy - 1, idx - 1) == 1 || Agr(idy - 1, idx + 1) == 1 || ...
               Agr(idy + 1, idx - 1) == 1 || Agr(idy + 1, idx + 1) == 1
                attach_possible = true;
            end
        end
        
        % If at least one neighbor is aggregated, count this as a "visit"
        if attach_possible
            VisitCount(idy, idx) = VisitCount(idy, idx) + 1;
            if VisitCount(idy, idx) > M
                Agr(idy, idx) = 1;   % attach the walker (aggregate the site)
                LD(i) = 0;           % mark the walker as dead (attached)
            end
        end
    end
    
    %% Update Aggregation Matrix Boundaries
    % Enforce no-flux boundaries in Y and periodic in X
    Agr(1, :) = Agr(2, :);
    Agr(ngp, :) = Agr(ngp - 1, :);
    Agr(:, 1) = Agr(:, ngp - 1);
    Agr(:, ngp) = Agr(:, 2);
    
    %% Visualization (Update every 20 iterations)
    if mod(iter, 20) == 1
        figure(2)
        alist = find(LD == 0);   % indices of attached walkers
        blist = find(LD == 1);   % indices of active walkers
        
        plot(X(alist, 1), X(alist, 2), 'r.', 'MarkerSize', 14)
        hold on
        plot(X(blist, 1), X(blist, 2), 'b.', 'MarkerSize', 14)
        hold off
        daspect([1 1 1])
        axis([1 ngp 1 ngp])
        grid on
        title(['Iteration: ' num2str(iter)])
        pause(0.04)
        
        % If all walkers are attached, end simulation
        if sum(LD, "all") == nwk
            break
        end
    end
end
