% Inicializacion.
close all
clear
clc
colordef white

% Cargo Datos
load data;

% Parametros.
MINIMO_REALIZACIONES_DE_ESTADO = 15;
ITERACIONES_MAXIMAS = 10;
MAXIMO_NUMERO_DE_CONDICION = 5;

% Genero la realizacion del HMM, itero hasta obtener una con suficientes
% puntos en cada estado.
data_ok = 0;
while(data_ok  == 0)
    [X, Q] = genhmm(hmm4);
    states_1 = sum(Q(:) == 2);
    states_2 = sum(Q(:) == 3);
    states_3 = sum(Q(:) == 4);
    if((states_1 > MINIMO_REALIZACIONES_DE_ESTADO) ...
            && (states_2 > MINIMO_REALIZACIONES_DE_ESTADO) ...
            && (states_3 > MINIMO_REALIZACIONES_DE_ESTADO))
        data_ok = 1;
    end
end

% Calculo las medias, varianzas y matriz de transición iniciales.
mu_inicial = media(X);
sigma_inicial = sigma(X, mu_inicial);
mu_1 = mu_inicial;
mu_2 = mu_inicial;
mu_3 = mu_inicial;
sigma_1 = sigma_inicial;
sigma_2 = sigma_inicial;
sigma_3 = sigma_inicial;
A = [0,   1,   0,   0,   0; ...
     0, 0.5, 0.5,   0,   0; ...
     0,   0, 0.5, 0.5,   0; ...
     0,   0,   0, 0.5, 0.5; ...
     0,   0,   0,   0,   1];

% Iteracion EM.
 
likelihoods = zeros(1, ITERACIONES_MAXIMAS);
delta_likelihood = Inf;
iter = 1;

while((iter <= ITERACIONES_MAXIMAS) && (delta_likelihood > 0.01))
    % Calculo las matrices con las probabilidades alfa, beta, gamma y xi.
    mi_hmm.means = {[], mu_1', mu_2', mu_3', []};
    mi_hmm.vars  = {[], sigma_1, sigma_2, sigma_3, []};
    mi_hmm.trans = A;

    [alphas, betas, gammas, xis, logpa, logpb] = calcular_matrices(X, mi_hmm);

    % Recalculo parametros.
    T = length(X);
    mu_1 = estimador_mu(X, 2, exp(gammas));
    mu_2 = estimador_mu(X, 3, exp(gammas));
    mu_3 = estimador_mu(X, 4, exp(gammas));

    sigma_1_bis = estimador_sigma(X, mu_1, 2, exp(gammas));
    sigma_2_bis = estimador_sigma(X, mu_2, 3, exp(gammas));
    sigma_3_bis = estimador_sigma(X, mu_3, 4, exp(gammas));

    if(rcond(sigma_1_bis) < MAXIMO_NUMERO_DE_CONDICION)
        sigma_1 = sigma_1_bis;
    end
    if(rcond(sigma_2_bis) < MAXIMO_NUMERO_DE_CONDICION)
        sigma_2 = sigma_2_bis;
    end
    if(rcond(sigma_3_bis) < MAXIMO_NUMERO_DE_CONDICION)
        sigma_3 = sigma_3_bis;
    end
    
    A = estimador_transicion(exp(xis), T);
    
    %Figuras
    figure(iter)
    plotseq3(X, gammas, iter);
    plotgaus(mu_1, sigma_1, [1, 0, 0]);
    plotgaus(mu_2, sigma_2, [0, 1, 0]);
    plotgaus(mu_3, sigma_3, [0, 0, 1]);
    axis([0, 1000, 0, 3000]);
    
    % Calculo cuanto varió el likelihood, para saber si cortar.
    likelihoods(iter) = logpa;
    if(iter == 1)
        delta_likelihood = Inf;
    elseif(likelihoods(iter) < likelihoods(iter - 1))
        delta_likelihood = Inf;
    else
        delta_likelihood = likelihoods(iter) - likelihoods(iter - 1);
    end
    
    iter = iter + 1;
end

% Figura de evolución del likelihood.
figure(iter);
plot(likelihoods);
xlabel('Iteración')
ylabel('LogLikelihood')
title('Evolución De El LogLikelihood');