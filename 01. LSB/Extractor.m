% The script extracts a monochrome image from first bytes of a filled container.

clear all;

[filled_cont_name] = uigetfile(...
    {'*.*', 'All Files (*.*)'}, ...
    'Select a filled container');

filled_cont = imread(filled_cont_name);

filled_cont_height = size(filled_cont, 1);
filled_cont_width = size(filled_cont, 2);

max_bytes = (filled_cont_height * filled_cont_width * 3) / 8
num_size_bits = ceil(log2(max_bytes))

i = 1:num_size_bits;
wmark_size_arr = filled_cont(i);
wmark_size_arr = uint32(bitand(wmark_size_arr, 1));

for i = 1:1:num_size_bits
    wmark_size_arr(i) = wmark_size_arr(i)*(2^(i - 1));
end;
wmark_size_arr = wmark_size_arr';
wmark_size = uint32(sum(wmark_size_arr))

if (wmark_size > max_bytes)
    fprintf('The watermark size hidden in the filled container is corrupted.\n');
    return
end

i = num_size_bits+1:num_size_bits+wmark_size*8;
wmark_area = filled_cont(i);
wmark = bitand(wmark_area, 1)';
wmark = reshape(wmark, wmark_size, 8);
wmark = uint8([
    wmark(:, 1)*128, ...
    wmark(:, 2)*64, ...
    wmark(:, 3)*32, ...
    wmark(:, 4)*16, ...
    wmark(:, 5)*8, ...
    wmark(:, 6)*4, ...
    wmark(:, 7)*2, ...
    wmark(:, 8)*1]);
bytes = sum(wmark, 2);

wmark_name = uiputfile;
fd = fopen(wmark_name, 'w');
count = fwrite(fd, bytes);
fclose(fd);