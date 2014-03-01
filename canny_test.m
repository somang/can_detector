big_apple = rgb2gray(imread('Images/big-bowl-of-fruit.jpg'));
sigma = 2;
high_thresh = 0.01;
low_thresh = 0.008;
apple_edge = canny_edge(big_apple,sigma,high_thresh,low_thresh);
figure, imshow(apple_edge), title('After Threshold Image'),pause;

small_apple = rgb2gray(imread('Images/bowl-of-fruit.jpg'));
sigma = 1;
high_thresh = 0.02;
low_thresh = 0.015;
small_apple_edge = canny_edge(small_apple,sigma,high_thresh,low_thresh);
figure, imshow(small_apple_edge), title('After Threshold Image'),pause;


roof = rgb2gray(imread('Images/houseedeg.tiff'));
sigma = 1;
high_thresh = 0.05;
low_thresh = 0.02;
roof_edge = canny_edge(roof,sigma,high_thresh,low_thresh);
figure, imshow(roof_edge), title('After Threshold Image'),pause;


ruler = imread('Images/ruler.512.tiff');
sigma = 0.6;
high_thresh = 0.6;
low_thresh = 0.4;
ruler_edge = canny_edge(ruler,sigma,high_thresh,low_thresh);
figure, imshow(ruler_edge), title('After Threshold Image'),pause;
