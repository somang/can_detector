% Your program should take as input a greyscale image and the edge detection
% parameters and return the Canny edge binary image as the result. The edge
% detection parameters are sigma for the Gaussian convolution and two thresholds,
% low and high, for implementing the hysteresis step.
% 
% You should implement Gaussian convolution as a sequence of horizontal and
% vertical convolutions i.e., a separable filter. Also note that if you implement
% the peak/ridge detection step correctly the output of your program should NOT
% have fat edges

function edge_I = canny_edges(grayscale_image, sigma, max_thresh, min_thresh)
% sigma = 1

%I = grayscale_image;
I = im2double(grayscale_image);
[h,w] = size(I);
filter_size = 5;
%figure, imshow(I);
%figure, edge(I,'canny');

% step 1 : derivatives
% smooth to reduce noise.
gaus_filter = fspecial ('gaussian', filter_size, sigma);
[dX dY] = gradient(gaus_filter); % separable filter

I = imfilter(I, gaus_filter, 'same');
%I = imfilter(I, dX, 'symmetric', 'same'); % do horizontal denoise
%I = imfilter(I, dY, 'symmetric', 'same'); % then vertical denoise
%figure, imshow(I);

% derivatives of image.
img_dy = imfilter(I, dY, 'symmetric', 'same');
img_dx = imfilter(I, dX, 'symmetric', 'same');
%figure, imshow(img_dx), figure, imshow(img_dy);

% step 2 : gradient mag and dir
grad_mag = sqrt(double(img_dx).^2 + double(img_dy).^2);
grad_dir = atan2(double(img_dy), double(img_dx)) * 180 / pi; % Convert it to degrees.
%figure, imshow(grad_mag);
%figure, imshow(grad_dir);

% Discretization of directions
n_direction_dis = zeros(h, w);
for i = 1  : h
    for j = 1 : w
        gd = grad_dir(i, j);
        if (gd >= -22.5 && gd < 22.5) || (gd >= 157.5 && gd <= 180) || (gd < -157.5 && gd >= -180)
            n_direction_dis(i, j) = 0;
        end
        if (gd >= 67.5 && gd < 112.5) || (gd < -67.5 && gd >= -112.5)
            n_direction_dis(i, j) = 90;
        end
        if (gd >= 22.5 && gd < 67.5) || (gd < -112.5 && gd >= -157.5)
            n_direction_dis(i, j) = 45;
        end
        if (gd < -22.5 && gd >= -67.5) || (gd >= 112.5 && gd < 157.5)
            n_direction_dis(i, j) = 135;
        end
    end
end


% step 3 : non-max suppression
sup_im = zeros(h,w); %initiate
% Norm to each gradient direction category, 
for r = 2 : h-1 % height: number of rows
    for c = 2 : w-1 % width: number of columns
        gd = grad_dir(r,c);        
        
        % if gradient direction is horizontal, then check vertical neighbors.
        if (n_direction_dis(i, j) == 0)
            if (grad_mag(r,c) > grad_mag(r-1,c) && grad_mag(r,c) > grad_mag(r+1,c))
                sup_im(r,c) = grad_mag(r,c);
            else
                sup_im(r,c) = 0;
            end
        end
        
        % if gradient direction is vertical, then check horizontal neighbors.
        if (n_direction_dis(i, j) == 90)
            if (grad_mag(r,c) > grad_mag(r,c-1) && grad_mag(r,c) > grad_mag(r,c+1))
                sup_im(r,c) = grad_mag(r,c);
            else
                sup_im(r,c) = 0;
            end
        end
        
        % if gradient direction in angle 45 or -135, look for two neighboring diagonal pixels.
        if (n_direction_dis(i, j) == 45)
            if (grad_mag(r,c) > grad_mag(r+1,c+1) && grad_mag(r,c) > grad_mag(r-1,c-1))
                sup_im(r,c) = grad_mag(r,c);
            else
                sup_im(r,c) = 0;
            end
        end        
        
        % if gradient direction in angle 135 or -45, look for two neighboring diagonal pixels.
        if (n_direction_dis(i, j) == 135)
            if (grad_mag(r,c) > grad_mag(r-1,c+1) && grad_mag(r,c) > grad_mag(r+1,c-1))
                sup_im(r,c) = grad_mag(r,c);
            else
                sup_im(r,c) = 0;
            end
        end        
    end
end
%figure, imshow(sup_im);


% step 4 : Hysteresis step.

edge_I = zeros(h,w);
for r = 1 : h
    for c = 1 : w
        if (sup_im(r,c) == 0)
            edge_I(r,c) = 0;
        elseif (sup_im(r,c) < min_thresh)
            edge_I(r,c) = 0;
        elseif (sup_im(r,c) > max_thresh)
            edge_I(r,c) = 1;
        elseif ((sup_im(r+1,c) > max_thresh) || (sup_im(r-1,c) > max_thresh) || (sup_im(r,c+1) > max_thresh) || (sup_im(r,c-1) > max_thresh))
            edge_I(r,c) = 1;
        end
    end
end

figure,imshow(edge_I);