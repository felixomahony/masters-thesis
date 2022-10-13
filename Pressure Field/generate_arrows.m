X = [];
Y = [];
U = [];
V = [];
for i = cluster_keys
  means = mean(clusters(int2str(i)),1);
  X = [X;means(2)];
  Y = [Y;-means(1)];
  cluster  = clusters(int2str(i));
  wyes = cluster(:,1);
  exes = [ones(size(cluster,1),1),cluster(:,2)];
  ws = (exes' * exes) \ (exes' * wyes);
  U = [U;10/sqrt(1+ws(2)*ws(2))];
  V = [V;ws(2) * 10/sqrt(1+ws(2)*ws(2))];
end
quiver(X,Y,U,V, "off");
xlim([0 size(im_y,2)]);
ylim([-size(im_y,1) 0]);