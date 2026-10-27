
clc;
clear;
close all;

% Read the colour image
RGB = imread('peppers.png');

% Ensure the image is uint8
RGB = uint8(RGB);

R = RGB(:,:,1);
G = RGB(:,:,2);
B = RGB(:,:,3);

Z = zeros(size(R), 'uint8');

%% (a) RGB Components
figure('Name','RGB Components');

subplot(2,4,1);
image(RGB);
axis image off;
title('Original');

subplot(2,4,2);
image(cat(3,R,Z,Z));
axis image off;
title('Red Component');

subplot(2,4,3);
image(cat(3,Z,G,Z));
axis image off;
title('Green Component');

subplot(2,4,4);
image(cat(3,Z,Z,B));
axis image off;
title('Blue Component');

subplot(2,4,6);
imagesc(R);
axis image off;
colormap(gca, gray(256));
title('R Intensity');

subplot(2,4,7);
imagesc(G);
axis image off;
colormap(gca, gray(256));
title('G Intensity');

subplot(2,4,8);
imagesc(B);
axis image off;
colormap(gca, gray(256));
title('B Intensity');

%% (b) CMY Colour Model
CMY = uint8(255 - double(RGB));

figure('Name','CMY Model');

subplot(1,4,1);
image(CMY);
axis image off;
title('CMY Image');

subplot(1,4,2);
imagesc(CMY(:,:,1));
axis image off;
colormap(gca, gray(256));
title('Cyan');

subplot(1,4,3);
imagesc(CMY(:,:,2));
axis image off;
colormap(gca, gray(256));
title('Magenta');

subplot(1,4,4);
imagesc(CMY(:,:,3));
axis image off;
colormap(gca, gray(256));
title('Yellow');

%% (c) HSV Colour Model - Manual Conversion
R1 = double(R)/255;
G1 = double(G)/255;
B1 = double(B)/255;

MaxC = max(RGB,[],3);
MinC = min(RGB,[],3);

MaxD = double(MaxC)/255;
MinD = double(MinC)/255;
Delta = MaxD - MinD;

V = MaxD;
S = zeros(size(MaxD));
idx = MaxD > 0;
S(idx) = Delta(idx)./MaxD(idx);

H = zeros(size(MaxD));
idx = Delta > 0;

idxR = idx & (MaxC == R);
idxG = idx & (MaxC == G) & (MaxC ~= R);
idxB = idx & (MaxC == B) & (MaxC ~= R) & (MaxC ~= G);

H(idxR) = mod((G1(idxR)-B1(idxR))./Delta(idxR),6);
H(idxG) = (B1(idxG)-R1(idxG))./Delta(idxG) + 2;
H(idxB) = (R1(idxB)-G1(idxB))./Delta(idxB) + 4;

H = H/6;
HSV = cat(3,H,S,V);

%% YCbCr Colour Model - Manual Conversion
Y  = 0.299*R1 + 0.587*G1 + 0.114*B1;
Cb = 128/255 + (-0.168736*R1 - 0.331264*G1 + 0.5*B1);
Cr = 128/255 + (0.5*R1 - 0.418688*G1 - 0.081312*B1);

YCC = cat(3,Y,Cb,Cr);

figure('Name','HSV and YCbCr');

subplot(2,3,1);
imagesc(H);
axis image off;
colormap(gca, gray(256));
title('Hue');

subplot(2,3,2);
imagesc(S);
axis image off;
colormap(gca, gray(256));
title('Saturation');

subplot(2,3,3);
imagesc(V);
axis image off;
colormap(gca, gray(256));
title('Value');

subplot(2,3,4);
imagesc(Y);
axis image off;
colormap(gca, gray(256));
title('Y (Luma)');

subplot(2,3,5);
imagesc(Cb);
axis image off;
colormap(gca, gray(256));
title('Cb');

subplot(2,3,6);
imagesc(Cr);
axis image off;
colormap(gca, gray(256));
title('Cr');

%% (d) One Pixel in Different Colour Models
r = 200;
c = 300;

rgb_pixel = double(reshape(RGB(r,c,:),1,3));
cmy_pixel = double(reshape(CMY(r,c,:),1,3));
hsv_pixel = reshape(HSV(r,c,:),1,3);
ycc_pixel = reshape(YCC(r,c,:),1,3);

fprintf('Pixel (%d,%d)\n',r,c);
fprintf('RGB = [%.0f %.0f %.0f]\n',rgb_pixel);
fprintf('CMY = [%.0f %.0f %.0f]\n',cmy_pixel);
fprintf('HSV = [%.3f %.3f %.3f]\n',hsv_pixel);
fprintf('YCbCr = [%.3f %.3f %.3f]\n',ycc_pixel*255);

%% (e) Colour Enhancement - Increase Saturation
HSV2 = HSV;
HSV2(:,:,2) = min(1.5*HSV(:,:,2),1);

% Manual HSV to RGB conversion
H2 = HSV2(:,:,1);
S2 = HSV2(:,:,2);
V2 = HSV2(:,:,3);

C = V2.*S2;
X = C.*(1-abs(mod(6*H2,2)-1));
m = V2-C;

Rp = zeros(size(H2));
Gp = zeros(size(H2));
Bp = zeros(size(H2));

k = floor(6*H2);
i = (k == 0);
Rp(i)=C(i); Gp(i)=X(i);

i = (k == 1);
Rp(i)=X(i); Gp(i)=C(i);

i = (k == 2);
Gp(i)=C(i); Bp(i)=X(i);

i = (k == 3);
Gp(i)=X(i); Bp(i)=C(i);

i = (k == 4);
Rp(i)=X(i); Bp(i)=C(i);

i = (k >= 5);
Rp(i)=C(i); Bp(i)=X(i);

Rout = uint8(255*(Rp+m));
Gout = uint8(255*(Gp+m));
Bout = uint8(255*(Bp+m));

Enhanced = cat(3,Rout,Gout,Bout);

figure('Name','Saturation Enhancement');

subplot(1,2,1);
image(RGB);
axis image off;
title('Original Image');

subplot(1,2,2);
image(Enhanced);
axis image off;
title('Saturation x 1.5');
