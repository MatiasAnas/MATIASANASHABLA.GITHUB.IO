close all;
clear;

tiempo_ventana = 0.025;
tiempo_avance_ventana = 0.010;
archivo = 'fantasia.wav';
M = 20;

%Cargo el audio.
[audio, fs] = audioread(archivo);

tamanio_ventana = tiempo_ventana * fs;
avance_ventana = tiempo_avance_ventana * fs;

%Recorto las partes vacias.
inicio_de_audio = 9000;
fin_de_audio = 25000;
audio = audio(inicio_de_audio : fin_de_audio);

posicion_ventana = 1;
i = 1;
envolvente = zeros(ceil(length(audio) / avance_ventana), tamanio_ventana);

%Obtengo coeficientes LPC para cada ventana.
while (posicion_ventana + tamanio_ventana < length(audio))
    audio_ventaneado = audio(posicion_ventana : (posicion_ventana + tamanio_ventana - 1));
    r = xcorr(audio_ventaneado);
    r = r(tamanio_ventana : (tamanio_ventana + M - 1));
    R = toeplitz(r(1: M - 1));
    b = R\r(2 : M);
    G = sqrt(r(1) - b' * r(2 : M));
    
    envolvente(i,:) = abs(freqz(G, [1; -b], tamanio_ventana, 'whole'));
    
    i = i + 1;
    posicion_ventana = posicion_ventana + avance_ventana;
end

%Grafico de envolventes.
figure(1);
[a,b] = size(envolvente);
tiempos = linspace(0, length(audio) / fs, a);
frecuencias = linspace(0, fs*((tamanio_ventana-1)/tamanio_ventana), tamanio_ventana);
s  = surf(frecuencias, tiempos, 10*log(envolvente));
s.EdgeColor = 'none';
view(2);
axis([0, fs / 2, 0, length(audio) / fs])

title('Envolventes.');
xlabel('Frecuencia (Hz)');
ylabel('Tiempo (s)');

%Grafico De Espectrograma.
figure(2);
spectrogram(audio, hamming(tamanio_ventana),(tamanio_ventana - avance_ventana), tamanio_ventana, fs);
title('Espectrograma.');
