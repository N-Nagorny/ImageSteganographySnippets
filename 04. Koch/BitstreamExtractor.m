clear all;

% xys = csvread('xys.csv');
% [filled_cont_name] = uigetfile(...
%     {'*.*', 'All Files (*.*)'}, ...
%     'Select an filled container');
filled_cont_name = 'out.png';
filled_cont = imread(filled_cont_name);

dct_filled_cont = dct2(filled_cont(:, :, 3));
cont_height = size(dct_filled_cont, 1);

seg_side = 32;

Nc = (cont_height.^2)/(seg_side^2);

y = 1;
n = 1;
while y < cont_height
    x = 1;
    while x < cont_height
        seg(:,:,n) = dct_filled_cont(x:x+seg_side-1, y:y+seg_side-1);
        x = x+seg_side;
        n = n + 1;
    end
    y = y+seg_side;
end

a = ones(1, 64);
c = 100;
start_u = 1;
start_v = seg_side;
u1 = start_u;
v1 = start_v;
end_u = seg_side;
end_v = 1;
diag = 0;
for ii = 1:64
    if (u1 + 1 > end_u || v1 -1 < end_v)
        if (diag == 0)
            diag = 1;
        elseif (diag > 0)
            diag = -diag;
        elseif (diag < 0)
            diag = -diag + 1;
        end
        if (diag > 0)
            start_u = 1 + diag * 1;
            start_v = seg_side;
            end_u = seg_side;
            end_v = 1 + diag * 1; 
        elseif (diag < 0)
            start_u = 1;
            start_v = seg_side + diag * 1;
            end_u = seg_side + diag * 1;
            end_v = 1;
        end
        u1 = start_u;
        v1 = start_v;
    end
    u2 = u1 + 1;
    v2 = v1 - 1;
    if (abs(seg(v1, u1, c)) - abs(seg(v2, u2, c))) > 0
        a(1, ii) = 0;
    else a(1,ii) = 1;
    end
    u1 = u1 + 2;
    v1 = v1 - 2;
end

dlmwrite('extracted_bitstream.csv', a);
