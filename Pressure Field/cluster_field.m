im = imread("../res/starry_night.jpg");
im = imgaussfilt(im,5);
im = imresize(im,1/8);

im_ycbcr = rgb2ycbcr(im);
im_y = im_ycbcr(:,:,1); %Only look at Y channel

clusters = 1:numel(im_y);

difference_x = double(im_y(:,1:end-1)) - double(im_y(:, 2:end));
difference_x_sq = difference_x .* difference_x;
difference_x_sq = [difference_x_sq,Inf.*ones(size(difference_x_sq,1), 1)];

difference_y = double(im_y(1:end-1,:)) - double(im_y(2:end, :));
difference_y_sq = difference_y .* difference_y;
difference_y_sq = [difference_y_sq;Inf.*ones(1, size(difference_y_sq,2))];

difference_x_sq_flat = reshape(difference_x_sq, [1,numel(difference_x_sq)]);
difference_y_sq_flat = reshape(difference_y_sq, [1,numel(difference_y_sq)]);

[ordered_x, order_x] = sort(difference_x_sq_flat);
[ordered_y, order_y] = sort(difference_x_sq_flat);

ref_index_y = 1;
for i = 1:size(ordered_x,2)
  difference_of_pixels_x = ordered_x(i);
  difference_of_pixels_y = ordered_y(ref_index_y);

  while (difference_of_pixels_y <= difference_of_pixels_x)
  
    index_of_pixel_to_add_1_y = order_y(i);
    index_of_pixel_to_add_2_y = order_y(i) + 1;

    [~, cluster_column_1] = find(clusters == index_of_pixel_to_add_1_y);
    [~, cluster_column_2] = find(clusters == index_of_pixel_to_add_2_y);
    if cluster_column_1 ~= cluster_column_2
      num_zero_c1 = sum(clusters(:,cluster_column_1)==0);
      num_zero_c2 = sum(clusters(:,cluster_column_2)==0);
      cluster_1 = clusters(1:end-num_zero_c1,cluster_column_1);
      cluster_2 = clusters(1:end-num_zero_c2,cluster_column_2);
      joint_cluster = [cluster_1;cluster_2];
      if (size(joint_cluster, 1) > size(clusters,1))
        clusters = [clusters;zeros(size(joint_cluster, 1) - size(clusters,1), size(clusters,2))];
      end
      clusters(1:size(joint_cluster, 1),cluster_column_1) = joint_cluster;
      clusters = [clusters(:,1:cluster_column_2-1), clusters(:,cluster_column_2+1:end)];
    end

    ref_index_y = ref_index_y + 1;
    difference_of_pixels_y = ordered_y(ref_index_y);
  end
  index_of_pixel_to_add_1 = order_x(i);
  index_of_pixel_to_add_2 = order_x(i) + size(difference_x_sq,1);
  if (difference_of_pixels_x > 9)
    break;
  end
  [~, cluster_column_1] = find(clusters == index_of_pixel_to_add_1);
  [~, cluster_column_2] = find(clusters == index_of_pixel_to_add_2);
  if cluster_column_1 ~= cluster_column_2
    num_zero_c1 = sum(clusters(:,cluster_column_1)==0);
    num_zero_c2 = sum(clusters(:,cluster_column_2)==0);
    cluster_1 = clusters(1:end-num_zero_c1,cluster_column_1);
    cluster_2 = clusters(1:end-num_zero_c2,cluster_column_2);
    joint_cluster = [cluster_1;cluster_2];
    if (size(joint_cluster, 1) > size(clusters,1)) 
      clusters = [clusters;zeros(size(joint_cluster, 1) - size(clusters,1), size(clusters,2))];
    end
    clusters(1:size(joint_cluster, 1),cluster_column_1) = joint_cluster;
    clusters = [clusters(:,1:cluster_column_2-1), clusters(:,cluster_column_2+1:end)];
  end

end

%Pixel colouring
im_reformed = zeros(1,numel(im_y));
for c = 1:size(clusters,2)
  cluster = clusters(1:end,c);
  num_zero = sum(cluster == 0);
  cluster = cluster(1:end - num_zero,:)';
  im_reformed(cluster) = rand();
end
im_reformed = reshape(im_reformed, size(im_y));
im_disp = zeros([size(im_reformed),3]);
im_disp(:,:,1) = im_reformed;
im_disp(:,:,2) = im_reformed;
im_disp(:,:,3) = im_reformed;
imshow(im_disp);