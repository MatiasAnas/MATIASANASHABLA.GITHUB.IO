clear;
close all;

f1 = 100;
f2 = 200;
A = 1;
B = 1;

fs = 500;
%Ancho de la ventana.
L = 25            
n = [0:L-1]';
%Tamaño de la DFT.
N = 100

x = A * cos(2 * pi* f1 * n / fs) + B * cos(2 * pi * f2 * n / fs);
x = x .* hamming(L);

espectro_x = fft(x, N) / L;
frecuencias = linspace(0, fs*((N-1)/N), N);

plot(frecuencias, abs(espectro_x));
axis([0,500,0,1]);