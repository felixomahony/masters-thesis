function [velocity_x, velocity_y] = turbulent_time_progression(U, V)
%hold on
n_points_y = size(U,1);
n_points_x = size(U,2);
nu = 1/1000;
dt = 0.001;
n_iter = 1000;

aspect_ratio = n_points_x/n_points_y;
coordinates_x = ones(n_points_y,1) * linspace(0,aspect_ratio, n_points_x);
coordinates_y = linspace(0,1,n_points_y)' * ones(1,n_points_x);


wavenumbers_1d_x = [0:((n_points_x - rem(n_points_x,2))/2-1), -((n_points_x - rem(n_points_x,2))/2):-1];
n_fft_points_x = size(wavenumbers_1d_x,2);
wavenumbers_1d_y = [0:((n_points_y - rem(n_points_y,2))/2-1), -((n_points_y - rem(n_points_y,2))/2):-1];
n_fft_points_y = size(wavenumbers_1d_y,2);

wavenumbers_x = ones(n_fft_points_y,1) * wavenumbers_1d_x;
wavenumbers_y = wavenumbers_1d_y' * ones(1,n_fft_points_x);
wavenumbers_x_squared = wavenumbers_x .* wavenumbers_x;
wavenumbers_y_squared = wavenumbers_y .* wavenumbers_y;
wavenumbers_norm = sqrt(wavenumbers_x_squared + wavenumbers_y_squared);

decay = exp(-dt .* nu .* wavenumbers_norm .* wavenumbers_norm);
wavenumbers_norm(wavenumbers_norm==0) = 1; %145
normalized_wavenumbers_x = wavenumbers_x ./ wavenumbers_norm;
normalized_wavenumbers_y = wavenumbers_y ./ wavenumbers_norm;

%Line 156
velocity_x = zeros(n_points_y, n_points_x);
velocity_y = zeros(n_points_y, n_points_x);

% velocity_x_prev = zeros(n_points_y, n_points_x);
% velocity_y_prev = zeros(n_points_y, n_points_x);
velocity_x_prev = U;
velocity_x_prev(isnan(velocity_x_prev)) = 0;
velocity_y_prev = V;
velocity_y_prev(isnan(velocity_y_prev)) = 0;




for iter = 1:n_iter
  [velocity_x, velocity_y] = backtrace(coordinates_x, coordinates_y, velocity_x_prev, velocity_y_prev, dt, aspect_ratio);
  
  [velocity_x, velocity_y] = zero_mean_velocity(velocity_x, velocity_y);

  [velocity_x, velocity_y] = diffuse_incompressible(velocity_x, velocity_y, decay, normalized_wavenumbers_x, normalized_wavenumbers_y);

  [velocity_x, velocity_y] = zero_mean_velocity(velocity_x, velocity_y);

  %Progress in Time
  velocity_x_prev = velocity_x;
  velocity_y_prev = velocity_y;
  if mod(iter,100)==0
    aaa=0;
  end
  %Visualise
  %quiver(reshape(coordinates_x,[numel(coordinates_x),1]),reshape(coordinates_y,[numel(coordinates_x),1]),reshape(velocity_x,[numel(coordinates_x),1]),reshape(velocity_y,[numel(coordinates_x),1]));
  %xlim([0.87,0.95])
  %ylim([0.43,0.5])

%   % Visualize
%   Tight = get(gca, 'TightInset');  %Gives you the bording spacing between plot box and any axis labels
%                                  %[Left Bottom Right Top] spacing
%   NewPos = [Tight(1) Tight(2) 1-Tight(1)-Tight(3) 1-Tight(2)-Tight(4)]; %New plot position [X Y W H]
%   set(gca, 'Position', NewPos);
%   colormap(gca, jet(256));
%   exportgraphics(gcf,"../out/images/"+sprintf('%04d',iter)+".png",'Resolution',300)

  %curl = sign.(curl) .* sqrt.(abs.(curl) ./ quantile(vec(curl), 0.8))
end
% Visualize
visualise_curl(velocity_x, velocity_y, wavenumbers_x, wavenumbers_y)

end
