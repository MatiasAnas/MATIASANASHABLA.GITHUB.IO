close all;
clear

puntos_fft = 50000;

tiempo_ventana = 0.025;
tiempo_avance_ventana = 0.010;

archivo = 'fantasia.wav';

numero_de_coeficientes = 50;

%Cargo el archivo.
[audio, fs] = audioread(archivo);

tamanio_ventana = tiempo_ventana * fs;
avance_ventana = tiempo_avance_ventana * fs;

%Recorto las partes vacias.
inicio_de_audio = 9000;
fin_de_audio = 25000;
audio = audio(inicio_de_audio : fin_de_audio);


posicion_ventana = 1;
i = 1;
envolvente = zeros(ceil(length(audio) / avance_ventana), puntos_fft);

%Obtengo coeficientes LPC para cada ventana.
while (posicion_ventana + tamanio_ventana < length(audio))
    audio_ventaneado = audio(posicion_ventana : (posicion_ventana + tamanio_ventana - 1));
    
    %Cepstrum
    cepstrum = ifft(log(abs(fft(audio_ventaneado, puntos_fft)) + 1));
    
    %Liftering
    cepstrum(numero_de_coeficientes + 1 : (length(cepstrum) - numero_de_coeficientes)) = 0;
    
    envolvente(i,:) = abs(fft(cepstrum, puntos_fft));
    
    i = i + 1;
    posicion_ventana = posicion_ventana + avance_ventana;
end

%Grafico de envolventes.
figure(1);
[a,b] = size(envolvente);
tiempos = linspace(0, length(audio) / fs, a);
frecuencias = linspace(0, fs*((tamanio_ventana-1)/tamanio_ventana), b);
s  = surf(frecuencias, tiempos, envolvente);
s.EdgeColor = 'none';
view(2);
axis([0, fs / 2, 0, length(audio) / fs])

title('Envolventes.');
xlabel('Frecuencia (Hz)');
ylabel('Tiempo (s)');

