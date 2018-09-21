close all;
clear

fs = 16000;
T = 1 / fs;

sigmas = [60, 100, 120, 175, 250];
fk = [660, 1720, 2410, 3500, 4500];

f0 = 125;

gamma = 0.96;

duracion_en_segundos = 1;

puntos_fft = 200000;

% Genero tren de pulsos.

pulso = zeros(duracion_en_segundos / T, 1);
posicion_de_la_delta = 1;
while posicion_de_la_delta < length(pulso)
    pulso(posicion_de_la_delta) = 1;
    posicion_de_la_delta = posicion_de_la_delta + fs / f0;
end

% Tracto Vocal

sintesis = pulso;
filtro = ones(puntos_fft, 1);
for k = 1:5
    coeficiente1 = 1;
    coeficiente2 = -2 * exp(-2 * pi * sigmas(k) * T) * cos(2 * pi * fk(k) * T);
    coeficiente3 = exp(-4 * pi * sigmas(k) * T);
    coeficientes = [coeficiente1, coeficiente2, coeficiente3];
    sintesis = filter(1, coeficientes, sintesis);
    filtro = filtro .* freqz(1, coeficientes, puntos_fft, 'whole');
end

% Radiacion Labial

sintesis = filter([1, -gamma], 1, sintesis);
[respuesta, frecuencias] = freqz([1, -gamma], 1, puntos_fft, 'whole');
filtro = filtro .* respuesta;
frecuencias = frecuencias * fs / 2 / pi ;

% Cepstrum
numero_de_coeficientes = 50;
cepstrum = ifft(log(abs(fft(sintesis, puntos_fft)) + 1));

% Liftering
cepstrum(numero_de_coeficientes + 1 : (length(cepstrum) - numero_de_coeficientes)) = 0;

% Grafico
figure(1);
hold on;
plot(frecuencias, exp(abs(fft(cepstrum, puntos_fft))) - 1);
plot(frecuencias, abs(filtro));
legend('Envolvente Con Cepstrum', 'Filtro');
axis([0, fs/2, 0, 60]);

%sound(sintesis, fs);

