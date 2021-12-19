function X = resample_particles(X, L_log)

% Calculating Cumulative Distribution

% L ,Q let L_log be probability , 2 means y-axis
L = exp(L_log - max(L_log));
Q = L / sum(L, 2);

% R is similar to integral graph, 2 means y axis
R = cumsum(Q, 2);

% Generating Random Numbers

N = size(X, 2);
T = rand(1, N);

% Resampling
% I[i]是第i個隨機點落在第幾個particle的cummulated array index
% ~[i]是第i個accumulated particle probability累積了幾個隨機點[隨機點不累加]
[~, I] = histc(T, R);

% + 1 means 取ceiling，因為通常機率不會剛好等於乾該particle的accumultaed probability
% 因此若位在100.05 histc會計算位在particle 100，但其實是因為particle101的likehood很高
% 所以應該要取ceiling才對
X = X(:, I + 1);
