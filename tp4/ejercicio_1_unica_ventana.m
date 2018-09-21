close all;
clear;

tiempo_ventana = 0.025;
archivo = 'fantasia.wav';
M = 20;

%Cargo el archivo.
[audio, fs] = audioread(archivo);

tamanio_ventana = tiempo_ventana * fs;

%Obtengo la porcion donde esta la 'a'.
audio_ventaneado = audio(14000 : (14000 + tamanio_ventana - 1));

%Calculo de coeficientes LPC.
r = xcorr(audio_ventaneado);
r = r(tamanio_ventana : (tamanio_ventana + M - 1));
R = toeplitz(r(1: M - 1));

b = R\r(2 : M);
G = sqrt(r(1) - b' * r(2 : M));

%Estimacion.
audio_estimado = filter([0; b], 1 , audio_ventaneado);

%Grafico señal estimada vs señal original.
figure(1);
hold on;
tiempos = linspace(0, tamanio_ventana / fs, tamanio_ventana);
plot(tiempos, audio_ventaneado);
plot(tiempos, audio_estimado);
title('Señal Estimada VS Original.');
legend('Original', 'Estimada');
xlabel('Tiempo (s)');
ylabel('Amplitud');

%Grafico error.
figure(2);
plot(tiempos, audio_ventaneado - audio_estimado);
title('Error De Estimación.');
legend('Error');
xlabel('Tiempo (s)');
ylabel('Amplitud');

%Grafico espectro vs envolvente.
figure(3);
hold on;
frecuencias = linspace(0, fs*((tamanio_ventana-1)/tamanio_ventana), tamanio_ventana);

plot(frecuencias, abs(fft(audio_ventaneado)));

envolvente = freqz(G, [1; -b], tamanio_ventana, 'whole');
plot(frecuencias, abs(envolvente));

axis([0, fs/2, 0, 25]);

title('Espectro VS Envolvente.');
legend('Espectro', 'Envolvente');
xlabel('Frecuencia (Hz)');
ylabel('Amplitud');
