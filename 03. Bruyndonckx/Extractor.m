clear all;
close all;

[filled_cont_name] = uigetfile(...
    {'*.*', 'All Files (*.*)'}, ...
    'Select a filled container');

filled_cont = imread(filled_cont_name);
filled_cont_size = size(filled_cont);
filled_cont_R = filled_cont(:,:,1);
filled_cont_G = filled_cont(:,:,2);
filled_cont_B = filled_cont(:,:,3);

N = 8;
Ns = filled_cont_size(1) * filled_cont_size(2) / (N*N);
Lm = 8192;

c1 = 1;
c2 = N;
S = cell(1, Ns);
for b = 1:Ns
    r1 = mod(N * (b - 1) + 1, filled_cont_size (1));
    r2 = r1 + N - 1;
    S{b} = filled_cont_B(r1:r2, c1:c2);
    if r2 == filled_cont_size(1)
        c1 = c1 + N;
        c2 = c2 + N;
    end
end

allZones = cell(1, Lm);
for s = 1:Lm
    f = zeros(1, N*N);
    Block = S{s};
    p = 1;
    for i = 1:size(Block, 1)
        for j = 1:size(Block, 2)
            f(p) = Block(i, j);
            p = p + 1;
        end
    end
    F = sort(f);
    r = 10;
    Ksi = zeros(1, r);
    Phi = zeros(1, r);
    Ksi(1) = 1;
    Ksi(r) = N*N;
    for x = 2:r-1
        Ksi(x) = (x-1)*round(N*N/(r-1));
    end
    for x = 1:size(Ksi,2)
        Phi(x) = F(Ksi(x));
    end
    Smax = 0;
    alpha = 0;
    Spline = pchip(Ksi, Phi);
    deriv = fnder(Spline);
    for w = 1:N*N
        sp = ppval(deriv, w);
        if sp > Smax
            Smax = sp;
            alpha = w;
        end
    end
    if alpha == 0
        alpha = N*N/2;
    elseif(alpha == 1)
        alpha = 2;
    elseif(alpha == N*N)
        alpha = N*N - 1;
    end
    threshold = 6;
    Zone1 = zeros(N);
    if Smax < threshold
        for i = 1:N
            for j = 1:N
                Zone1(i, j) = mod(j + i, 2) +1;
            end
        end
    end
    if Smax > threshold
        for i = 1:N
            for j = 1:N
                if Block(i , j) <= F(alpha)
                    Zone1(i, j) = 1;
                end
                if Block(i , j) > F(alpha)
                    Zone1(i, j) = 2;
                end
            end
        end
    end
    allZones{s} = Zone1;
end

KO = 123;
allMasks = cell(1, Ns);
Mul = char(zeros(N*N, 1));
for i = 1:Ns
    for j = 1:N*N
        Mul(j,1) = 'Z';
    end
    for j = 1:(N*N)/2
        Mul(mod(i+j*KO, N*N) + 1, 1) = 'A';
    end
    tempMask = Mul(N-(N-1):N, 1);
    for j =2:N
        tempMask = horzcat(tempMask, Mul(j*N-(N-1):j*N, 1));
    end
    allMasks{i} = tempMask;
end

allN = cell(1, Lm);
for s = 1:Lm
    Z = allZones{s};
    M = allMasks{s};
    n = ones(2,2);
    for i = 1:N
        for j = 1:N
            if (Z(i, j) == 1) && (M(i, j) == 'A')
                n(1, 1) = n(1, 1) + 1;
            end
            if (Z(i, j) == 1) && (M(i, j) == 'Z')
                n(1, 2) = n(1, 2) + 1;
            end
            if (Z(i, j) == 2) && (M(i, j) == 'A')
                n(2, 1) = n(2, 1) + 1;
            end
            if (Z(i, j) == 2) && (M(i, j) == 'Z')
                n(2, 2) = n(2, 2) + 1;
            end
        end
    end
    allN{s} = n;
end

allL = cell(1, Lm);
for s = 1:Lm
    Block = double(S{s});
    Z = allZones{s};
    M = allMasks{s};
    n = allN{s};
    El = zeros(2, 2);
    for i = 1:N
        for j = 1:N
            if (Z(i, j) == 1) && (M(i, j) == 'A')
                El(1, 1) = El(1, 1) + Block(i, j);
            end
            if (Z(i, j) == 1) && (M(i, j) == 'Z')
                El(1, 2) = El(1, 2) + Block(i, j);
            end
            if (Z(i, j) == 2) && (M(i, j) == 'A')
                El(2, 1) = El(2, 1) + Block(i, j);
            end
            if (Z(i, j) == 2) && (M(i, j) == 'Z')
                El(2, 2) = El(2, 2) + Block(i, j);
            end
        end
    end
    l = zeros(2, 2);
    for i = 1:2
        for j = 1:2
            l(i, j) = El(i, j) / double(n(i, j));
        end
    end
    allL{s} = l;
end

allE = cell(1, Lm);
for s = 1:Lm
    for x = 1:2
        E(x) = allL{s}(x,1) - allL{s}(x, 2);
    end
    allE{s} = E;
end

e = 0.0000005;
M = zeros(1, Lm);
for s = 1:Lm
    E = allE{s};
    n = allN{s};
    if E(1) < e && E(2) < e
        M(s) = 0;
    end
    if E(1) > e && E(2) > e
        M(s) = 1;
    end
end

for i = 1:Lm / 8
    byte = uint8([
        M(8*i - 7)*128, ...
        M(8*i - 6)*64, ...
        M(8*i - 5)*32, ...
        M(8*i - 4)*16, ...
        M(8*i - 3)*8, ...
        M(8*i - 2)*4, ...
        M(8*i - 1)*2, ...
        M(8*i)*1]);
    Mvec(i) = sum(byte);
end
p = 1;
t = sqrt(size(Mvec, 2));
BW = uint8(zeros(t, t));
for i = 1:t
    for j = 1:t
        if Mvec(p) > 127
            BW(i, j) = 255;
        else
            BW(i, j) = 0;
        end
        p = p+1;
    end
end

resImg = BW;
resImg(:,:,2) = BW;
resImg(:,:,3) = BW;

figure(4);
imshow(resImg);
% imwrite(wmark, 'cvz.bmp');
title('The watermark');