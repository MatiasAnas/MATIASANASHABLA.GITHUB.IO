function mu = estimador_mu(x, clase, gammas)
    T = length(x);
    mu = zeros(1,2);
    for t = 1:T
        mu = mu + x(t, :) * gammas(clase, t);
    end
    mu = mu / sum(gammas(clase,1:T));
end