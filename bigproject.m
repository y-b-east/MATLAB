function bigproject()
    % 初始化变量
    loadedImage = [];
    
    % 创建图形用户界面
    fig = uifigure('Name', 'Image Processing', 'Position', [100 100 800 600]);
    
    % 加载图像按钮
    uicontrol('Style', 'pushbutton', 'String', 'Load Image', 'Position', [20 550 100 30], 'Callback', @(btn,event) loadImage());
    
    % 显示灰度直方图按钮
    uicontrol('Style', 'pushbutton', 'String', 'Display Histogram', 'Position', [140 550 120 30], 'Callback', @(btn,event) displayHistogram());
    
    % 直方图均衡化按钮
    uicontrol('Style', 'pushbutton', 'String', 'Histogram Equalization', 'Position', [280 550 150 30], 'Callback', @(btn,event) histogramEqualization());
    
    % 对比度增强按钮
    uicontrol('Style', 'pushbutton', 'String', 'Contrast Enhancement', 'Position', [20 500 100 30], 'Callback', @(btn,event) contrastEnhancement());
    
    % 图像缩放按钮
    uicontrol('Style', 'pushbutton', 'String', 'Scale Image', 'Position', [140 500 100 30], 'Callback', @(btn,event) scaleImage());
    
    % 图像旋转按钮
    uicontrol('Style', 'pushbutton', 'String', 'Rotate Image', 'Position', [260 500 100 30], 'Callback', @(btn,event) rotateImage());
    
    % 图像加噪按钮
    uicontrol('Style', 'pushbutton', 'String', 'Add Noise', 'Position', [20 450 100 30], 'Callback', @(btn,event) addNoise());
    
    % 图像滤波按钮
    uicontrol('Style', 'pushbutton', 'String', 'Filter Image', 'Position', [140 450 100 30], 'Callback', @(btn,event) filterImage());
    
    % 边缘提取按钮
    uicontrol('Style', 'pushbutton', 'String', 'Edge Detection', 'Position', [20 400 100 30], 'Callback', @(btn,event) edgeDetection());
    
    % 显示原始图像
    axes('Position', [0.1 0.3 0.8 0.7]);
end

function loadImage()
    [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp', 'Image Files'});
    if isequal(filename, 0)
        return;
    end
    global loadedImage;
    loadedImage = imread(fullfile(pathname, filename));
    imshow(loadedImage);
end

function displayHistogram()
    global loadedImage;
    if isempty(loadedImage)
        error('No image loaded.');
    end
    grayImage = rgb2gray(loadedImage);
    figure, imhist(grayImage);
end

function histogramEqualization()
    global loadedImage;
    if isempty(loadedImage)
        error('No image loaded.');
    end
    grayImage = rgb2gray(loadedImage);
    eqImage = histeq(grayImage);
    figure, imshow(eqImage);
end

function contrastEnhancement()
    global loadedImage;
    if isempty(loadedImage)
        error('No image loaded.');
    end
    grayImage = rgb2gray(loadedImage);
    enhancedImage = imadjust(grayImage);
    figure, imshow(enhancedImage);
end

function scaleImage()
    global loadedImage;
    if isempty(loadedImage)
        error('No image loaded.');
    end
    scaledImage = imresize(loadedImage, 0.5);
    figure, imshow(scaledImage);
end

function rotateImage()
    global loadedImage;
    if isempty(loadedImage)
        error('No image loaded.');
    end
    rotatedImage = imrotate(loadedImage, 45);
    figure, imshow(rotatedImage);
end

function addNoise()
    global loadedImage;
    if isempty(loadedImage)
        error('No image loaded.');
    end
    noisyImage = imnoise(loadedImage, 'gaussian', 0, 0.01);
    figure, imshow(noisyImage);
end

function filterImage()
    global loadedImage;
    if isempty(loadedImage)
        error('No image loaded.');
    end
    grayImage = rgb2gray(loadedImage);
    filteredImage = imgaussfilt(grayImage, 2);
    figure, imshow(filteredImage);
end

function edgeDetection()
    global loadedImage;
    if isempty(loadedImage)
        error('No image loaded.');
    end
    grayImage = rgb2gray(loadedImage);
    edges = edge(grayImage, 'Canny');
    figure, imshow(edges);
end