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

%---- Transmisor ----

posicion_ventana = 1;
i = 1;
b_matriz = zeros(ceil(length(audio) / avance_ventana), M - 1);
error_total = [];
z = zeros(M - 1, 1);

while (posicion_ventana + tamanio_ventana < length(audio))
    %Hallo los coeficientes.
    audio_ventaneado = audio(posicion_ventana : (posicion_ventana + tamanio_ventana - 1));
    r = xcorr(audio_ventaneado);
    r = r(tamanio_ventana : (tamanio_ventana + M - 1));
    R = toeplitz(r(1: M - 1));
    b = R\r(2 : M);
    G = sqrt(r(1) - b' * r(2 : M));
    
    %Guardo los coeficientes.
    b_matriz(i,:) = b;
    
    %Guardo Error.
    [error, z] = filter([-1; b], 1, audio_ventaneado(1 : avance_ventana), z);
    error_total = [error_total; error];
    
    i = i + 1;
    posicion_ventana = posicion_ventana + avance_ventana;
end

%---- Receptor ----

% Debe reconstruir la señal a partir de b_matriz y error_total.
audios = [];

for bits = [16, 8, 6 ,4]
    
    posicion_ventana = 1;
    i = 1;
    z = zeros(M - 1, 1);
    audio_reconstruido_total = [];
    
    while (posicion_ventana + tamanio_ventana < length(error_total))
        error_ventaneado = truncar(error_total(posicion_ventana : (posicion_ventana + tamanio_ventana - 1)), bits);
        [audio_reconstruido, z] = filter(1, [-1; b_matriz(i,:)'], error_ventaneado(1:avance_ventana), z);

        audio_reconstruido_total = [audio_reconstruido_total; audio_reconstruido];

        i = i + 1;
        posicion_ventana = posicion_ventana + avance_ventana;
    end
    audios(bits,:) = audio_reconstruido_total;
end

%Genero Audios
audiowrite('reconstruida_16.wav', audios(16,:), fs);
audiowrite('reconstruida_8.wav',  audios(8, :), fs);
audiowrite('reconstruida_6.wav',  audios(6, :), fs);
audiowrite('reconstruida_4.wav',  audios(4, :), fs);

%Grafico Señales Reconstruidas
figure(1);
hold on;

tiempos = linspace(0, length(audio) / fs, length(audio));
plot(tiempos, audio);

tiempos = linspace(0, length(audios(16,:)) / fs, length(audios(16,:)));

plot(tiempos, audios(16,:));
plot(tiempos, audios(8, :));
plot(tiempos, audios(6, :));
plot(tiempos, audios(4, :));

axis([0.156, 0.174, -0.4, 0.4]);
title('Señales Reconstruidas.');
legend('16 Bits', '8 Bits', '6 Bits', '4 Bits');
xlabel('Tiempo (s)');
ylabel('Amplitud');

%Grafico Errores

figure(2)
hold on;

audio = audio(1:length(audios(16,:)));
audio = audio';

plot(tiempos, audio - audios(16,:));
plot(tiempos, audio - audios(8,:));
plot(tiempos, audio - audios(6,:));
plot(tiempos, audio - audios(4,:));

axis([0.156, 0.174, -0.05, 0.05]);
title('Errores.');
legend('16 Bits', '8 Bits', '6 Bits', '4 Bits');
xlabel('Tiempo (s)');
ylabel('Amplitud');