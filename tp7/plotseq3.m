function [hy,h] = plotseq3(x, gammas, iter)

T = length(x);

hold on;

set(gca, 'color', 'w');

plot(x(:,1), x(:,2), 'color', [0, 0, 0.2]);

for t = 1:T
    gammas = gammas + abs(min(min(gammas)));
    gammas = gammas / max(max(gammas));
    color = [gammas(2, t), gammas(3, t), gammas(4, t)];
    plot(x(t, 1), x(t, 2), 'color', [0.5, 0.5, 0.5], 'marker','o','markerface', color, 'markerSize', 5, ...
      'linestyle','none');
end

title(sprintf('EM Iteración %d', iter));
