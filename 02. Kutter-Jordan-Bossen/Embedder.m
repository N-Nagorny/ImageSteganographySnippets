% The script embeds a monochrome image into a container.

clear all;
close all;

[empty_cont_name] = uigetfile(...
    {'*.*', 'All Files (*.*)'}, ...
    'Select an empty container');
empty_cont = imread(empty_cont_name);
empty_cont_size = size(empty_cont);

[wmark_name] = uigetfile(...
    {'*.*', 'All Files (*.*)'}, ...
    'Select a watermark');
wmark = imread(wmark_name);

for i = 1:10
    wmark_size = size(wmark);
    if and(empty_cont_size(1) < wmark_size(1), empty_cont_size(2) < wmark_size(2))
        [wmark_name] = uigetfile(...
            {'*.*', 'All Files (*.*)'}, ...
            'Select a smaller watermark');
        wmark = imread(wmark_name);
    end
end

wmark_size = size(wmark);

if and(empty_cont_size(1) < wmark_size(1), empty_cont_size(2) < wmark_size(2))
    fprintf('The embedding was not completed.');
    return;
end;

k = 0;
for i = 1:wmark_size(1)
    for j = 1:wmark_size(2)
        k = k + 1;
        bin_wmark_2dim(k) = wmark(i, j);
    end
end

bin_wmark_2dim = dec2bin(bin_wmark_2dim) - '0';

k = 0;
bin_wmark_2dim_size = size(bin_wmark_2dim)
for i = 1:bin_wmark_2dim_size(1)
    for j = 1:bin_wmark_2dim_size(2)
        k = k + 1;
        bin_wmark(k) = bin_wmark_2dim(i, j);
    end
end

L = 0.1;
r = 5;
bin_wmark_size = size(bin_wmark);
coord_y = randi([4, empty_cont_size(1) - 3], bin_wmark_size(1), bin_wmark_size(2), r);
coord_x = randi([4, empty_cont_size(2) - 3], bin_wmark_size(1), bin_wmark_size(2), r);
coords = cat(3, coord_y, coord_x);

filled_cont = empty_cont;

s = size(coords);

for i = 1:s(1)
    for j = 1:s(2)
        for k = 1:r
            Y = (0.298 * empty_cont(coords(i, j, k), coords(i, j, k + 5), 1)) + ...
                (0.586 * empty_cont(coords(i, j, k), coords(i, j, k + 5), 2)) + ...
                (0.114 * empty_cont(coords(i, j, k), coords(i, j, k + 5), 3));
            if (Y == 0)
                Y = 5 / L;
            end
            if (bin_wmark(i, j) == 1)
                filled_cont(coords(i, j, k), coords(i, j, k + 5), 3) = ...
                    double(empty_cont(coords(i, j, k), coords(i, j, k + 5), 3) + L * Y);
            else
                filled_cont(coords(i, j, k), coords(i, j, k+5), 3) = ...
                    double(empty_cont(coords(i, j, k), coords(i, j, k + 5), 3) - L * Y);
            end
            if (filled_cont(coords(i, j, k), coords(i, j, k + 5), 3) > 255)
                filled_cont(coords(i, j, k), coords(i, j, k + 5), 3) = 255;
            end
            if (filled_cont(coords(i, j, k), coords(i, j, k + 5), 3) < 0)
                filled_cont(coords(i, j, k), coords(i, j, k + 5), 3) = 0;
            end
        end
    end
end

filled_cont_name = uiputfile('', 'Select a PNG file for the filled container');
imwrite(filled_cont, filled_cont_name, 'png');
bin_wmark_size = int64(bin_wmark_size);
dlmwrite('bin_wmark_size.csv', bin_wmark_size, 'precision', 6);
dlmwrite('wmark_size.csv', wmark_size, 'precision', 6);
coords_size = size(coords);
dlmwrite('coords.csv', reshape(coords, [coords_size(2), coords_size(3)]));