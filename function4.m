function function4()
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
    subplot(2,4,1); imshow(img_gray); title('原始图像');

    % 添加噪声并显示
    noise_types = {'gaussian', 'saltpepper'};
    noisy_images = cell(size(noise_types));
    for i = 1:length(noise_types)
        noisy_images{i} = add_noise(img_gray, noise_types{i});
        subplot(2,4,i+1); imshow(noisy_images{i}); title([noise_types{i}, ' 噪声']);
    end

    % 空域滤波
    spatial_filtered_images = cell(size(noise_types));
    for i = 1:length(noise_types)
        spatial_filtered_images{i} = spatial_filter(noisy_images{i});
        subplot(2,4,i+3); imshow(spatial_filtered_images{i}); title([noise_types{i}, ' - 空域滤波']);
    end

    % 频域滤波（这里分别对高斯噪声和椒盐噪声进行演示）
    freq_filtered_image_gaussian = frequency_domain_filter(noisy_images{1}, 'gaussian');
    freq_filtered_image_saltpepper = frequency_domain_filter(noisy_images{2}, 'saltpepper');
    
    subplot(2,4,7); imshow(freq_filtered_image_gaussian); title('高斯噪声 - 频域滤波');
    subplot(2,4,8); imshow(freq_filtered_image_saltpepper); title('椒盐噪声 - 频域滤波');
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