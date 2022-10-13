im = imread("../res/starry_night.jpg");
im = imgaussfilt(im,20);
im = imresize(im,1/5);

im_ycbcr = rgb2ycbcr(im);
im_y = im_ycbcr(:,:,1); %Only look at Y channel

kernel_size = 50; %Max wavelength /px which will be studied

sz_im = size(im_y);
sz_im(1) = sz_im(1) - kernel_size;
sz_im(2) = sz_im(2) - kernel_size; %Cannot overflow the kernel outside the image border

scale_image = zeros([kernel_size, sz_im], 'double'); %This will store overall image

for y = 1:sz_im(1) % Iterate over image
  for x = 1:1:sz_im(2)
    block = im_y(y:(y+kernel_size - 1), x:(x+kernel_size-1)); % Form kernel block by cropping image
    dct_block = dct2(im2double(block)); % Perform discrete cosine transform
    intensity_flat_x = sum(dct_block, 1)'; % Flatten image
    intensity_flat_y = sum(dct_block, 2); % Flatten image
    intensity_flat = intensity_flat_x.*intensity_flat_x+intensity_flat_y.*intensity_flat_y;
    scale_image(1:end, y, x) = intensity_flat; % Update scale with freq. values
  end
end

mean_scale = mean(scale_image, [2,3]); % For z-parametrisation
sd_scale = std(scale_image, 1, [2,3]); % For z-parametrisation
scale_image = (scale_image - mean_scale)./sd_scale; % Normalise
[~, P] = max(scale_image, [], 1); % Find max values within normal field

P = P/kernel_size * 4*pi/3; % Make sine value (0 -> pi) by dividing by size of kernel
R = cos(P) * 0.5 + 0.5; %Red channel
G = cos(P - 2*pi/3) * 0.5 + 0.5; % Green channel
B = cos(P - 4*pi/3) * 0.5 + 0.5; % Blue channel

img = zeros([size(P, [2,3]),3]);
img(:,:,1) = R(1,:,:);
img(:,:,2) = G(1,:,:);
img(:,:,3) = B(1,:,:);
imshow(img)