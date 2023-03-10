import cv2
import numpy as np
import config
import os

l2d = np.array([[0, 1, 0],[1, -4, 1],[0, 1, 0]])

def join_lines(img):
    img = np.mean(img,axis = 2)
    img = img/255
    img = np.array( img > 0.5, np.uint8)
    B = np.copy(img)
    A = 0.9*(1-img)+0.1
    diffusion_advection(A, B, 1000)
    cv2.imwrite(config.OUT_DIR, img*255)
    os.system("ffmpeg -f image2 -framerate 15 -i \"/Users/felixomahony/OneDrive - Nexus365/4Y/MAE 442 - Senior Thesis/masters-thesis/line-join/out/%d.png\" Output.gif -y")

def diffusion_advection(A, B, N):
    for i in range(N):
        A, B = da_step(A, B)
        cv2.imwrite("out/"+str(i)+".png", B*255)

def da_step(A, B):
    del_A = (config.DA * cv2.filter2D(A, -1, l2d) - A * B * B + config.F*(1-A))*config.DT
    del_B = (config.DB * cv2.filter2D(B, -1, l2d) + A * B * B - (config.K+config.F)*B)*config.DT

    A = np.clip(np.copy(A + del_A), 0, 1)
    B = np.clip(np.copy(B + del_B), 0, 1)
    return (A,B)


if __name__ == "__main__":
    img = cv2.imread(config.IMG_DIR)
    join_lines(img)