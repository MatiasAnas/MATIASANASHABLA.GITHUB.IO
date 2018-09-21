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

posicion_ventana = 1;
i = 1;
z = zeros(M - 1, 1);
audio_reconstruido_total = [];

while (posicion_ventana + tamanio_ventana < length(error_total))
    %Tomo una ventana del error.
    error_ventaneado = error_total(posicion_ventana : (posicion_ventana + tamanio_ventana - 1));
    
    %Filtro Inverso
    [audio_reconstruido, z] = filter(1, [-1; b_matriz(i,:)'], error_ventaneado(1:avance_ventana), z);
    
    %Agrego al total.
    audio_reconstruido_total = [audio_reconstruido_total; audio_reconstruido];
    
    i = i + 1;
    posicion_ventana = posicion_ventana + avance_ventana;
end

%Genero Audio Reconstruido.
audiowrite('reconstruida.wav', audio_reconstruido_total, fs);

%Grafico Señal Original VS Reconstruida Para Una Parte.
figure(1);
hold on;

tiempos = linspace(0, length(audio) / fs, length(audio));
plot(tiempos, audio);
tiempos = linspace(0, length(audio_reconstruido_total) / fs, length(audio_reconstruido_total));
plot(tiempos, audio_reconstruido_total, '--');

title('Señal Original VS Reconstruida.');
legend('Original', 'Reconstruida');
xlabel('Tiempo (s)');
ylabel('Amplitud');
axis([0.156, 0.174, -0.4, 0.4]);