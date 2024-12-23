function function1()
    % 打开一幅图像
    [filename, pathname] = uigetfile({'*.jpg; *.jpeg; *.png; *.bmp', '所有图像文件'; '*.*', '所有文件'}, '选择一个图像文件');
    if ischar(filename)
        img = imread(fullfile(pathname, filename));
        img_gray = rgb2gray(img); % 将图像转换为灰度图以简化处理
    else
        error('没有选择文件');
    end

    % 显示原始图像及其直方图
    figure;
    subplot(3,3,1); imshow(img_gray); title('原始图像');
    subplot(3,3,2); imhist(img_gray); title('原始直方图');

    % 直方图均衡化
    img_histeq = histeq(img_gray);
    subplot(3,3,4); imshow(img_histeq); title('直方图均衡化后的图像');
    subplot(3,3,5); imhist(img_histeq); title('均衡化后直方图');

    % 直方图匹配（规定化）
    % 选择参考图像
    [ref_filename, ref_pathname] = uigetfile({'*.jpg; *.jpeg; *.png; *.bmp', '所有图像文件'; '*.*', '所有文件'}, '选择一个参考图像文件');
    if ischar(ref_filename)
        ref_img = imread(fullfile(ref_pathname, ref_filename));
        ref_img_gray = rgb2gray(ref_img); % 将参考图像转换为灰度图
    else
        error('没有选择参考文件');
    end

    % 确保参考图像与目标图像具有相同的尺寸
    ref_img_gray = imresize(ref_img_gray, size(img_gray));

    % 进行直方图匹配
    img_matched = histeq(img_gray, nHistogram(ref_img_gray));
    subplot(3,3,7); imshow(img_matched); title('直方图匹配后的图像');
    subplot(3,3,8); imhist(img_matched); title('匹配后直方图');

    % 显示参考图像及其直方图
    subplot(3,3,3); imshow(ref_img_gray); title('参考图像');
    subplot(3,3,6); imhist(ref_img_gray); title('参考直方图');
end

function h = nHistogram(I)
    % 计算归一化的直方图
    h = imhist(I);
    h = h / sum(h);
end