%Open image and rescale it
if exist('U','var') ~= 1
  im = imread("../res/starry_night.jpg");
  im = imgaussfilt(im,5);
  im = imresize(im,1/5);
  clusters = create_clusters(im);
  [X, Y, U, V] = generate_velocity_field(clusters, size(im,1:2), false);
end

U = randn(size(U));
V = randn(size(V));
subplot(2,1,1);
turbulent_time_progression(U,V);
U = U+0.1*randn(size(U));
V = V + 0.1*randn(size(V));
subplot(2,1,2);
turbulent_time_progression(U,V);
