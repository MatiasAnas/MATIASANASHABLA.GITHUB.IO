function resultado_sigma = sigma(x_n, mu)
    [N, d] = size(x_n);
    suma = zeros(d, d);
    for i = 1:N
        suma = suma + (x_n(i,:) - mu)' * (x_n(i,:) - mu);
    end
    resultado_sigma = suma / N;
end