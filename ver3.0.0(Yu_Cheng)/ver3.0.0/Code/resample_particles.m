function X = resample_particles(X, L_log)
    if size(X,1) == 10 || size(X,1) == 9
        % resample for each connected component
        num = unique(X(9,:));
        for i = 1 : size(num,2)
            Xpart = X(:,X(9,:) == num(i));
            Lpart = L_log(X(9,:)==num(i));
            
            % Calculating Cumulative Distribution
            L = exp(Lpart - max(Lpart));
            Q = L / sum(L, 2);
            R = cumsum(Q, 2);

            % Generating Random Numbers

            N = size(Xpart, 2);
            T = rand(1, N);

            % Resampling
            if(all(isnan(R)))
                X(:,X(9,:) == num(i)) = [];
                L_log(:,X(9,:) == num(i)) = [];
            else
                [~, I] = histc(T, R);
                X(:,X(9,:) == num(i)) = Xpart(:, I + 1);
            end

        end
    else
        % Calculating Cumulative Distribution
        L = exp(L_log - max(L_log));
        Q = L / sum(L, 2);
        R = cumsum(Q, 2);

        % Generating Random Numbers

        N = size(X, 2);
        T = rand(1, N);

        % Resampling

        [~, I] = histc(T, R);
        X = X(:, I + 1);
    end
    
end

