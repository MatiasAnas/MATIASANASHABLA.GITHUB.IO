clear;
close all;

f1 = 100;
f2 = 200;
A = 1;
B = 1;

fs = 500;
%Ancho de la ventana.
L = fs / ((f2 - f1) / 2) * 8;   % Es el minimo en el que se notan las dos
                            % senoidales con ventana cuadrada.                         
n = 0:L-1;

%Tamaño de la DFT.
N = 80;

x = A * cos(2 * pi* f1 * n / fs) + B * cos(2 * pi * f2 * n / fs);

espectro_x = fft(x, N) / L;
frecuencias = linspace(0, fs*((N-1)/N), N);

stem(frecuencias, abs(espectro_x));
axis([0,500,0,1]);