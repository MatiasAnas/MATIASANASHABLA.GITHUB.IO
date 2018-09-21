close all;
clear;

N = 40;
M = 10;
d = 2;

datos.a = importdata('a.txt');
datos.o = importdata('o.txt');
datos.u = importdata('u.txt');

formantes.a.train = datos.a( 1:40,1:2);
formantes.a.test  = datos.a(41:50,1:2);
formantes.o.train = datos.o( 1:40,1:2);
formantes.o.test  = datos.o(41:50,1:2);
formantes.u.train = datos.u( 1:40,1:2);
formantes.u.test  = datos.u(41:50,1:2);

figure(1);
hold on;
plot(formantes.a.train(:,1),formantes.a.train(:,2),'bo');
plot(formantes.o.train(:,1),formantes.o.train(:,2),'ro');
plot(formantes.u.train(:,1),formantes.u.train(:,2),'go');

mu_a = media(formantes.a.train);
mu_o = media(formantes.o.train);
mu_u = media(formantes.u.train);

sigma_a = sigma(formantes.a.train, mu_a);
sigma_o = sigma(formantes.o.train, mu_o);
sigma_u = sigma(formantes.u.train, mu_u);

sigma = (sigma_a + sigma_o + sigma_u) / 3;

% Elipses

t = 0:pi/50:2*pi;
y = [sin(t'),cos(t')];
x = y * chol(sigma);
x_a = x + mu_a;
x_o = x + mu_o;
x_u = x + mu_u;

plot(x_a(:,1), x_a(:,2), 'b');
plot(x_o(:,1), x_o(:,2), 'r');
plot(x_u(:,1), x_u(:,2), 'g');

% Clasificacion

a_bien = [];
a_mal  = [];
o_bien = [];
o_mal  = [];
u_bien = [];
u_mal  = [];

resultados.a = zeros(M, 1);
resultados.o = zeros(M, 1);
resultados.u = zeros(M, 1);

x0_a = mu_a * inv(sigma) * mu_a';
x0_o = mu_o * inv(sigma) * mu_o';
x0_u = mu_u * inv(sigma) * mu_u';
v0_a = inv(sigma) * mu_a';
v0_o = inv(sigma) * mu_o';
v0_u = inv(sigma) * mu_u';

for i = 1:length(formantes.a.test)
    g_a = -(1/2) * x0_a + v0_a' * formantes.a.test(i,:)' + log(1/3);
    g_o = -(1/2) * x0_o + v0_o' * formantes.a.test(i,:)' + log(1/3); 
    g_u = -(1/2) * x0_u + v0_u' * formantes.a.test(i,:)' + log(1/3); 
    if((g_a > g_o) && (g_a > g_u))
        resultados.a(i) = 1;
        a_bien = [a_bien; formantes.a.test(i,:)];
    else
        a_mal = [a_mal; formantes.a.test(i,:)];
    end
end

for i = 1:length(formantes.o.test)
    g_a = -(1/2) * x0_a + v0_a' * formantes.o.test(i,:)' + log(1/3);
    g_o = -(1/2) * x0_o + v0_o' * formantes.o.test(i,:)' + log(1/3); 
    g_u = -(1/2) * x0_u + v0_u' * formantes.o.test(i,:)' + log(1/3); 
    if((g_o > g_a) && (g_o > g_u))
        resultados.o(i) = 1;
        o_bien = [o_bien; formantes.o.test(i,:)];
    else
        o_mal = [o_mal; formantes.o.test(i,:)];
    end
end

for i = 1:length(formantes.u.test)
    g_a = -(1/2) * x0_a + v0_a' * formantes.u.test(i,:)' + log(1/3);
    g_o = -(1/2) * x0_o + v0_o' * formantes.u.test(i,:)' + log(1/3); 
    g_u = -(1/2) * x0_u + v0_u' * formantes.u.test(i,:)' + log(1/3); 
    if((g_u > g_a) && (g_u > g_o))
        resultados.u(i) = 1;
        u_bien = [u_bien; formantes.u.test(i,:)];
    else
        u_mal = [u_mal; formantes.u.test(i,:)];
    end
end

% Grafico

plot(a_bien(:,1), a_bien(:,2), 'b*');
plot(a_mal(:,1),  a_mal(:,2),  'bx');
plot(o_bien(:,1), o_bien(:,2), 'r*');
%plot(o_mal(:,1),  o_mal(:,2),  'rx');
plot(u_bien(:,1), u_bien(:,2), 'g*');
plot(u_mal(:,1),  u_mal(:,2),  'gx');

legend('a de entrenamiento','o de entrenamiento','u de entrenamiento', ...
    'Curva de nivel de a', 'Curva de nivel de o', 'Curva de nivel de u', ...
    'a de test bien clasificados', 'a de test mal clasificados', ...
    'o de test bien clasificados', ...
    'u de test bien clasificados', 'u de test mal clasificados');

resultados = [resultados.a; resultados.o; resultados.u];
ErrorRatio = 100 - mean(resultados) * 100