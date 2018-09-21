close all;
clear;

t = [0:pi/100:2*pi];
x = sin(t);

figure(1);
hold on;

plot(t,x);
plot(t,truncar(x,3));

title('Redondeo De Una Senoidal A 3 Bits.');
legend('Original', 'Redondeada');
xlabel('Argumento (rad)');
ylabel('Amplitud');

axis([0, 2*pi, -1, 1]);