% Your program should take as input a greyscale image and the edge detection
% parameters and return the Canny edge binary image as the result. 

% The edge detection parameters are 
% sigma, for the Gaussian convolution and 
% two thresholds: low and high, for implementing the hysteresis step.
% 
% You should implement Gaussian convolution as a sequence of horizontal and
% vertical convolutions i.e., a separable filter. 

% Also note that if you implement
% the peak/ridge detection step correctly the output of your program should NOT
% have fat edges

%eI = canny_edges_a(imread('ruler.512.tiff'), 2, 0.1, 0.04);


function edge_I = canny_edges_a(grayscale_image, sigma, high_thresh, low_thresh)

I = im2double(grayscale_image);
[h,w] = size(I);
figure, imshow(I)

% Gaussian Separable filter for smoothing.
filter_size = round(sigma) * 2 + 1; % soundup or down, make it odd.
gaussian1d = fspecial('gaussian', [1,filter_size], sigma);
I = imfilter(I, gaussian1d, 'conv');
I = imfilter(I, gaussian1d', 'conv');

% Image derivatives.
% Sobel
sobel = fspecial('sobel');
img_dx = imfilter(I, sobel, 'conv');
img_dy = imfilter(I, sobel', 'conv');


% Using Gradient
%filter_size = round(2*sigma)*2+1;
%filter_size = 3;
%gaus = fspecial ('gaussian', filter_size, sigma);
%[dX dY] = gradient(gaus);
%img_dx = imfilter(I, dX, 'symmetric', 'same');
%img_dy = imfilter(I, dY, 'symmetric', 'same');

%figure, imshow(img_dx), figure, imshow(img_dy);

% step 2 : gradient mag and dir
grad_mag = sqrt(img_dx.^2 + img_dy.^2);
grad_dir = atan2(img_dy,img_dx)*180/pi; % Convert it to degrees.
%figure, imshow(grad_mag),figure, imshow(grad_dir);

% step 3 : non-max suppression
sup_im = zeros(h,w); %initiate
% Norm to each gradient direction category, 
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
            if (grad_mag(r,c) < grad_mag(r-1,c) || grad_mag(r,c) < grad_mag(r+1,c))
                sup_im(r,c) = 0;
            else
                sup_im(r,c) = grad_mag(r,c);
            end
        end
        
        % if gradient direction is vertical, then check horizontal neighbors.
        if (grad_dir(r,c) == 90)
            if (grad_mag(r,c) < grad_mag(r,c-1) || grad_mag(r,c) < grad_mag(r,c+1))
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
%figure, imshow(sup_im);

edge_I = sup_im;

maxp = max(max(sup_im))
meanp = mean(mean(sup_im))

% step 4 : Hysteresis step.
edge_I = zeros(h,w);
for r = 1 : h
    for c = 1 : w
        if (sup_im(r,c) == 0)
            edge_I(r,c) = 0;
        elseif (sup_im(r,c) < low_thresh)
            edge_I(r,c) = 0;
        elseif (sup_im(r,c) >= low_thresh)
            edge_I(r,c) = 1;
        elseif (sup_im(r,c) <= high_thresh)
            edge_I(r,c) = 1;
        else %if ((sup_im(r+1,c) > high_thresh) || (sup_im(r-1,c) > high_thresh) || (sup_im(r,c+1) > high_thresh) || (sup_im(r,c-1) > high_thresh))
            edge_I(r,c) = 1;
        end
    end
end
figure,imshow(edge_I);