function clusters = create_clusters(im)
  %Take only the chroma spectrum
  im_ycbcr = rgb2ycbcr(im);
  im_y = im_ycbcr(:,:,1); %Only look at Y channel
  
  im_edges = edge(im_y, "Canny");
  %imshow(im_edges)
  
  ctr = 0;
  clusters = containers.Map;
  cluster_keys = [];
  
  %Now we need to create a dictionary to store the clusters
  remaining_pixels = int8(im_edges);
  clusters = containers.Map('KeyType', 'int32', 'ValueType','any');
  x_indices = ones(size(im_edges,1),1) * (1:size(im_edges,2));
  y_indices = (1:size(im_edges,1))' * ones(1,size(im_edges,2));
  for y = 1:size(im_edges,1)
    for x = 1:size(im_edges,2)
      if (remaining_pixels(y,x) == 1)
        cluster = grayconnected(remaining_pixels,y,x, 0.5);
        x_cluster = x_indices(cluster);
        y_cluster = y_indices(cluster);
        clusters(size(clusters,1)+1) = [y_cluster,x_cluster];
        for item = 1:size(x_cluster,1)
          remaining_pixels(y_cluster(item,1),x_cluster(item,1)) = 0;
        end
      end
    end
  end
end