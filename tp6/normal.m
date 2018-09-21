function valor = normal(x, mu, sigma)
    %d = length(x);
    %valor = (1 / (sqrt(2*pi)^d * sqrt(det(sigma)))) * exp((-1/2) * (x - mu) * inv(sigma) * (x - mu)'); 
    
    valor = mvnpdf(x, mu, sigma);
end