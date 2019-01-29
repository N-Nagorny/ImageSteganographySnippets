% The script embeds a monochrome image into a color container.

clear all;

[empty_cont_name] = uigetfile(...
    {'*.*', 'All Files (*.*)'}, ...
    'Select an empty container');
empty_cont = imread(empty_cont_name);

dct_empty_cont = dct2(empty_cont(:, :, 3));
cont_height = size(dct_empty_cont, 1);
Nc = (cont_height.^2)/64;
seg(:, :, 1) = dct_empty_cont(1:8, 1:8);
seg(:, :, Nc) = dct_empty_cont(cont_height - 7:cont_height, cont_height -7:cont_height);
for b = 2:(Nc - 1)
    if rem(b, sqrt(Nc)) == 0
        seg(:, :, b) = dct_empty_cont(cont_height - 7:cont_height, 8*(ceil(b/sqrt(Nc)) - 1) + 1:8*(ceil(b/sqrt(Nc)) - 1) + 8);
    else
        seg(:, :, b) = dct_empty_cont(8 * (b - sqrt(Nc) * floor(b / sqrt(Nc)) - 1) + ...
            1:8 * (b - sqrt(Nc) * floor(b / sqrt(Nc)) - 1) + ...
            8, 8 * (ceil(b /sqrt(Nc)) - 1) + 1:8 * (ceil(b / sqrt(Nc)) - 1) + 8);
    end
end

P = 100;

[wmark_name] = uigetfile(...
    {'*.*', 'All Files (*.*)'}, ...
    'Select a watermark');
wmark = imread(wmark_name);

dwm = wmark(:, :, 1)/255;

enc = seg;
c = 1;
xys = zeros(size(dwm,2),4);
for ii = 1:size(dwm,1)
    for jj = 1:size(dwm,2)
        y = rand;
        z = rand;
        if (round(y) == 1)
            u1 = round(z*7)+1;
            v1 = 9 - u1;
        else
            u1 = round(z*6)+2;
            v1 = 10 - u1;
        end
            u2 = u1;
            while (u2 == u1)
                y = rand;
                z = rand;
                if (round(y) == 1)
                    u2 = round(z*7)+1;
                    v2 = 9 -u2;
                else
                    u2 = round(z*6)+2;
                    v2 = 10-u2;
                end
            end
            xys(c,1) = u1;
            xys(c,2) = v1;
            xys(c,3) = u2;
            xys(c,4) = v2;
            if dwm(ii, jj) == 1
                while(abs(enc(u1,v1,c))-abs(enc(u2,v2,c)) >= -P)
                    if (enc(u1,v1,c)>0 && enc(u2,v2,c)  > 0) || (enc(u1,v1,c)<0 && enc(u2,v2,c)<0)
                        enc(u1,v1,c) = enc(u1,v1,c) - 1;
                        enc(u2, v2,c)=enc(u2,v2,c) + 1;
                    elseif enc(u1, v1, c) < 0
                        enc(u1, v1,c) = enc(u1,v1,c)+1;
                        enc(u2,v2,c) = enc(u2,v2,c)+1;
                    elseif enc(u2,v2,c)<0
                        enc(u1,v1,c) = enc(u1,v1,c) -1;
                        enc(u2,v2,c) = enc(u2, v2,c) - 1;
                    end
                end
                c = c+1;
            else
                while(abs(enc(u1,v1,c)) - abs(enc(u2,v2,c)) <= P)
                    if (enc(u1,v1,c) > 0 && enc(u2,v2,c) > 0) || (enc(u1,v1,c) <0 && enc(u2,v2,c) < 0)
                        enc(u1,v1,c) = enc(u1,v1,c) + 1;
                        enc(u2,v2,c) = enc(u2,v2,c) - 1;
                    elseif enc(u1,v1,c) < 0
                        enc(u1, v1,c) = enc(u1, v1,c) -1;
                        enc(u2,v2,c) = enc(u2,v2,c) -1;
                    elseif enc(u2,v2,c) < 0
                        enc(u1,v1,c) = enc(u1,v1,c) +1;
                        enc(u2,v2,c) = enc(u2,v2,c) +1;
                    end
                end
                c = c+1;
            end
        end
end


N = size(enc,1);
one = enc(:,:,1);
for kk = 2:(1024/N)
    one = [one; enc(:, :, kk)];
end
for ii = (1024/N)+1:(1024/N):size(enc,3)
    column = enc(:, :, ii);
    for jj = ii + 1:ii + (1024/N - 1)
        column = [column; enc(:, :, jj)];
    end
    one = [one column];
end

blue = idct2(one);
empty_cont(:, :, 3) = blue;
filled_cont_name = uiputfile('', 'Select a PNG file for the filled container');
imwrite(empty_cont, filled_cont_name, 'png');
dlmwrite('xys.csv', xys, 'precision', 6);

C = (double(empty_cont(:, :, 3)) - round(blue)).^2;
MSE = 1/(size(empty_cont, 1) * size(empty_cont, 2)) * sum(sum(C))
NMSE = sum(sum(C)) / sum(sum(double(empty_cont(:, :, 3))^2))
SNR = 1 / NMSE
PSNR = size(empty_cont, 1) * size(empty_cont, 2) * max(max(double(empty_cont(:, :, 3))^2)) / sum(sum(C))