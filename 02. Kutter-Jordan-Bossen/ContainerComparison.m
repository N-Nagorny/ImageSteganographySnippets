clear all;

[image1_name] = uigetfile(...
    {'*.*', 'All Files (*.*)'}, ...
    'Select an empty container');
image1 = imread(image1_name);
image1_size = size(image1);

[image2_name] = uigetfile(...
    {'*.*', 'All Files (*.*)'}, ...
    'Select the filled container');
image2 = imread(image2_name);
image2_size = size(image2);

MSE = 0;
num = 0;
denom = 0;
SNR =0;
k = 1;

for i = 1:image1_size(1)
    for j = 1:image1_size(2)
        MSE = MSE + double((image1(i, j, 3) - image2(i, j, 3))^2);
        num = num + double(image1(i, j, 3)^2);
        denom = denom + double((image1(i, j, 3) - image2(i, j, 3))^2);
    end
    MSE_blocks(k) = MSE;
    MSE_blocks(k) = MSE / image1_size(2);
    SNR_blocks(k) = num / denom;
    if (SNR_blocks(k) > 50)
        SNR_blocks(k) = 50;
    end
    k = k + 1;
    MSE = 0;
    num = 0;
    denom = 0;
end
figure;
plot(MSE_blocks);
figure;
plot(SNR_blocks);

for i = 1:image1_size(1)
    for j = 1:image1_size(2)
        MSE = MSE + double((image1(i, j, 3) - image2(i, j, 3))^2);
        num = num + double(image1(i, j, 3)^2);
        denom = denom + double((image1(i, j, 3) - image2(i, j, 3))^2);
    end
end

MSE = MSE / (image1_size(1)*image1_size(2))
SNR = num / denom