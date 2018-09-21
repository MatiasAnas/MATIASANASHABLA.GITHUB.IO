function [alphas, betas, gammas, xis, logProbAlpha, logProbBeta] = logalphabeta(x,means,vars,transitions)

if nargin == 2,
  model = means;
  means = model.means;
  vars = model.vars;
  model.trans(model.trans<1e-100) = 1e-100;
  logTrans = log(model.trans);
end;

numStates = length(means);
nMinOne = numStates - 1;
[numPts,dim] = size(x);

log2pi = log(2*pi);
for i=2:nMinOne,
  invSig{i} = inv(vars{i});
  logDetVars2(i) = - 0.5 * log(det(vars{i})) - log2pi;
end;

% Initialize the alpha vector for the emitting states
for i=2:nMinOne,
  X = x(1,:)-means{i}';
  alpha(i) = logTrans(1,i) ...
      - 0.5 * (X * invSig{i}) * X' + logDetVars2(i);
end;
alpha = alpha(:);

alphas = zeros(length(alpha),numPts);
alphas(:, 1) = alpha(:);

% Do the forward recursion
for t = 2:numPts
  alphaBefore = alpha;
  for i = 2:nMinOne
    X = x(t,:)-means{i}';
    alpha(i) = logsum( alphaBefore(2:nMinOne) + logTrans(2:nMinOne,i) ) ...
        - 0.5 * (X * invSig{i}) * X' + logDetVars2(i);
  end;
  alphas(:, t) = alpha(:);
end;

% Terminate the recursion with the final state
logProb =  logsum( alpha(2:nMinOne) + logTrans(2:nMinOne,numStates) );

logProbAlpha = logProb;

% Inicializo vector de betas.
beta = logTrans(1:nMinOne, end);

betas = zeros(length(beta),numPts);
betas(:, numPts) = beta(:);
%betas
% Recursion Backward
t = numPts - 1;
while(t >= 1)
    betaBefore = beta;
    for i = 2:nMinOne
        b = zeros(1, nMinOne);
        for j = 2:nMinOne
            X = x((t + 1),:) - means{j}';
            b(j) = - 0.5 * (X * invSig{j}) * X' + logDetVars2(j);
        end
        beta(i) = logsum(betaBefore(2:nMinOne)' + logTrans(i, 2:nMinOne) ...
            + b(2:nMinOne));
    end
    betas(:, t) =  beta(:);
    t = t - 1;
end

b = zeros(1, nMinOne);
for j = 2:nMinOne
	X = x(1,:) - means{j}';
	b(j) = - 0.5 * (X * invSig{j}) * X' + logDetVars2(j);
end

logProbBeta = logsum(b(2:nMinOne) + betas(2:nMinOne, 1)' + logTrans(1, 2:nMinOne));

[N, T] = size(alphas);
gammas = zeros(N, T);
for t = 1:T
	for k = 2:N
        gammas(k, t) = alphas(k, t) + betas(k, t) - ...
            logsum(alphas(2:N, t) + betas(2:N, t));
	end
end

xis = zeros(N, N, T);
for t = 2:T
    for j = 2:N
        for k = 2:N
            X = x(t, :) - means{k}';
            b = - 0.5 * (X * invSig{k}) * X' + logDetVars2(k);
            %xis(j, k, t) = alphas(j, t - 1) + b + logTrans(j, k) + ...
            %    betas(k, t) - logsum(gammas(2:N, t));
            xis(j, k, t) = alphas(j, t - 1) + b + logTrans(j, k) + ...
                betas(k, t) - logsum(alphas(2:N, t) + betas(2:N, t));
            
        end
    end
end

%=================================
function result = logsum(logv)

len = length(logv);
if (len<2);
  error('Subroutine logsum cannot sum less than 2 terms.');
end;

% First two terms
if (logv(2)<logv(1)),
  result = logv(1) + log( 1 + exp( logv(2)-logv(1) ) );
else,
  result = logv(2) + log( 1 + exp( logv(1)-logv(2) ) );
end;

% Remaining terms
for (i=3:len),
  term = logv(i);
  if (result<term),
    result = term   + log( 1 + exp( result-term ) );
  else,
    result = result + log( 1 + exp( term-result ) );
  end;    
end;
