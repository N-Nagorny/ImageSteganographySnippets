% The script embeds a monochrome image into a container.

clear all;
close all;

[empty_cont_name] = uigetfile(...
    {'*.*', 'All Files (*.*)'}, ...
    'Select an empty container');
empty_cont = imread(empty_cont_name);
empty_cont_size = size(empty_cont);

empty_cont_R = empty_cont(:, :, 1);
empty_cont_G = empty_cont(:, :, 2);
empty_cont_B = empty_cont(:, :, 3);

N = 8;
Ns = empty_cont_size(1) * empty_cont_size(2) / (N * N);

[wmark_name] = uigetfile(...
    {'*.*', 'All Files (*.*)'}, ...
    'Select a watermark');
wmark = imread(wmark_name);

for i = 1:10
    wmark_size = size(wmark);
    if (Ns / 8 < wmark_size(1)*wmark_size(2))
        [wmark_name] = uigetfile(...
            {'*.*', 'All Files (*.*)'}, ...
            'Select a smaller watermark');
        wmark = imread(wmark_name);
    end
end

wmark_size = size(wmark);

if (Ns / 8 < wmark_size(1)*wmark_size(2))
    fprintf('The embedding was not completed.');
    return;
end;

wmark_R = wmark(:, :, 1);

c1 = 1;
c2 = N;
S = cell(1, Ns);
for b = 1:Ns
    r1 = mod(N * (b - 1) + 1, empty_cont_size(1));
    r2 = r1 + N - 1;
    S{b} = empty_cont_B(r1:r2, c1:c2);
    if r2 == empty_cont_size(1)
        c1 = c1 + N;
        c2 = c2 + N;
    end
end

p = 1;
BW = uint8(zeros(1, size(wmark_R, 1) * size(wmark_R, 2)));
for i = 1:size(wmark_R, 1)
    for j = 1:size(wmark_R, 2)
        BW(p) = wmark_R(i, j);
        p = p + 1;
    end
end
for i = 1:size(BW, 2)
    if BW(i) > 127
        BW(i) = 255;
    else
        BW(i) = 0;
    end
end

MVec_bin = uint8(zeros(1, size(BW, 2) * 8));
p = 1;
for i = 1:size(BW, 2)
    if BW(i) == 255
        tempB = [1 1 1 1 1 1 1 1]; %d2b(255);
    else
        tempB = [0 0 0 0 0 0 0 0]; %d2b(0);
    end
    for j = 1:8
        MVec_bin(p) = tempB(j);
        p = p + 1;
    end
end

Lm = size(MVec_bin, 2);

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

E = 15;
allInsert = cell(1, Lm);
for s = 1:Lm
    b = MVec_bin(s);
    Block = S{s};
    Z = allZones{s};
    M = allMasks{s};
    n = ones(2, 2);
    El = uint32(zeros(2,2));
    for i = 1:N
        for j = 1:N
            if (Z(i, j) == 1) && (M(i, j) == 'A')
                n(1, 1) = n(1, 1) +1;
                El(1,1) = El(1,1) + uint32(Block(i,j));
            end
            if (Z(i, j) == 1) && (M(i, j) == 'Z')
                n(1, 2) = n(1, 2) +1;
                El(1,2) = El(1,2) + uint32(Block(i,j));
            end
            if (Z(i, j) == 2) && (M(i, j) == 'A')
                n(2, 1) = n(2, 1) +1;
                El(2, 1) = El(2,1) + uint32(Block(i,j));
            end
            if (Z(i, j) == 2) && (M(i, j) == 'Z')
                n(2, 2) = n(2, 2) +1;
                El(2, 2) = El(2,2) + uint32(Block(i,j));
            end
        end
    end
    l = zeros(2, 2);
    for i = 1:2
        for j = 1:2
            l(i, j) = double(El(i, j)) / n(i, j);
        end
    end
    L = zeros(1,2);
    l1 = cell(1,2);
    for x = 1:2
        L(x) = (l(x,1)*n(x,1) +l(x,2)*n(x,2)) / (n(x,1)+n(x,2));
        if b == 1
            l1{x} = [n(x,1) n(x,2); 1 -1] \ [L(x)*(n(x,1)+n(x,2)); E];
        end
        if b == 0
            l1{x} = [n(x,1) n(x,2); -1 1] \ [L(x)*(n(x,1)+n(x,2)); E];
        end
    end
    l1 = transpose([l1{1}(1) l1{2}(1); l1{1}(2) l1{2}(2)]);
    allInsert{s} = l1 -1;
end


SM = cell(1, Ns);
for s = 1:Ns
    Block = S{s};
    Block1 = double(Block);
    if s <= Lm
        ins = allInsert{s};
        Z = allZones{s};
        M = allMasks{s};
        for i = 1:N
            for j = 1:N
                if (Z(i, j) == 1) && (M(i, j) == 'A')
                    Block1(i, j) = double(Block(i, j)) + ins(1, 1);
                end
                if (Z(i, j) == 1) && (M(i, j) == 'Z')
                    Block1(i, j) = double(Block(i, j)) + ins(1, 2);
                end
                if (Z(i, j) == 2) && (M(i, j) == 'A')
                    Block1(i, j) = double(Block(i, j)) + ins(2, 1);
                end
                if (Z(i, j) == 2) && (M(i, j) == 'Z')
                    Block1(i, j) = double(Block(i, j)) + ins(2, 2);
                end
            end
        end
    end
    SM{s} = Block1;
end

BM = SM{1};
for b = 2:empty_cont_size(1)/N
    BM = vertcat(BM, SM{b});
end
BM1 = 0;
for b = empty_cont_size(1)/N+1:Ns
    if BM1 == 0
        BM1 = SM{b};
    else
        BM1 = vertcat(BM1, SM{b});
    end
    if mod(b, empty_cont_size(1)/N) == 0
        BM = horzcat(BM, BM1);
        BM1 = 0;
    end
end
BMmin = min(BM(:));
BMmax = max(BM(:));
BMnorm = uint8(zeros(empty_cont_size(1), empty_cont_size(2)));
for x = 1:empty_cont_size(1)
    for y = 1:empty_cont_size(2)
        %if ((ceil(x/N) - 1) * empty_cont_size(2) / N + ceil(y/N) < Lm)
        %if (x < 512)
            BMnorm(x, y) = round((BM(x, y) + abs(BMmin)) / (BMmax + abs(BMmin))*255);
        %else
        %    BMnorm(x, y) = empty_cont_B(x, y);
        %end
    end
end
BMnorm(:, 513:1024) = empty_cont_B(:, 513:1024);
filled_cont = empty_cont_R;
filled_cont(:,:,2) = empty_cont_G;
filled_cont(:,:,3) = BMnorm;
filled_cont_name = uiputfile('', 'Select a PNG file for the filled container');
imwrite(filled_cont, filled_cont_name, 'png');
fprintf('Embedding was completed.\n')
% bin_wmark_size = int64(bin_wmark_size);
% dlmwrite('bin_wmark_size.csv', bin_wmark_size, 'precision', 6);
% dlmwrite('wmark_size.csv', wmark_size, 'precision', 6);
% coords_size = size(coords);
% dlmwrite('coords.csv', reshape(coords, [coords_size(2), coords_size(3)]));