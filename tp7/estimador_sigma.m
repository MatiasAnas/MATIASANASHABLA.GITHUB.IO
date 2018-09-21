function sigma = estimador_sigma(x, mu, clase, gammas)
    T = length(x);
    sigma = zeros(2, 2);
    for t = 1:T
        sigma = sigma + (x(t, :) - mu)' * (x(t, :) - mu) * gammas(clase, t);
    end
    sigma = sigma / sum(gammas(clase,1:T));
end