
clc;
clear;

% Read the colour image
RGB = imread('peppers.png');

% Display image information
info = imfinfo('peppers.png');
fprintf('File format: %s\n', info.Format);
fprintf('Bit depth: %d bits/pixel\n', info.BitDepth);

fprintf('Size of RGB image: %d x %d x %d\n', ...
    size(RGB,1), size(RGB,2), size(RGB,3));

% Convert colour image to grayscale
G = rgb2gray(RGB);

fprintf('Size of gray image: %d x %d\n', ...
    size(G,1), size(G,2));

% Grayscale conversion using luminance equation
Gm = uint8(0.2989 * double(RGB(:,:,1)) + ...
    0.5870 * double(RGB(:,:,2)) + ...
    0.1140 * double(RGB(:,:,3)));

fprintf('Maximum difference = %d\n', ...
    max(abs(double(G(:)) - double(Gm(:)))));

% Convert grayscale image to binary
BW1 = G > 127;

% Calculate Otsu threshold manually
counts = hist(double(G(:)), 0:255);
p = counts(:) / numel(G);

omega = cumsum(p);
mu = cumsum(p .* (0:255)');
muT = mu(end);

sigmaB = (muT * omega - mu).^2 ./ ...
    (omega .* (1 - omega) + eps);

[~, idx] = max(sigmaB);
level = (idx - 1) / 255;

BW2 = G > (level * 255);

fprintf('Otsu threshold = %.4f (%d on 0-255 scale)\n', ...
    level, round(255 * level));

% Display images
figure;

subplot(2,2,1);
imshow(RGB);
title('Colour Image');

subplot(2,2,2);
imshow(G);
title('Grayscale Image');

subplot(2,2,3);
imshow(BW1);
title('Binary Image (T = 0.5)');

subplot(2,2,4);
imshow(BW2);
title('Binary Image (Otsu Threshold)');

% Save output images
imwrite(G, 'peppers_gray.png');
imwrite(BW2, 'peppers_binary.png');
