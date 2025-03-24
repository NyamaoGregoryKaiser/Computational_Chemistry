%% DLA_03.m
% Diffusion-Limited Aggregation in a 200x200 domain with the nucleus at the center.
% Walkers start at random positions and perform a fully random walk.
% Attachment is considered only via the first nearest neighbors.
% A walker attaches if its current site has been "visited" (i.e. found adjacent to an aggregated site)
% more than M times.
%
% Set parameters:
%   M    - threshold for attachment (try M = 1, 100, 1000, 2000)
%   nwk  - number of walkers (default 2400)
%   Nstp - number of iterations (default 100001)

clear all;
clc;

%% USER PARAMETERS
M = 100;              % Threshold for visit count (set to 1, 100, 1000, or 2000)
nwk = 2400;           % Number of walkers
Nstp = 100001;        % Number of Monte Carlo iterations

%% Set the size of the 2D computational domain
ngp = 200;                        % domain size: 200 x 200
Lttc = linspace(1, 200, ngp);       % grid positions
[Xmsh, Ymsh] = meshgrid(Lttc, Lttc); % create the 2D meshgrid

%% Initialize Walker and Aggregation Variables
X = zeros(nwk, 2);          % Walker positions: each row [x, y]
LD = ones(nwk, 1);          % Status: 1 = active, 0 = attached
Agr = zeros(ngp, ngp);      % Aggregation matrix: 1 = aggregated site, 0 = empty

% VisitCount matrix to record the number of visits at each site.
VisitCount = zeros(ngp, ngp);

% Place all walkers at random positions in the domain (avoiding the boundaries)
for i = 1:nwk
    X(i, 1) = randi([2, ngp-1]);
    X(i, 2) = randi([2, ngp-1]);
end

%% Set the nucleus at the center of the domain
% For a 200x200 grid, choose a 3x3 square at the center as the seed.
center = round(ngp / 2);
nuc_half = 1;  % half-width of the nucleus block
Agr(center-nuc_half:center+nuc_half, center-nuc_half:center+nuc_half) = 1;

% Mark any walker starting inside the nucleus as attached.
for i = 1:nwk
    if Agr(X(i,2), X(i,1)) == 1
        LD(i) = 0;
    end
end

%% Monte Carlo Iterations
for iter = 1:Nstp
    for i = 1:nwk
        if LD(i) == 1  % Only move active walkers
            % Fully random walk: choose one of the four directions uniformly.
            direction = randi(4);
            idx = X(i, 1);
            idy = X(i, 2);
            switch direction
                case 1 % move up
                    idy = idy + 1;
                case 2 % move down
                    idy = idy - 1;
                case 3 % move left
                    idx = idx - 1;
                case 4 % move right
                    idx = idx + 1;
            end
            
            % Reflecting boundary conditions (prevent leaving the domain)
            if idx < 2, idx = 2; end
            if idx > ngp-1, idx = ngp-1; end
            if idy < 2, idy = 2; end
            if idy > ngp-1, idy = ngp-1; end
            
            % Update the walker position if the new site is unoccupied
            if Agr(idy, idx) == 0
                X(i, :) = [idx, idy];
            end
            
            % Check for potential attachment:
            % Consider only the first nearest neighbors: left, right, up, and down.
            if Agr(idy, idx-1) == 1 || Agr(idy, idx+1) == 1 || ...
               Agr(idy-1, idx) == 1 || Agr(idy+1, idx) == 1
                % Increase the visitation count for the current site.
                VisitCount(idy, idx) = VisitCount(idy, idx) + 1;
                % If the visit count exceeds threshold M, attach the walker.
                if VisitCount(idy, idx) > M
                    Agr(idy, idx) = 1;
                    LD(i) = 0;
                end
            end
        end
    end
    
    %% Visualization every 1000 iterations
    if mod(iter, 1000) == 1
        figure(3)
        clf;
        % Plot aggregated sites (red)
        [Y_agg, X_agg] = find(Agr == 1);
        plot(X_agg, Y_agg, 'r.', 'MarkerSize', 14);
        hold on;
        % Plot active walkers (blue)
        active_idx = find(LD == 1);
        plot(X(active_idx, 1), X(active_idx, 2), 'b.', 'MarkerSize', 14);
        hold off;
        daspect([1 1 1]);
        axis([1 ngp 1 ngp]);
        grid on;
        title(['Iteration: ' num2str(iter) ', M = ' num2str(M)]);
        pause(0.01);
    end
end

%% Final Snapshot
figure(3)
clf;
[Y_agg, X_agg] = find(Agr == 1);
plot(X_agg, Y_agg, 'r.', 'MarkerSize', 14);
hold on;
active_idx = find(LD == 1);
plot(X(active_idx, 1), X(active_idx, 2), 'b.', 'MarkerSize', 14);
hold off;
daspect([1 1 1]);
axis([1 ngp 1 ngp]);
grid on;
title(['Final Configuration, M = ' num2str(M)]);
