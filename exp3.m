
clc;
clear;
close all;

%% Create a grayscale test image (256 x 256)
n = 256;
[x,y] = meshgrid(0:n-1,0:n-1);

I = uint8(127 + 60*sin(x/20).*cos(y/25) ...
    + 40*exp(-((x-130).^2+(y-120).^2)/2000));

%% Part A: Spatial Resolution (Sampling)
f = [1 2 4 8];

figure('Name','Sampling');

for k = 1:numel(f)
    Is = I(1:f(k):end,1:f(k):end);

    % Nearest-neighbour enlargement
    Id = Is(ceil((1:n)/f(k)),ceil((1:n)/f(k)));

    subplot(2,2,k);
    imagesc(Id,[0 255]);
    axis image off;
    colormap(gca,gray(256));

    title(sprintf('%d x %d samples', ...
        size(Is,1),size(Is,2)));
end

%% Part B: Intensity Resolution (Quantization)
L = [256 64 16 8 4 2];

figure('Name','Quantization');

for k = 1:numel(L)
    step = 256/L(k);
    Iq = uint8(floor(double(I)/step)*(255/(L(k)-1)));

    subplot(2,3,k);
    imagesc(Iq,[0 255]);
    axis image off;
    colormap(gca,gray(256));

    title(sprintf('%d levels (%d bits)', ...
        L(k),log2(L(k))));
end

%% Part C: Interpolation Methods
small = I(1:4:end,1:4:end);

% Nearest-neighbour interpolation
Nn = small(ceil((1:n)/4),ceil((1:n)/4));

% Bilinear interpolation (manual)
t = linspace(1,64,256);
[Xs,Ys] = meshgrid(1:64,1:64);
[Xq,Yq] = meshgrid(t,t);

Bl = interp2(Xs,Ys,double(small),Xq,Yq,'linear');
Bl = uint8(Bl);

% Bicubic interpolation (manual)
Bc = interp2(Xs,Ys,double(small),Xq,Yq,'cubic');
Bc = uint8(max(0,min(255,Bc)));

%% Calculate PSNR
mseN = mean((double(I(:))-double(Nn(:))).^2);
mseB = mean((double(I(:))-double(Bl(:))).^2);
mseC = mean((double(I(:))-double(Bc(:))).^2);

psnrN = 10*log10(255^2/(mseN+eps));
psnrB = 10*log10(255^2/(mseB+eps));
psnrC = 10*log10(255^2/(mseC+eps));

figure('Name','Interpolation');

subplot(2,2,1);
imagesc(small,[0 255]);
axis image off;
colormap(gca,gray(256));
title('64 x 64 input');

subplot(2,2,2);
imagesc(Nn,[0 255]);
axis image off;
colormap(gca,gray(256));
title(sprintf('Nearest (%.2f dB)',psnrN));

subplot(2,2,3);
imagesc(Bl,[0 255]);
axis image off;
colormap(gca,gray(256));
title(sprintf('Bilinear (%.2f dB)',psnrB));

subplot(2,2,4);
imagesc(Bc,[0 255]);
axis image off;
colormap(gca,gray(256));
title(sprintf('Bicubic (%.2f dB)',psnrC));

fprintf('PSNR nearest = %.2f dB\n',psnrN);
fprintf('PSNR bilinear = %.2f dB\n',psnrB);
fprintf('PSNR bicubic = %.2f dB\n',psnrC);
