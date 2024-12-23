function bigproject0_2()
    % 清除工作区变量，清空命令窗口，并关闭所有图形窗口
    clear; clc; close all;

    % 读取图像
    [filename, pathname] = uigetfile({'*.jpg; *.jpeg; *.png; *.bmp', '所有图像文件'; '*.*', '所有文件'}, '选择一个图像文件');
    if ischar(filename)
        img = imread(fullfile(pathname, filename));
    else
        error('没有选择文件');
    end

    % 如果图像是RGB，则转换为灰度图像
    if size(img, 3) == 3
        rgb_img = double(img);
        img_gray = 0.2989 * rgb_img(:,:,1) + 0.5870 * rgb_img(:,:,2) + 0.1140 * rgb_img(:,:,3);
    else
        img_gray = double(img); % 确保是双精度类型
    end

    % 显示原始图像及其直方图
    figure;
    subplot(3,3,1); imshow(uint8(img_gray)); title('原始图像');
    subplot(3,3,2); imhist(uint8(img_gray)); title('原始直方图');

    % 直方图均衡化
    img_histeq = histeq(uint8(img_gray));
    subplot(3,3,4); imshow(uint8(img_histeq)); title('直方图均衡化后的图像');
    subplot(3,3,5); imhist(uint8(img_histeq)); title('均衡化后直方图');

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
    img_matched = histeq(uint8(img_gray), nHistogram(ref_img_gray));
    subplot(3,3,7); imshow(uint8(img_matched)); title('直方图匹配后的图像');
    subplot(3,3,8); imhist(uint8(img_matched)); title('匹配后直方图');

    % 显示参考图像及其直方图
    subplot(3,3,3); imshow(uint8(ref_img_gray)); title('参考图像');
    subplot(3,3,6); imhist(uint8(ref_img_gray)); title('参考直方图');

    % 线性变换：对比度拉伸
    min_val = min(img_gray(:));
    max_val = max(img_gray(:));
    img_linear = (img_gray - min_val) / (max_val - min_val) * 255;
    img_linear = uint8(min(max(img_linear, 0), 255)); % 转换回uint8以显示

    % 对数变换：对比度增强
    c_log = 255 / log(1 + max(img_gray(:))); % 计算缩放因子c
    img_log = c_log * log(double(img_gray) + 1);
    img_log = uint8(min(max(img_log, 0), 255)); % 转换回uint8以显示

    % 指数变换：对比度增强
    gamma = 0.5; % 可调整的参数，用于控制指数曲线的形状
    c_exp = 255 / (255^gamma);
    img_exp = c_exp * img_gray.^gamma;
    img_exp = uint8(min(max(img_exp, 0), 255)); % 转换回uint8以显示

    % 显示所有处理后的图像在一个figure窗口中
    figure;
    subplot(2,2,1); imshow(uint8(img_gray)); title('原始灰度图像');
    subplot(2,2,2); imshow(img_linear); title('线性变换后的图像');
    subplot(2,2,3); imshow(img_log); title('对数变换后的图像');
    subplot(2,2,4); imshow(img_exp); title('指数变换后的图像');

    % 缩放图像
    scale_factor_1 = 0.75; % 缩小为原来的75%
    resized_img_1 = imresize(img, scale_factor_1);
    subplot(2,3,2); imshow(resized_img_1); title(['缩放比例: ', num2str(scale_factor_1)]);

    scale_factor_2 = 1.5; % 放大1.5倍
    resized_img_2 = imresize(img, scale_factor_2);
    subplot(2,3,3); imshow(resized_img_2); title(['缩放比例: ', num2str(scale_factor_2)]);

    % 旋转图像
    rotation_angle_1 = 45; % 逆时针旋转45度
    rotated_img_1 = imrotate(img, rotation_angle_1, 'bilinear', 'loose');
    subplot(2,3,4); imshow(rotated_img_1); title(['旋转角度: ', num2str(rotation_angle_1), '度']);

    rotation_angle_2 = -30; % 顺时针旋转30度
    rotated_img_2 = imrotate(img, rotation_angle_2, 'bilinear', 'loose');
    subplot(2,3,5); imshow(rotated_img_2); title(['旋转角度: ', num2str(rotation_angle_2), '度']);

    % 结合缩放和旋转
    combined_transformed_img = imrotate(imresize(img, 0.75), 45, 'bilinear', 'loose');
    subplot(2,3,6); imshow(combined_transformed_img); title('缩放与旋转结合');

    % 添加噪声并显示
    figure;
    noise_types = {'gaussian', 'saltpepper'};
    noisy_images = cell(size(noise_types));
    for i = 1:length(noise_types)
        noisy_images{i} = add_noise(img_gray, noise_types{i});
        subplot(2,4,i+4); imshow(noisy_images{i}); title([noise_types{i}, ' 噪声']);
    end

    % 空域滤波
    spatial_filtered_images = cell(size(noise_types));
    for i = 1:length(noise_types)
        spatial_filtered_images{i} = spatial_filter(noisy_images{i});
        subplot(2,4,i+6); imshow(spatial_filtered_images{i}); title([noise_types{i}, ' - 空域滤波']);
    end

    % 频域滤波（这里分别对高斯噪声和椒盐噪声进行演示）
    freq_filtered_image_gaussian = frequency_domain_filter(noisy_images{1}, 'gaussian');
    freq_filtered_image_saltpepper = frequency_domain_filter(noisy_images{2}, 'saltpepper');
    
    subplot(2,4,12); imshow(freq_filtered_image_gaussian); title('高斯噪声 - 频域滤波');
    subplot(2,4,13); imshow(freq_filtered_image_saltpepper); title('椒盐噪声 - 频域滤波');
end

function h = nHistogram(I)
    % 计算归一化的直方图
    h = imhist(I);
    h = h / sum(h);
end

function noisy_img = add_noise(img, noise_type)
    switch lower(noise_type)
        case 'gaussian'
            % 添加均值为0，方差为0.01的高斯噪声
            noisy_img = imnoise(img, 'gaussian', 0, 0.01);
        case 'saltpepper'
            % 添加密度为0.05的椒盐噪声
            noisy_img = imnoise(img, 'salt & pepper', 0.05);
        otherwise
            error('未知的噪声类型');
    end
end

function filtered_img = spatial_filter(img)
    % 使用中值滤波器去除噪声，适用于椒盐噪声
    filtered_img = medfilt2(img, [3 3]);
end

function filtered_img = frequency_domain_filter(img, noise_type)
    % 创建一个低通巴特沃斯滤波器
    H = fspecial('gaussian', [50 50], 10); % 滤波器大小和标准偏差
    
    % 获取图像的尺寸
    [M, N] = size(img);
    
    % 转换到频域
    F = fftshift(fft2(double(img)));
    
    % 调整滤波器矩阵的尺寸以匹配图像的尺寸
    H = padarray(H, [(M-size(H,1))/2 (N-size(H,2))/2], 'symmetric');
    
    % 应用滤波器
    G = F .* fftshift(H);
    
    % 转换回空域
    filtered_img = real(ifft2(ifftshift(G)));
    
    % 归一化处理
    filtered_img = uint8(mat2gray(filtered_img) * 255);
end



