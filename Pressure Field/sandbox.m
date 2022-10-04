% base = meshgrid(1:100);
% output = base;% + base';
% output = sin(output) * 0.5 + 0.5;
% imshow(output)
% plot(sum(dct2(output), 1))
% title("Flattened dct of horizontal pattern")
% xlabel("Frequency")
% ylabel("Intensity of component")

rows = 0:0.01:1;
cols = ones(30,1);
img = cols * rows;

img = img * 4*pi/3; % Make sine value (0 -> pi) by dividing by size of kernel
R = cos(img) * 0.5 + 0.5; %Red channel
G = cos(img - 2*pi/3) * 0.5 + 0.5; % Green channel
B = cos(img - 4*pi/3) * 0.5 + 0.5; % Blue channel
img = zeros([size(img), 3]);
img(:,:,1) = R;
img(:,:,2) = G;
img(:,:,3) = B;
imshow(img);