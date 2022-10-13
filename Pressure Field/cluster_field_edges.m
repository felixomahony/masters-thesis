im = imread("../res/starry_night.jpg");
im = imgaussfilt(im,5);
im = imresize(im,1/5);

im_ycbcr = rgb2ycbcr(im);
im_y = im_ycbcr(:,:,1); %Only look at Y channel
%imshow(im_y)

im_edges = edge(im_y, "Canny");
imshow(im_edges)

ctr = 0;
clusters = containers.Map;
cluster_keys = [];
for y = 1:size(im_edges,1)
  for x = 1:size(im_edges,2)
    if (im_edges(y,x) == 1)
      my_cluster = [y, x];
      for c = cluster_keys
        if (or(ismember(0,sum((clusters(int2str(c)) - [y, x]).* (clusters(int2str(c)) - [y, x]), 2) - 2),ismember(0,sum((clusters(int2str(c)) - [y, x]).* (clusters(int2str(c)) - [y, x]), 2) - 1)))
          my_cluster = [my_cluster; clusters(int2str(c))];
          remove(clusters, int2str(c));
          cluster_keys = cluster_keys(cluster_keys~=c);
        end
      end
      clusters(int2str(ctr)) = my_cluster;
      cluster_keys = [cluster_keys, ctr];
    end
    ctr = ctr + 1;
  end
end