% Inicializacion.
close all
clear
clc
colordef white

% Cargo Datos.
load data;

% ----------------------------------------------------------------

% -----------------------
% Construyo matriz total.
% -----------------------
A = hmm4.trans;
B = hmm6.trans;

C = zeros(8, 8);

% Probabilidades de arrancar con una o con otra.
C(1, 2) = 0.5;
C(1, 5) = 0.5;

% Inserto la matriz de HMM4.
C(2:4, 2:4) = A(2:4, 2:4);

% Probabilidades de reiniciar en una o la otra, o terminar.
C(4, 2) = A(4, 5) / 3;
C(4, 5) = A(4, 5) / 3;
C(4, 8) = A(4, 5) / 3;

% Inserto la matriz de HMM6.
C(5:7, 5:7) = B(2:4, 2:4);

% Probabilidades de reiniciar en una o la otra, o terminar.
C(7, 2) = B(4, 5) / 3;
C(7, 5) = B(4, 5) / 3;
C(7, 8) = B(4, 5) / 3;

% Estado Final.
C(8, 8) = 1;

% -------
% Medias.
% -------
medias = {[], hmm4.means{2}, hmm4.means{3}, hmm4.means{4}, ...
    hmm6.means{2}, hmm6.means{3}, hmm6.means{4}, []};

% ----------
% Varianzas.
% ----------
varianzas = {[], hmm4.vars{2}, hmm4.vars{3}, hmm4.vars{4}, ...
    hmm6.vars{2}, hmm6.vars{3}, hmm6.vars{4}, []};

% ----------------------------------------------------------------

% Construyo el nuevo modelo.
hmm_total.means = medias;
hmm_total.vars = varianzas;
hmm_total.trans = C;

% ----------------------------------------------------------------

% Genero Secuencia.
[x, q] = genhmm(hmm_total);
[alfas, betas, gamas, xis, proba, p] = calcular_matrices(x, hmm_total);

% Viterbi
[q_opt, proba_opt] = logvit(x, hmm_total);

fprintf('Probabilidad (Log): %f\n', proba);
fprintf('Probabilidad Secuencia Optima (Log): %f\n', proba_opt);

% ----------------------------------------------------------------

% Detector De Tipo De Secuencia.
secuencia_hmm = [];
i = 1;

% Se resuelve con una maquina de estados.
IDLE = 0;
MODELO_4 = 4;
MODELO_6 = 6;

while(q_opt(i) ~= 8)
    switch(q_opt(i))
        case 1
            state = IDLE;
        case 2
            if(state == IDLE)
                state = MODELO_4;
                secuencia_hmm = [secuencia_hmm, MODELO_4];
            elseif(state == MODELO_4)
                state = MODELO_4;
            elseif(state == MODELO_6)
                state = MODELO_4;
                secuencia_hmm = [secuencia_hmm, MODELO_4];
            end
        case 4
            state = IDLE;
        case 5
            if(state == IDLE)
                state = MODELO_6;
                secuencia_hmm = [secuencia_hmm, MODELO_6];
            elseif(state == MODELO_4)
                state = MODELO_6;
                secuencia_hmm = [secuencia_hmm, MODELO_6];
            elseif(state == MODELO_6)
                state = MODELO_6;
            end 
        case 7
            state = IDLE;
    end
    i = i + 1;
end

% Resultado.
fprintf('La secuencia fue:');
secuencia_hmm