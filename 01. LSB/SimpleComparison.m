clear all;

[image1_name] = uigetfile(...
    {'*.*', 'All Files (*.*)'}, ...
    'Select the first image');
image1_fd = fopen(image1_name);
image1 = fread(image1_fd);
image1_size = size(image1, 1);

[image2_name] = uigetfile(...
    {'*.*', 'All Files (*.*)'}, ...
    'Select the second image');
image2_fd = fopen(image2_name);
image2 = fread(image2_fd);
image2_size = size(image2, 1);

MSE = 0;
NMSE = 0;
SNR = 0;

for i = 1:image1_size
    form_mse = (image1(i) - image2(i))^2;
    form_nmse = form_mse / image1(i)^2;
    form_snr = image1(i)^2 / form_mse;
    if isnan(form_nmse) | isnan(form_snr) | isinf(form_nmse) | isinf(form_snr)
        form_nmse = 0;
        form_snr = 0;
    end;
    MSE = MSE + form_mse;
    NMSE = NMSE + form_nmse;
    SNR = SNR + form_snr;
end
mult = image1_size;

MSE = MSE / mult
NMSE = NMSE * 100
SNR = 10 * log10(SNR)
mA = max(image2)
PSNR = 20 * log10(mA/sqrt(MSE))