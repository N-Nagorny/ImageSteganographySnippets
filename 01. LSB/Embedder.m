% The script embeds a monochrome image into a color container.

clear all;

[empty_cont_name] = uigetfile(...
    {'*.*', 'All Files (*.*)'}, ...
    'Select an empty container');
empty_cont = imread(empty_cont_name);

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

if (possible)
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
    bits = [wmark_size_arr; razdel_bits(:)];
    bits_iter = 1:size(bits, 1);
    bits_iter = bits_iter';
    bits = bits';
    filled_cont = empty_cont;
    new_cont(bits_iter) = bitshift(empty_cont(bits_iter), -1);
    new_cont(bits_iter) = bitshift(new_cont(bits_iter), 1) + bits(bits_iter);
    filled_cont(bits_iter) = new_cont(bits_iter);
    filled_cont_name = uiputfile('', 'Select a PNG file for the filled container');
    imwrite(filled_cont, filled_cont_name, 'png');
    fprintf('Embedding was completed successfully.\n')
else
    fprintf('Embedding was not completed.\n')
end;