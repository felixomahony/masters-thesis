import cv2
import numpy as np
import matplotlib.pyplot as plt
import config
import os

def azimuthal_average_power_spectrum(image):
    '''
    This function takes the azimuthally-averaged power spectrum of an image.
    Params
    -----
    image: numpy array
        Image to calculate the power spectrum of.
    '''
    image_ft = np.fft.fft2(image) #Take FT
    image_ft = np.fft.fftshift(image_ft) #By default, FFT puts the high frequencies in the middle
    image_ft = image_ft * np.conj(image_ft) #Power so multiply by conjugate
    image_ft = np.real(image_ft) #image_ft will still be of complex type without this
    image_ft = cv2.GaussianBlur(image_ft, (0,0), 3) #Blur image
    sz = image_ft.shape
    image_ft = image_ft / (sz[0]**2)/(sz[1]**2) #By default numpy.fft is not size-normalised

    radius = radius_map(sz)

    #Azimuthally average according to radius
    max_r = int(np.max(radius))
    power_az_av = [np.mean(image_ft[np.logical_and(radius > i, radius < i+1)]) for i in range(max_r)]
    return power_az_av

def calculate_gradient_linear(spectrum, mask_1, mask_2):
    '''
    This function calculates the gradient of a line section between mask_1 and mask_2 of a power spectrum.
    It fits a line to calculate the best fit of a variable 'a' in the function log(spectrum)=a*log(x)+b
    Params
    ------
    spectrum: array
        Power spectrum for which to fit a linear section.
    mask_1, mask_2: int
        Wave numbers between which the linear section should be fitted.
    '''

    #Masking and taking logs
    spectrum = np.array(spectrum)
    spectrum = spectrum[np.logical_and(np.arange(spectrum.size) >= mask_1, np.arange(spectrum.size) < mask_2)]
    spectrum_index = np.arange(mask_1, mask_2)
    log_spectrum = np.log(spectrum)
    log_spectrum_index = np.log(spectrum_index)

    #Fitting a line
    log_spectrum = np.expand_dims(log_spectrum, axis=0).T
    log_spectrum_index = np.expand_dims(log_spectrum_index, axis=0).T
    log_spectrum_index = np.hstack((log_spectrum_index, np.ones(log_spectrum_index.shape)))
    fit_vector = np.linalg.inv(log_spectrum_index.T @ log_spectrum_index) @ (log_spectrum_index.T @ log_spectrum)
    return fit_vector[0]

def remove_frequencies(image, n):
    '''
    This function destroys certain frequencies in an image.
    Params
    -----
    image: numpy array
        image to destroy frequencies of
    n: int
        number of iterations of frequency destruction to complete.'''
    image_ft = np.fft.fft2(image) #Take FT
    image_ft = np.fft.fftshift(image_ft) #By default, FFT puts the high frequencies in the middle
    sz = image_ft.shape
    radius = radius_map(sz)

    max_r = np.max(radius)
    log_max_r = np.log10(max_r) #We will destroy at log-spaced frequencies.
    for i in range(n):
        image_ft_decayed = np.copy(image_ft) #Take FT
        mask = radius > 10**(log_max_r*(i+1)/n) #Mask according to radius
        image_ft_decayed[mask] = 0 #Destroy frequencies
        image_ft_decayed = np.fft.fftshift(image_ft_decayed) #We need to re-shift the frequencies as above.
        image_decayed = np.fft.ifft2(image_ft_decayed) #Invert FT
        image_decayed = np.abs(image_decayed) #Get rid of complex values
        image_decayed = np.clip(image_decayed, 0, 255) #Clip to [0, 255]
        mask = np.array(mask, np.float32)
        mask[np.logical_and(radius > 27, radius < 29)] = 0.5
        mask[np.logical_and(radius > 70, radius < 72)] = 0.5
        image_decayed = np.hstack((image_decayed, (1-mask)*255))
        cv2.imwrite(config.OUT_DIR + "/"+str(i)+"_low.png", image_decayed) #Write image
        image_ft_decayed = np.copy(image_ft)
        mask = radius < 10**(log_max_r*(i+1)/n)
        image_ft_decayed[mask] = 0
        image_ft_decayed = np.fft.fftshift(image_ft_decayed)
        image_decayed = np.fft.ifft2(image_ft_decayed)
        image_decayed = np.abs(image_decayed)
        image_decayed = np.clip(image_decayed, 0, 255)
        mask = np.array(mask, np.float32)
        mask[np.logical_and(radius > 27, radius < 29)] = 0.5
        mask[np.logical_and(radius > 70, radius < 72)] = 0.5
        image_decayed = np.hstack((image_decayed, (1-mask)*255))
        cv2.imwrite(config.OUT_DIR + "/"+str(i)+"_high.png", image_decayed)
    os.system("ffmpeg -f image2 -framerate 10 -i "+config.OUT_DIR+"/%d_high.png -loop 0 "+config.OUT_DIR+"/high.gif -y") #Make gif
    os.system("ffmpeg -f image2 -framerate 10 -i "+config.OUT_DIR+"/%d_low.png -loop 0 "+config.OUT_DIR+"/low.gif -y")

def radius_map(sz):
    #Find radii of pixels
    x_ords = np.ones((sz[0],1)) @ np.expand_dims(np.arange(sz[1]), axis=0)
    y_ords = np.expand_dims(np.arange(sz[0]), axis=0).T @ np.ones((1,sz[1]))
    x_ords = x_ords - sz[1]//2
    y_ords = y_ords - sz[0]//2
    radius = np.sqrt(x_ords * x_ords + y_ords * y_ords)
    return radius


if __name__=="__main__":
    starry_night = cv2.imread(config.SOURCE)
    starry_night = cv2.cvtColor(starry_night, cv2.COLOR_BGR2GRAY) #Flatten image to greyscale
    # print(starry_night.shape)

    power_az_av = azimuthal_average_power_spectrum(starry_night) #Calculate power spectrum
    gradient = calculate_gradient_linear(power_az_av, 28, 71)
    remove_frequencies(starry_night, config.N_MASKS)
    print(gradient)

    #Plotting methods
    plt.plot(power_az_av)
    plt.plot([28,28],[0, 100], 'r')
    plt.plot([71,71],[0, 100], 'r')
    plt.loglog()
    plt.xlabel("k")
    plt.ylabel("Azimuthally-Averaged Power")
    plt.show()
