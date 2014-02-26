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
%ID = grayscale_image;
ID = im2double(grayscale_image);
[h,w] = size(ID);
filter_size = 5;
%figure, imshow(ID), pause;

% step 1 : derivatives
% smooth to reduce noise.
gaus_filter = fspecial ('gaussian', filter_size, sigma);
ID = imfilter(ID, gaus_filter, 'same');
%figure, imshow(ID), pause;

% derivatives of image.
[dX dY] = gradient(gaus_filter);
mX = double(imfilter(ID, dX, 'same'));
mY = double(imfilter(ID, dY, 'same'));
%figure, imshow(mX), figure, imshow(mY);

% step 2 : gradient mag and dir
grad_mag = sqrt(mX.^2 + mY.^2);
grad_dir = atan2(mY, mX);
grad_dir = grad_dir*180/pi; % Convert it to degrees.
%figure, imshow(grad_mag), figure, imshow(grad_dir);

% step 3 : non-max suppression
sup_im = zeros(h,w); %initiate
% Norm to each gradient direction category, 
for r = 2 : h-1 % height: number of rows
    for c = 2 : w-1 % width: number of columns
        
        % dx : gradient direction in angle 0 or 180(-180), look for two horizontal pixels near.      
        % | p p p |
        if ((grad_dir(r,c) > 0 ) && (grad_dir(r,c) < 22.5)) || ((grad_dir(r,c) > 157.5) && (grad_dir(r,c) < -157.5)) 
            if ((grad_mag(r,c) > grad_mag(r,c+1)) && (grad_mag(r,c) > grad_mag(r,c-1))) % then look for horizontal neighbors to compare.
                sup_im(r,c) = grad_mag(r,c);
            else
                sup_im(r,c) = 0;
            end
        end
        
        % dy : gradient direction in angle 90 or -90, look for two vertical pixels near.
        % | p |
        % | p |
        % | p |
        if ((grad_dir(r,c) > 67.5) && (grad_dir(r,c) < 112.5)) || ((grad_dir(r,c) < -67.5) && (grad_dir(r,c) > 112.5))
            if ((grad_mag(r,c) > grad_mag(r+1,c)) && (grad_mag(r,c) > grad_mag(r-1,c)))
                sup_im(r,c) = grad_mag(r,c);
            else
                sup_im(r,c) = 0;
            end
        end
        
        % dxdy : direction in angle 45 or -135, look for two neighboring diagonal pixels.
        % |0 0 p|
        % |0 p 0|
        % |p 0 0|
        if ((grad_dir(r,c) > 22.5) && (grad_dir(r,c) < 67.5)) || ((grad_dir(r,c) < -112.5) && (grad_dir(r,c) > -157.5))
            if ((grad_mag(r,c) > grad_mag(r+1,c-1)) && (grad_mag(r,c) > grad_mag(r-1,c+1)))
                sup_im(r,c) = grad_mag(r,c);
            else
                sup_im(r,c) = 0;
            end
        end        
        
        % dxdy : direction in angle -45 or 135, look for two neighboring diagonal pixels.
        % |p 0 0|
        % |0 p 0|
        % |0 0 p|
        if ((grad_dir(r,c) < -22.5) && (grad_dir(r,c) > -67.5)) || ((grad_dir(r,c) > 112.5) && (grad_dir(r,c) <= 157.5))
            if ((grad_mag(r,c) > grad_mag(r+1,c+1)) && (grad_mag(r,c) > grad_mag(r-1,c-1)))
                sup_im(r,c) = grad_mag(r,c);
            else
                sup_im(r,c) = 0;
            end
        end
    end
end
%figure, imshow(sup_im);


% step 4 : Hysteresis step.
%high_I = max_thresh * mean(mean(grad_mag));
%low_I = min_thresh * high_I;
high_I = max_thresh;
low_I = min_thresh;

edge_I = zeros(h,w);
for r = 1 : h
    for c = 1 : w
        if (sup_im(r,c) == 0)
            edge_I(r,c) = 0;
        elseif (sup_im(r,c) < low_I)
            edge_I(r,c) = 0;
        elseif (sup_im(r,c) > high_I)
            edge_I(r,c) = 1;
        elseif ((sup_im(r+1,c)>high_I)||(sup_im(r-1,c)>high_I)||(sup_im(r,c+1)>high_I)||(sup_im(r,c-1)>high_I))
                edge_I(r,c) = 1;
        end
    end
end

imshow(edge_I);