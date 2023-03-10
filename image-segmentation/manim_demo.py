from manim import *
from manim import hex_to_rgb
import pickle
import numpy as np


rgb_bg = ("#a69cacff")

with open('../out/U.pkl', 'rb') as inp:
    U = np.real(pickle.load(inp))
with open('../out/V.pkl', 'rb') as inp:
    V = np.real(pickle.load(inp))

sz = np.shape(U)

n_points_y = sz[0]
n_points_x = sz[1]

aspect_ratio = n_points_x/n_points_y
coordinates_x = np.ones([n_points_y,1]) @ np.array([np.arange(start = 0, stop = aspect_ratio,step = aspect_ratio/n_points_x)])#linspace(0,aspect_ratio, n_points_x);
coordinates_y = np.array([np.arange(0,1,1/n_points_y)]).T * np.ones([1,n_points_x])

wavenumbers_1d_x = np.fft.fftfreq(n_points_x)
wavenumbers_1d_y = np.fft.fftfreq(n_points_y)
#wavenumbers_1d_x = [0:((n_points_x - rem(n_points_x,2))/2-1), -((n_points_x - rem(n_points_x,2))/2):-1];
n_fft_points_x = np.shape(wavenumbers_1d_x)[0]
#wavenumbers_1d_y = [0:((n_points_y - rem(n_points_y,2))/2-1), -((n_points_y - rem(n_points_y,2))/2):-1];
n_fft_points_y = np.shape(wavenumbers_1d_y)[0]

wavenumbers_x = np.ones([n_fft_points_y,1]) @ np.array([wavenumbers_1d_x])
wavenumbers_y = np.array([wavenumbers_1d_x]).T @ np.ones([1,n_fft_points_x])

print(U)

def curl_fft_UV(U,V):
    d_u_d_y_fft = 1j * wavenumbers_y * np.fft.fft2(U)
    d_v_d_x_fft = 1j * wavenumbers_x * np.fft.fft2(V)
    curl_fft = d_v_d_x_fft - d_u_d_y_fft
    return curl_fft
def curl(curl_fft):
    # print(curl_fft.shape)
    curl = np.fft.ifft2(curl_fft, np.shape(U))
    curl = np.real(curl)
    return curl
C = np.copy(curl(curl_fft_UV(U,V)))
mn = np.min(C)
C -= mn
mx = np.max(C)
C /= mx
def interpolate_u_v(x,y):
    x*=1
    y*=-1
    if (np.abs(x) > 4):
        return np.zeros([3])
    if (np.abs(y) > 4):
        return np.zeros([3])
    if (np.isnan(x) or np.isnan(y)):
        return np.zeros([3])
    x += 4
    y += 4
    x /=8
    y /=8
    nx = np.shape(U)[1]
    x *= nx
    x_low = np.floor(x)
    x_high = np.ceil(x)
    rx = x - x_low
    x_low = np.int32(np.clip(x_low,0,nx-1))
    x_high = np.int32(np.clip(x_high,0,nx-1))

    ny = np.shape(U)[0]
    y *= ny
    y_low = np.floor(y)
    y_high = np.ceil(y)
    ry= y - y_low
    y_low = np.int32(np.clip(y_low,0,ny-1))
    y_high = np.int32(np.clip(y_high,0,ny-1))

    u = U[y_low,x_low]*(1-rx)*(1-ry)+U[y_high,x_low]*(1-rx)*(ry)+U[y_high,x_high]*(rx)*(ry)+U[y_low,x_high]*(rx)*(1-ry)
    v = V[y_low,x_low]*(1-rx)*(1-ry)+V[y_high,x_low]*(1-rx)*(ry)+V[y_high,x_high]*(rx)*(ry)+V[y_low,x_high]*(rx)*(1-ry)
    c = C[y_low,x_low]*(1-rx)*(1-ry)+C[y_high,x_low]*(1-rx)*(ry)+C[y_high,x_high]*(rx)*(ry)+C[y_low,x_high]*(rx)*(1-ry)
    return np.array([-u,v,c*0.01+0.5])
def get_color(pos):
    # print("pos",pos)
    # print((pos[2]-0.5)*100)
    return (pos[2]-0.5)*100
class VanGoghVortex(Scene):
    def construct(self):
        # func = lambda pos: np.cos(pos[0] / 2) * UR + np.cos(pos[1] / 2) * LEFT
        cfunc = lambda pos: np.float16(pos[0])
        rgb_bg = hex_to_rgb("#a69cacff")
        self.background_color = rgb_bg
        rgb_stroke = hex_to_rgb("#161b33")
        self.camera.background_color="#161b33ff"
        func = lambda pos: interpolate_u_v(pos[0],pos[1])
        self.aspect_ratio = 1
        stream_lines = StreamLines(func, color_scheme = get_color, colors = ["#f1dac4", "#a69cacff"], stroke_width=2, max_anchors_per_line=30, min_color_scheme_value=0, max_color_scheme_value=1)
        spawning_area = Rectangle(width = 1,height=1)
        flowing_area = Rectangle(width = 1,height=1)
        self.add(stream_lines)
        stream_lines.start_animation(warm_up=False, flow_speed=1.5)
        self.wait(stream_lines.virtual_time / stream_lines.flow_speed)

class VanGoghVField(Scene):
    def construct(self):
        func = lambda pos: interpolate_u_v(pos[0],pos[1])
        self.camera.background_color="#161b33"
        vector_field = ArrowVectorField(func = func, colors = ["#f1dac4", "#a69cacff"])
        self.add(vector_field)
        # vector_field.play()