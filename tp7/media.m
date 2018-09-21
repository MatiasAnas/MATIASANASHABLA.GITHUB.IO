function resultado_media = media(x_n)
    [N, d] = size(x_n);
    suma = zeros(1, d);
    for i = 1:N
        suma = suma + x_n(i,:);
    end
    resultado_media = suma / N;
end