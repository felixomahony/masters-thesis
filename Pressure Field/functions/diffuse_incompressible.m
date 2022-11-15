function [velocity_x, velocity_y] = diffuse_incompressible(velocity_x, velocity_y, decay, normalized_wavenumbers_x, normalized_wavenumbers_y)

n_points_y = size(velocity_x, 1);
n_points_x = size(velocity_x, 2);

%Transform Into Fourier
velocity_x_fft = fft2(velocity_x); %Case A
velocity_y_fft = fft2(velocity_y); %Case A
%
%Low Pass Filter
velocity_x_fft = velocity_x_fft .* decay;
velocity_y_fft = velocity_y_fft .* decay;
%
%Compute Pseudo Pressure
pressure_fft = velocity_x_fft .* normalized_wavenumbers_x + velocity_y_fft .* normalized_wavenumbers_y;
%
%Project Velocities to be Incompressible
velocity_x_fft = velocity_x_fft - pressure_fft .* normalized_wavenumbers_x;
velocity_y_fft = velocity_y_fft - pressure_fft .* normalized_wavenumbers_y;
%
%Transform Into Spatial
velocity_x = real(ifft2(velocity_x_fft, n_points_y, n_points_x));
velocity_y = real(ifft2(velocity_y_fft, n_points_y, n_points_x));

end