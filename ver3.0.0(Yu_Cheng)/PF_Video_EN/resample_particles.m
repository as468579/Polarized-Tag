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
% I[i]�O��i���H���I���b�ĴX��particle��cummulated array index
% ~[i]�O��i��accumulated particle probability�ֿn�F�X���H���I[�H���I���֥[]
[~, I] = histc(T, R);

% + 1 means ��ceiling�A�]���q�`���v���|��n���󰮸�particle��accumultaed probability
% �]���Y��b100.05 histc�|�p���bparticle 100�A�����O�]��particle101��likehood�ܰ�
% �ҥH���ӭn��ceiling�~��
X = X(:, I + 1);
