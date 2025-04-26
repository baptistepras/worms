import numpy as np
import matplotlib.pyplot as plt
import math

g = 9.81

def trajectoire(v0, angle, tmax,h, N):
    t = np.linspace(0, tmax, N)
    
    x = math.cos(angle)*t*v0 
    y = -0.5*g*t*t+math.sin(angle)*v0*t+h 


    return x, y

def trajectoir2(v0, angle, tmax, M, N):
    t = 0 
    T = []
    X = []
    Y  = []
    x = 0
    y = M
    h = 1 / 60 


    while t < tmax:
        X.append(x)
        Y.append(y)
        T.append(t)
        dx = math.cos(angle) * v0
        dy = -g*t + math.sin(angle)*v0
        x = x + dx*h
        y = y + dy*h
        t = t +h

    return np.array(T), np.array(X), np.array(Y)
    



# Exemple d'utilisation
v0 = 0.5  # vitesse initiale en m/s
angle = math.radians(45)  # angle en degrés
tmax = 12  # temps maximum en secondes
h = 0  # hauteur initiale en mètres
N = 100
les_t, les_x, les_y = trajectoir2(v0, angle, tmax, h , N)


plt.plot(les_t,les_y,label="Y")
plt.plot(les_t, les_x,label="X",color="red")
plt.legend()
plt.show()
