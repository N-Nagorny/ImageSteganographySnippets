% The script embeds a bitstream into a color container.

clear all;

% [empty_cont_name] = uigetfile(...
%     {'*.*', 'All Files (*.*)'}, ...
%     'Select an empty container');
empty_cont_name = 'empty_container.png'
empty_cont = imread(empty_cont_name);

seg_side = 32;

dct_empty_cont = dct2(empty_cont(:, :, 3));
cont_height = size(dct_empty_cont, 1);
Nc = (cont_height.^2)/(seg_side^2);

y = 1;
n = 1;
while y < cont_height
    x = 1;
    while x < cont_height
        seg(:,:,n) = dct_empty_cont(x:x+seg_side-1, y:y+seg_side-1);
        x = x+seg_side;
        n = n + 1;
    end
    y = y+seg_side;
end

P = 99;

% [wmark_name] = uigetfile(...
%     {'*.*', 'All Files (*.*)'}, ...
%     'Select a bitstream');
wmark_name = 'bitstream.csv'
dwm = dlmread(wmark_name);

enc = seg;
% enc = zeros(size(seg,1), size(seg,2), 1);
xys = zeros(size(dwm,2),4);
for c = 1:Nc
    start_u = 1;
    start_v = seg_side;
    u1 = start_u;
    v1 = start_v;
    end_u = seg_side;
    end_v = 1;
    diag = 0;
    for ii = 1:size(dwm,2)
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
%         u1
%         v1
%         u2
%         v2
%         enc(v1,u1,c) = 1;
%         enc(v2,u2,c) = 1;        
        if dwm(ii) == 1
            while(abs(enc(v1,u1,c))-abs(enc(v2,u2,c)) >= -P)
                if (enc(v1,u1,c)>0 && enc(v2,u2,c)  > 0) || (enc(v1,u1,c)<0 && enc(v2,u2,c)<0)
                    enc(v1,u1,c) = enc(v1,u1,c) - 1;
                    enc(v2,u2,c)=enc(v2,u2,c) + 1;
                elseif enc(v1, u1, c) < 0
                    enc(v1,u1,c) = enc(v1,u1,c)+1;
                    enc(v2,u2,c) = enc(v2,u2,c)+1;
                elseif enc(v2,u2,c)<0
                    enc(v1,u1,c) = enc(v1,u1,c) -1;
                    enc(v2,u2,c) = enc(v2,u2,c) - 1;
                end
            end
        else
            while(abs(enc(v1,u1,c)) - abs(enc(v2,u2,c)) <= P)
                if (enc(v1,u1,c) > 0 && enc(v2,u2,c) > 0) || (enc(v1,u1,c) <0 && enc(v2,u2,c) < 0)
                    enc(v1,u1,c) = enc(v1,u1,c) + 1;
                    enc(v2,u2,c) = enc(v2,u2,c) - 1;
                elseif enc(v1,u1,c) < 0
                    enc(v1,u1,c) = enc(v1,u1,c) -1;
                    enc(v2,u2,c) = enc(v2,u2,c) -1;
                elseif enc(v2,u2,c) < 0
                    enc(v1,u1,c) = enc(v1,u1,c) +1;
                    enc(v2,u2,c) = enc(v2,u2,c) +1;
                end
            end
        end
        u1 = u1 + 2;
        v1 = v1 - 2;
    end
end

one = zeros(cont_height, cont_height);
y = 1;
n = 1;
while y < cont_height
    x = 1;
    while x < cont_height
        one(x:x+seg_side-1, y:y+seg_side-1) = enc(:,:,n);
        x = x+seg_side;
        n = n + 1;
    end
    y = y+seg_side;
end
blue = idct2(one);
empty_cont(:, :, 3) = blue;
% filled_cont_name = uiputfile('', 'Select a PNG file for the filled container');
filled_cont_name= 'filled_container.png'
imwrite(empty_cont, filled_cont_name, 'png');
dlmwrite('xys.csv', xys, 'precision', 6);

C = (double(empty_cont(:, :, 3)) - round(blue)).^2;
MSE = 1/(size(empty_cont, 1) * size(empty_cont, 2)) * sum(sum(C))
NMSE = sum(sum(C)) / sum(sum(double(empty_cont(:, :, 3))^2))
SNR = 1 / NMSE
PSNR = size(empty_cont, 1) * size(empty_cont, 2) * max(max(double(empty_cont(:, :, 3))^2)) / sum(sum(C))