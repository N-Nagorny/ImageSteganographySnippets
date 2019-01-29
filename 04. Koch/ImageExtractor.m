clear all;


xys = csvread('xys.csv');
[filled_cont_name] = uigetfile(...
    {'*.*', 'All Files (*.*)'}, ...
    'Select an filled container');
filled_cont = imread(filled_cont_name);

dct_filled_cont = dct2(filled_cont(:, :, 3));
cont_height = size(dct_filled_cont, 1);
Nc = (cont_height.^2)/64;
seg(:, :, 1) = dct_filled_cont(1:8, 1:8);
seg(:, :, Nc) = dct_filled_cont(cont_height - 7:cont_height, cont_height -7:cont_height);
for b = 2:(Nc - 1)
    if rem(b, sqrt(Nc)) == 0
        seg(:, :, b) = dct_filled_cont(cont_height - 7:cont_height, 8*(ceil(b/sqrt(Nc)) - 1) + 1:8*(ceil(b/sqrt(Nc)) - 1) + 8);
    else
        seg(:, :, b) = dct_filled_cont(8 * (b - sqrt(Nc) * floor(b / sqrt(Nc)) - 1) + ...
            1:8 * (b - sqrt(Nc) * floor(b / sqrt(Nc)) - 1) + ...
            8, 8 * (ceil(b /sqrt(Nc)) - 1) + 1:8 * (ceil(b / sqrt(Nc)) - 1) + 8);
    end
end

a = ones(sqrt(size(xys, 1)));
c = 1;
d = 1;
for ii = 1:size(xys, 1)
    if (abs(seg(xys(ii, 1), xys(ii, 2), ii)) - abs(seg(xys(ii, 3), xys(ii, 4), ii))) > 0
        a(c, d) = 0;
    else a(c, d) = 1;
    end
    d = d+1;
    if (d > sqrt(size(xys, 1)))
        d = 1;
        c = c+1;
    end
end

filled_cont_name = uiputfile('', 'Select a PNG file for the filled container');
imwrite(a, filled_cont_name, 'png');
