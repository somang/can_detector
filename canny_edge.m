
function edge_I = canny_edge(image, sigma, high_thresh, low_thresh)
I = im2double(image);
[h,w] = size(I);

% STEP 1. APPLY SMOOTH FILTER TO DENOISE, AND GET IMAGE DERIVATIVES.
% Gaussian Separable filter for smoothing.
filter_size = round(sigma) * 2 + 1; % roundup or down, make it odd.
one_d_gaussian = fspecial('gaussian', [1,filter_size], sigma);
temp = imfilter(I, one_d_gaussian, 'same');
smooth_I = imfilter(temp, one_d_gaussian', 'same');

% Image derivatives.
dx = imfilter(fspecial('gaussian',filter_size, sigma),[2 0 -2],'same'); % to exaggerate, multiplied 2 to [1 0 -1].
dy = imfilter(fspecial('gaussian',filter_size, sigma),[2 0 -2]','same');
img_dx = imfilter(smooth_I,dx);
img_dy = imfilter(smooth_I,dy);

% Sobel for extra
% sobel = fspecial('sobel');
% img_dx = imfilter(I, sobel, 'conv');
% img_dy = imfilter(I, sobel', 'conv');

% Or Using Gradient builtin function.
%filter_size = round(2*sigma)*2+1;
%gaus = fspecial ('gaussian', filter_size, sigma);
%[dX dY] = gradient(gaus);
%img_dx = imfilter(I, dX, 'symmetric', 'same');
%img_dy = imfilter(I, dY, 'symmetric', 'same');

% Original image, Smooth Image, X-Deriv, Y-Deriv
figure,
subplot(2,2,1), imshow(I), title('Original Image');
subplot(2,2,2), imshow(smooth_I), title('Smooth Filtered Image');
subplot(2,2,3), imshow(img_dx), title('X-Derivative Image');
subplot(2,2,4), imshow(img_dy), title('Y-Derivative Image'), pause;


% STEP 2. GRADIENT MAGNITUDE AND DIRECITON.
grad_mag = sqrt(img_dx.^2 + img_dy.^2);
grad_dir = atan2(img_dy,img_dx)*180/pi; % Convert it to degrees.
 
% STEP 3. Non-Max SUPPRESSION.
sup_im = zeros(h,w);
% Norm to each gradient direction categorization, 
for r = 2 : h-1 % height: number of rows
    for c = 2 : w-1 % width: number of columns
        gd = grad_dir(r,c);
        
        if (gd >= -22.5 && gd < 22.5) || (gd >= 157.5 && gd <= 180) || (gd < -157.5 && gd >= -180)
            grad_dir(r,c) = 0;
        end
        if (gd >= 67.5 && gd < 112.5) || (gd < -67.5 && gd >= -112.5)
            grad_dir(r,c) = 90;
        end
        if (gd >= 22.5 && gd < 67.5) || (gd < -112.5 && gd >= -157.5)
            grad_dir(r,c) = 45;
        end
        if (gd < -22.5 && gd >= -67.5) || (gd >= 112.5 && gd < 157.5)
            grad_dir(r,c) = 135;
        end
        
        % if gradient direction is horizontal, then check vertical neighbors.
        if (grad_dir(r,c) == 0)
            if (grad_mag(r,c) < grad_mag(r,c-1) || grad_mag(r,c) < grad_mag(r,c+1))
                sup_im(r,c) = 0;
            else
                sup_im(r,c) = grad_mag(r,c);
            end
        end
        
        % if gradient direction is vertical, then check horizontal neighbors.
        if (grad_dir(r,c) == 90)
            if (grad_mag(r,c) < grad_mag(r-1,c) || grad_mag(r,c) < grad_mag(r+1,c))
                sup_im(r,c) = 0;
            else
                sup_im(r,c) = grad_mag(r,c);
            end
        end
        
        % if gradient direction in angle 45 or -135, look for two neighboring diagonal pixels.
        if (grad_dir(r,c) == 45)
            if (grad_mag(r,c) < grad_mag(r+1,c+1) || grad_mag(r,c) < grad_mag(r-1,c-1))
                sup_im(r,c) = 0;
            else
                sup_im(r,c) = grad_mag(r,c);
            end
        end        
        
        % if gradient direction in angle 135 or -45, look for two neighboring diagonal pixels.
        if (grad_dir(r,c) == 135)
            if (grad_mag(r,c) < grad_mag(r-1,c+1) || grad_mag(r,c) < grad_mag(r+1,c-1))
                sup_im(r,c) = 0;
            else
                sup_im(r,c) = grad_mag(r,c);
            end
        end        
    end
end

% mean(mean(sup_im))
% mean(max(sup_im))

% STEP 4. HYSTERESIS STEP.
edge_I = zeros(h,w);
for r = 1 : h
    for c = 1 : w
        if (sup_im(r,c) == 0) % Zero is zero.
            edge_I(r,c) = 0;
        elseif (sup_im(r,c) >= high_thresh) % First check for high threshold
            edge_I(r,c) = 1;
        elseif (sup_im(r,c) < low_thresh) % If it is less than low threshold, then ignore.
            edge_I(r,c) = 0;
            
            % If any pixel having low threshold in continuous edge, then 1.
        elseif (grad_dir(r,c) == 0)
            if (sup_im(r-1,c) >= low_thresh) || (sup_im(r+1,c) >= low_thresh)
                edge_I(r,c) = 1;
            end
        elseif (grad_dir(r,c) == 90)
            if (sup_im(r,c-1) >= low_thresh) || (sup_im(r-1,c+1) >= low_thresh)
                edge_I(r,c) = 1;
            end
        elseif (grad_dir(r,c) == 45)
            if (sup_im(r-1,c-1) >= low_thresh) || (sup_im(r+1,c+1) >= low_thresh)
                edge_I(r,c) = 1;
            end
        elseif (grad_dir(r,c) == 135)
            if (sup_im(r-1,c+1) >= low_thresh) || (sup_im(r+1,c-1) >= low_thresh)
                edge_I(r,c) = 1;
            end
        else
            edge_I(r,c) = 0;
        end
    end
end

% Gradient Magnitude, Gradient Direction, Non-Max Suppressed, After Threshold
figure,
subplot(2,2,1), imshow(grad_mag), title('Gradient Magnitude');
subplot(2,2,2), imshow(grad_dir), title('Gradient Direction');
subplot(2,2,3), imshow(sup_im), title('Non-Max Suppressed');
subplot(2,2,4), imshow(edge_I), title('After Threshold Image'), pause;