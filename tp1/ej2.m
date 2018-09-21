clear;
close all;

load('guia1_files.mat');

fs = 1000;
N1 = length(y1);
N2 = length(y2);

espectro1 = fft(y1, N1) / N1;
espectro2 = fft(y2, N2) / N2;
frecuencias1 = linspace(0, fs*((N1-1)/N1), N1);
frecuencias2 = linspace(0, fs*((N2-1)/N2), N2);

figure
plot(frecuencias1, abs(espectro1));
figure
plot(frecuencias2, abs(espectro2));

figure
spectrogram(y1, hamming(200), 0, N1, fs);
figure
spectrogram(y2, hamming(200), 0, N2, fs);