function [X_grid,Y_grid,field_x,field_y] = generate_velocity_field(clusters, sz, show_image)
if ~exist('show_image','var')
  show_image = false;
end
X = [];
Y = [];
U = [];
V = [];
for i = 1:size(clusters,1)
  means = mean(clusters(i),1);
  X = [X;means(2)];
  Y = [Y;-means(1)];
  cluster  = clusters(i);
  wyes = cluster(:,1);
  exes = [ones(size(cluster,1),1),cluster(:,2)];
  ws = (exes' * exes) \ (exes' * wyes);
  U = [U;10/sqrt(1+ws(2)*ws(2))];
  V = [V;ws(2) * 10/sqrt(1+ws(2)*ws(2))];
end
if (show_image)
  subplot(2,1,1);
  quiver(X,Y,U,V, "off");
  xlim([0 sz(2)]);
  ylim([-sz(1) 0]);
end

U_p = U./sqrt(U.*U+V.*V);
V = V./sqrt(U.*U+V.*V);
U = U_p;
Y = -Y;


field_x = zeros(sz);
field_y = zeros(sz);
for j = 1:size(field_y,1)
  for i = 1:size(field_x,2)
    p = 6;
    dist = power((X - i),p)+power((Y-j),p);
    inv_dist = 1./dist;
    field_x(j,i) = sum(U(~isnan(U)).*inv_dist(~isnan(U)))/(sum(inv_dist(~isnan(U))));
    field_y(j,i) = sum(V(~isnan(V)).*inv_dist(~isnan(V)))/(sum(inv_dist(~isnan(V))));
  end
end
X_grid = ones([sz(1),1]) * (1:(sz(2)));
Y_grid = (1:sz(1))' * ones([1,sz(2)]);
if (show_image)
  subplot(2,1,2);
  n = numel(X_grid);
  quiver(reshape(X_grid,[1,n]),reshape(Y_grid,[1,n]),reshape(field_x,[1,n]),reshape(field_y,[1,n]));
end
end