% The script embeds a bitstream into a container.

clear all;
close all;

[empty_cont_name] = uigetfile(...
    {'*.*', 'All Files (*.*)'}, ...
    'Select an empty container');
empty_cont = imread(empty_cont_name);
empty_cont_size = size(empty_cont);
cont_height = size(empty_cont, 1);
cont_width = size(empty_cont, 2);

max_bytes = (cont_height * cont_width * 3) / 8
num_size_bits = ceil(log2(max_bytes))


[wmark_name] = uigetfile(...
    {'*.*', 'All Files (*.*)'}, ...
    'Select a watermark');
fd = fopen(wmark_name);
wmark = fread(fd);
status = fclose(fd);

for i = 1:10
    wmark_size = size(wmark, 1);
    num_bits = wmark_size*8 + num_size_bits;
    if (num_bits <= max_bytes*8)
        possible = true;
    else
        possible = false;
    end;


    if (~possible)
        [wmark_name] = uigetfile(...
            {'*.*', 'All Files (*.*)'}, ...
            'Select a smaller watermark');
        fd = fopen(wmark_name);
        wmark = fread(fd);
        status = fclose(fd);
    end
end

if (~possible)
    fprintf('The embedding was not completed.');
    return;
end;

wmark_size_arr = zeros(num_size_bits, 1);
for i = 0:1:num_size_bits-1
    wmark_size_arr(i+1) = bitand(bitshift(wmark_size, -i), 1);
end;
razdel_bits = uint8(im2bw([...
    bitand(wmark, 128), ...
    bitand(wmark, 64), ...
    bitand(wmark, 32), ...
    bitand(wmark, 16), ...
    bitand(wmark, 8), ...
    bitand(wmark, 4), ...
    bitand(wmark, 2), ...
    bitand(wmark, 1)], 0.6));
% bits = [wmark_size_arr; razdel_bits(:)];
bits = [razdel_bits(:)];
bits = bits';

L = 0.1;
r = 5;
bin_wmark_size = size(bits);
coord_y = randi([4, empty_cont_size(1) - 3], bin_wmark_size(1), bin_wmark_size(2), r);
coord_x = randi([4, empty_cont_size(2) - 3], bin_wmark_size(1), bin_wmark_size(2), r);
coords = cat(3, coord_y, coord_x);

filled_cont = empty_cont;

s = size(coords);

for i = 1:s(1)
    for j = 1:s(2)
        for k = 1:r
            Y = (0.298 * empty_cont(coords(i, j, k), coords(i, j, k + r), 1)) + ...
                (0.586 * empty_cont(coords(i, j, k), coords(i, j, k + r), 2)) + ...
                (0.114 * empty_cont(coords(i, j, k), coords(i, j, k + r), 3));
            if (Y == 0)
                Y = 5 / L;
            end
            if (bits(i, j) == 1)
                filled_cont(coords(i, j, k), coords(i, j, k + 5), 3) = ...
                    double(empty_cont(coords(i, j, k), coords(i, j, k + r), 3) + L * Y);
            else
                filled_cont(coords(i, j, k), coords(i, j, k+5), 3) = ...
                    double(empty_cont(coords(i, j, k), coords(i, j, k + r), 3) - L * Y);
            end
            if (filled_cont(coords(i, j, k), coords(i, j, k + r), 3) > 255)
                filled_cont(coords(i, j, k), coords(i, j, k + r), 3) = 255;
            end
            if (filled_cont(coords(i, j, k), coords(i, j, k + r), 3) < 0)
                filled_cont(coords(i, j, k), coords(i, j, k + r), 3) = 0;
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