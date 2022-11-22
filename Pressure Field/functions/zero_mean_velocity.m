function [velocity_x, velocity_y] = zero_mean_velocity(velocity_x, velocity_y)

  %Subtract Mean
  velocity_x = velocity_x - mean(mean(velocity_x));
  velocity_y = velocity_y - mean(mean(velocity_y));

end