function A = estimador_transicion(xis, T)
    A = zeros(5, 5);
    for j = 2:4
        for k = 2:4
            A(j,k) = 0;
            for t = 2:T
                A(j,k) = A(j,k) + xis(j, k, t);
            end
            denominador = 0;
            for t = 2:T
                for k2 = 2:4
                    denominador = denominador + xis(j, k2, t);
                end
            end
            A(j, k) = A(j, k) / denominador;
        end
    end
    A(2,5) = 1 - A(2, 4) - A(2, 3) - A(2, 2);
    A(3,5) = 1 - A(3, 4) - A(3, 3) - A(3, 2);
    A(4,5) = 1 - A(4, 4) - A(4, 3) - A(4, 2);
    A(1,:) = [0, 1, 0, 0, 0];
    A(5,:) = [0, 0, 0, 0, 1];
end