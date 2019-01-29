clear all;
close all;

[filled_cont_name] = uigetfile(...
    {'*.*', 'All Files (*.*)'}, ...
    'Select a filled container');

filled_cont = imread(filled_cont_name);
filled_cont_copy = filled_cont;

sigma = 3;
r = 5;
wmark_size = csvread('wmark_size.csv');
bin_wmark_size = csvread('bin_wmark_size.csv');
% coords = reshape(coords, [coords_size(2), coords_size(3)]);
coords = csvread('coords.csv');
% coords = coords';

for i = 1:bin_wmark_size(1)
    for j = 1:bin_wmark_size(2)
        for k = 1:r
            filled_cont_copy = (double(sum(filled_cont(coords(j, k) - sigma : coords(j, k) + sigma, coords(j, k + 5), 3))) + ...
                double(sum(filled_cont(coords(j, k), coords(j, k + 5) - sigma : coords(j, k + 5) + sigma, 3))) - ...
                2 * double(filled_cont(coords(j, k), coords(j, k + 5), 3))) / (4 * sigma);
            del = double(filled_cont(coords(j, k), coords(j, k + 5), 3)) - filled_cont_copy;
            if (and(del == 0, filled_cont_copy == 255))
                del = 0.5;
            end
            if (and(del == 0, filled_cont_copy == 0))
                del = -0.5;
            end
            if (del > 0)
                kat(k) = 1;
            else
                kat(k) = 0;
            end
        end
        bin_wmark(i, j) = (round(sum(kat) / r));
    end
end

t = 1;
k = 1;
bin_wmark_size= size(bin_wmark);

for i = 1:bin_wmark_size(2)/8
    for j = 1:8
        bin_wmark_2dim(i, j) = bin_wmark(k);
        k = k + 1;
    end
end

bin_wmark_2dim = num2str(bin_wmark_2dim);
bin_wmark_2dim = bin2dec(bin_wmark_2dim);

for i = 1:wmark_size(1)
    for j = 1:wmark_size(2)
        wmark(i, j) = bin_wmark_2dim(t);
        t = t + 1;
    end
end

wmark = uint8(wmark);
figure(4);
imshow(wmark);
imwrite(wmark, 'cvz.png');
title('The watermark');