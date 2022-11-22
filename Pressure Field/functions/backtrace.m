function [velocity_x, velocity_y] = backtrace(coordinates_x, coordinates_y, velocity_x_prev, velocity_y_prev, dt, aspect_ratio)

  %First, get the backtraced coordinates (if you follow the streamline
  %back, where do we go?)
  backtraced_coordinates_x = coordinates_x - dt.* velocity_x_prev;
  backtraced_coordinates_y = coordinates_y - dt.* velocity_y_prev;

  %The reference tells us the matrix index of the matrix we need to select
  backtraced_reference_x = backtraced_coordinates_x ./ aspect_ratio * (size(coordinates_x,2)-1) + 1;
  backtraced_reference_x_low = floor(backtraced_reference_x);
  backtraced_reference_x_high = ceil(backtraced_reference_x);
  linear_const_x = backtraced_reference_x - backtraced_reference_x_low;
  backtraced_reference_x_low = mod(backtraced_reference_x_low-1,size(backtraced_reference_x_low,2))+1;
  backtraced_reference_x_high = mod(backtraced_reference_x_high-1,size(backtraced_reference_x_high,2))+1;

  backtraced_reference_y = backtraced_coordinates_y * (size(coordinates_y,1)-1) + 1;
  backtraced_reference_y_low = floor(backtraced_reference_y);
  backtraced_reference_y_high = ceil(backtraced_reference_y);
  linear_const_y = backtraced_reference_y - backtraced_reference_y_low;
  backtraced_reference_y_low = mod(backtraced_reference_y_low-1,size(backtraced_reference_y_low,1))+1;
  backtraced_reference_y_high = mod(backtraced_reference_y_high-1,size(backtraced_reference_y_high,1))+1;

  %Need to reshape the velocity matrix to account for the fact that we can
  %only index a vector not a matrix
  velocity_x_row = reshape(velocity_x_prev,[1,numel(velocity_x_prev)]);
  velocity_y_row = reshape(velocity_y_prev,[1,numel(velocity_y_prev)]);

  %Need to amend the referencing to account for the fact it is a vector not
  %an index.
  %This is made more confusing since MATLAB indexes at 1 (hence +1)
  low_low_index = (backtraced_reference_x_low-1).*size(coordinates_x,1)+(backtraced_reference_y_low-1)+1;
  low_high_index = (backtraced_reference_x_low-1).*size(coordinates_x,1)+(backtraced_reference_y_high-1)+1;
  high_low_index = (backtraced_reference_x_high-1).*size(coordinates_x,1)+(backtraced_reference_y_low-1)+1;
  high_high_index = (backtraced_reference_x_high-1).*size(coordinates_x,1)+(backtraced_reference_y_high-1)+1;

  %Complete interpolation for backtracing
  velocity_x = velocity_x_row(low_low_index).* (1-linear_const_x).*(1-linear_const_y) + velocity_x_row(low_high_index).* (1-linear_const_x).*(linear_const_y) + velocity_x_row(high_low_index).* (linear_const_x).*(1-linear_const_y) + velocity_x_row(high_high_index).* (linear_const_x).*(linear_const_y);
  velocity_y = velocity_y_row(low_low_index).* (1-linear_const_x).*(1-linear_const_y) + velocity_y_row(low_high_index).* (1-linear_const_x).*(linear_const_y) + velocity_y_row(high_low_index).* (linear_const_x).*(1-linear_const_y) + velocity_y_row(high_high_index).* (linear_const_x).*(linear_const_y);

end