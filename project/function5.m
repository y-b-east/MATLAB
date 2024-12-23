function function5()
    % 打开一幅图像
    [filename, pathname] = uigetfile({'*.jpg; *.jpeg; *.png; *.bmp', '所有图像文件'; '*.*', '所有文件'}, '选择一个图像文件');
    if ischar(filename)
        img = imread(fullfile(pathname, filename));
        img_gray = rgb2gray(img); % 将图像转换为灰度图以简化处理
    else
        error('没有选择文件');
    end

    % 显示原始图像
    figure;
    subplot(2,3,1); imshow(img_gray); title('原始图像');

    % 使用 Robert 算子进行边缘检测
    roberts_edges = edge(img_gray, 'roberts');
    subplot(2,3,2); imshow(roberts_edges); title('Robert 算子');

    % 使用 Prewitt 算子进行边缘检测
    prewitt_edges = edge(img_gray, 'prewitt');
    subplot(2,3,3); imshow(prewitt_edges); title('Prewitt 算子');

    % 使用 Sobel 算子进行边缘检测
    sobel_edges = edge(img_gray, 'sobel');
    subplot(2,3,4); imshow(sobel_edges); title('Sobel 算子');

    % 使用 Laplacian of Gaussian (LoG) 进行边缘检测
    laplacian_edges = edge(img_gray, 'log'); % LoG 也可以称为 Mexican hat 滤波器
    subplot(2,3,5); imshow(laplacian_edges); title('Laplacian of Gaussian (LoG)');

    % 使用 Canny 算子进行边缘检测（作为额外的对比）
    canny_edges = edge(img_gray, 'canny');
    subplot(2,3,6); imshow(canny_edges); title('Canny 算子');
end