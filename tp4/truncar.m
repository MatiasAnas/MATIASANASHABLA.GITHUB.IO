function senial_truncada = truncar(senial, bits)

    minimo = min(senial);
    maximo = max(senial);
 
    %La hago toda positiva.
    senial = senial + abs(minimo);

    %La divido en 2^bits niveles.
    senial = round(senial * (2^bits - 1) / (maximo + abs(minimo)));
    
    %La vuelvo a pasar a punto flotante.
    senial = senial * (maximo + abs(minimo)) / (2^bits - 1);
    
    %Le saco el nivel de continua.
    senial_truncada = senial - abs(minimo);
end