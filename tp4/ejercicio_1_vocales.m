close all;
clear;

tiempo_ventana = 0.025;
tiempo_avance_ventana = 0.010;
archivo = 'fantasia.wav';
M = 20;

%Cargo Audio.
[audio, fs] = audioread(archivo);

tamanio_ventana = tiempo_ventana * fs;

%Recorto las partes vacias.
inicio_de_audio = 9000;
fin_de_audio = 25000;
audio = audio(inicio_de_audio : fin_de_audio);

%Grafico envolventes para cada vocal.
posicion_vocales = [1500, 5000, 9000, 12500];

figure(1);
hold on;

frecuencias = linspace(0, fs*((tamanio_ventana-1)/tamanio_ventana), tamanio_ventana);

for posicion_vocal = posicion_vocales
    audio_ventaneado = audio(posicion_vocal : (posicion_vocal + tamanio_ventana - 1));
    r = xcorr(audio_ventaneado);
    r = r(tamanio_ventana : (tamanio_ventana + M - 1));
    R = toeplitz(r(1: M - 1));
    b = R\r(2 : M);
    G = sqrt(r(1) - b' * r(2 : M));
    envolvente = abs(freqz(G, [1; -b], tamanio_ventana, 'whole'));
    
    plot(frecuencias, envolvente);
end

axis([0, fs/2, 0, 20]);

title('Envolventes De Vocales.');
legend('a', 'a', 'i', 'a');
xlabel('Frecuencia (Hz)');
ylabel('Amplitud');
