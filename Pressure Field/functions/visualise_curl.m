function visualise_curl(velocity_x, velocity_y, wavenumbers_x, wavenumbers_y)

n_points_x = size(velocity_x, 2);
n_points_y = size(velocity_x, 1);
d_u_d_y_fft = 1i .* wavenumbers_y .* fft2(velocity_x);
d_v_d_x_fft = 1i .* wavenumbers_x .* fft2(velocity_y);
curl_fft = d_v_d_x_fft - d_u_d_y_fft;
curl = ifft2(curl_fft, n_points_y, n_points_x);
curl = (real(curl));

imshow((curl - min(min(curl)))/(max(max(curl))-min(min(curl))))
colormap(gca, jet(256));
end