clc
clearvars
warning off

%% Data analysis

%%Steel Plates Dataset
data = readtable("Data\Sources\stell-faults.csv");
data = removevars(data);
Y = table2array(data(1:739, 28:30));
X = table2array(data(1:739, 1:27));

%%Iris Dataset
%...

%%Validation
runs = 10;
[order_index,order_table] = orderAnalysis(X,Y,runs);
figure (1)
plot(1:size(X,2),order_index(:,3));
grid on
[mce_ord,idOrd] = max(order_index(:,3));

%cv_list = plsOrder(X,Y);
%[mce_ord,ord] = max(cv_list);
%figure(1)
%plot(1:size(X,2),cv_list)
%grid on 
%[ord,idOrd] = max(cv_list);

%%Prediction 
B2 = pls(X, Y, order_index(idOrd,1), false); %idOrd se si vuole usare la parte posta sotto commento
Y_hat = normalize(X)*B2;

%%Y_hat transformation
Y_hat_bin = performClassification(Y_hat);
mce = performMCE(Y_hat_bin,Y);

%%Plot Classes
figure(2)
scatter3(Y_hat(1:158,1), Y_hat(1:158,2), Y_hat(1:158,3), 'magenta')
hold on
scatter3(Y_hat(159:348,1), Y_hat(159:348,2), Y_hat(159:348,3), 'yellow')
hold on
scatter3(Y_hat(349:end,1), Y_hat(349:end,2), Y_hat(349:end,3), 'green')
grid on


%%
function [order_index,order_table] = orderAnalysis(X,Y,runs)
    order_table = zeros(runs,2);
    for index = 1:runs
        cv_list = plsOrder(X,Y);
        [mce_ord,ord] = max(cv_list);
        order_table(index,:) = [mce_ord,ord];
    end

    order_index = zeros(size(X,2),3);
    for idx = 1 : size(X,2)
        acc = 0;
        count = 0;
        for idx1 = 1: runs
           if order_table(idx1,2) == idx
               count = count +1;
               acc = acc + order_table(idx1,1);
           end
        end
        if count ~= 0
            order_index(idx,:) = [idx, count, acc/count];
        else
            order_index(idx,:) = [idx, count, 0];
        end
    end
end

function cv_list = plsOrder(X,Y)
    cv_list = zeros(size(X,2),1);
    for id_ord = 1:size(X,2)
        cv_list(id_ord,1) = mean(crossPLS(X,Y,id_ord));
    end
end

function mce = performMCE(Y_hat,Y)
    cont = 0;
    for i = 1: size(Y, 1)
        [~, j] = max(Y(i, :));
        [~, k] = max(Y_hat(i, :));
        if j ~= k
            cont = cont + 1;
        end
    end
    mce = 1 - cont/size(Y, 1); % togliendo il -1 il grafico cresce al crescere dell'ordine
end                        % questo però comporta che però con il metodo di cross-validazione facendone più run
                           % l'ordine scelto rimanga sempre 27

function Y_hat_bin = performClassification(Y_hat)
    for i = 1:size(Y_hat, 1)
        [~, j] = max(Y_hat(i, :));
        for k = 1:3
            if k == j
                Y_hat_bin(i, k) = 1;
            else
                Y_hat_bin(i, k) = 0;
            end
        end
    end
end

function CV_error = crossPLS(X,Y,initord)
    kfold = 10;
    idx = randsample(size(X,1),size(X,1),false);
    X = X(idx,:);
    Y = Y(idx,:);

    step = round(size(X,1)/kfold);
    startk = 1;
    CV_error = zeros(kfold,1);
    for index = 1 : kfold
        if index < kfold
            idx = startk:(startk + step-1);
            startk = startk + step;
        else
            idx = startk:size(X,1);

        end
        X_test = X(idx,:);
        Y_test = Y(idx,:);
        
        X_train = X(setdiff(1:size(X,1),idx),:);
        Y_train = Y(setdiff(1:size(Y,1),idx),:);

        B2_cross = pls(X_train,Y_train,initord,false);
        Y_cross_hat = performClassification(normalize(X_test)*B2_cross);
        CV_error(index) = performMCE(Y_cross_hat, Y_test);
    end
end

function B = pls(X, Y, alphaRed, mod2, stand, maxIter, tol)
    
    function B1 = pls1(X, Y, alphaRed, maxIter, tol)
        nY = size(Y, 1);
        pY = size(Y, 2);
        mX = size(X, 2);
        maxRank = alphaRed;
        for i = 1 : pY
            f = Y(:, 1);
            y = Y(:, i);
            W = zeros(mX, maxRank);
            P = zeros(mX, maxRank);
            T = zeros(nY, 1);
            E = X;
            for j = 1 : maxRank
                tOld = 0;
                for k = 1 : maxIter
                    w = (E'*y)/norm(E'*y);
                    t = E*w;
                    p = (E'*t)/(t'*t);
                    if abs(tOld - t) < tol
                        break;
                    else
                        tOld = t;
                    end
                end
                
                % scaling
                t = t*norm(p);
                w = w*norm(p);
                p = p/norm(p);
                
                b = (y'*t)/(t'*t);
                E = E - t*p';
                f = f - b*t*1;

                W(:, j) = w;
                P(:, j) = p;
                T(:, j) = t;
            end
            B1(:, i) = W*(P'*W)^-1*(T'*T)^-1*T'*y;
        end
    end
   
    function B2 = pls2(X, Y, alphaRed, maxIter, tol)
        nY = size(Y, 1);
        pY = size(Y, 2);
        mX = size(X, 2);
        maxRank = alphaRed;
        E = X; % residual matrix for X
        F = Y; % residual matrix for Y

        [~, idx] = max(sum(Y.*Y));

        for j = 1 : maxRank
            u = F(:, idx);
            tOld = 0;
            for i = 1 : maxIter
                w = (E'*u)/norm(E'*u); % support vector
                t = E*w; % j-th column of the score matrix for X
                q = (F'*t)/norm(F'*t); % j-th column of the loading matrix for Y
                u = F*q; % j-th column of the score matrix for Y
                if abs(tOld - t) < tol
                    break;
                else 
                    tOld = t;
                end
            end
            p = (E'*t)/(t'*t); % j-th column of the loading matrix of X
            
            % scaling
            t = t*norm(p);
            w = w*norm(p);
            p = p/norm(p);
            
            b = (u'*t)/(t'*t); % j-th column of the coefficient regression matrix
            E = E - t*p';
            F = F - b*t*q';

            W(:, j) = w;
            P(:, j) = p;
            T(:, j) = t;

            B2 = W*(P'*W)^-1*(T'*T)^-1*T'*Y;
        end
    end

    switch nargin
        case 2
            alphaRed = max(size(Y, 1), size(X, 2));
            mod2 = true;
            stand = true;
            maxIter = 10000;
            tol = 1e-0;
        case 3
            mod2 = true;
            stand = true;
            maxIter = 10000;
            tol = 1e-9;
        case 4
            stand = true;
            maxIter = 10000;
            tol = 1e-9;
        case 5
            maxIter = 10000;
            tol = 1e-9;
        case 6
            tol = 1e-9;
    end
    
    % data standardization
    if stand
        X = normalize(X);
        Y = normalize(Y);
    end
    
    disp("PLS configuration: ")
    disp("- PLS2: " + mod2);
    disp("- Normalization: " + stand);
    disp("- Maximum iterations: " + maxIter);
    disp("- Tolerance: " + tol);

    if mod2
        B = pls2(X, Y, alphaRed, maxIter, tol);
    else
        B = pls1(X, Y, alphaRed, maxIter, tol);
    end
end