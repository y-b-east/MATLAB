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

    % 用户输入噪声参数
    noise_types = {'高斯', '椒盐'};
    prompt = {'请输入噪声类型（高斯或椒盐）:', '请输入噪声参数：对于高斯噪声为方差（0-1之间），对于椒盐噪声为密度（0-1之间）:'};
    dlgtitle = '噪声参数';
    dims = [1 50];
    definput = {noise_types{1}, '0.01'};
    answer = inputdlg(prompt, dlgtitle, dims, definput);
    selected_noise_type = lower(answer{1});
    noise_param = str2double(answer{2});

    % 添加噪声并显示
    noisy_img = add_noise(img_gray, selected_noise_type, noise_param);
    subplot(2,4,2); imshow(noisy_img); title([selected_noise_type, ' 噪声']);

    % 空域滤波
    spatial_filtered_img = spatial_filter(noisy_img);
    subplot(2,4,3); imshow(spatial_filtered_img); title([selected_noise_type, ' - 空域滤波']);

    % 频域滤波
    freq_filtered_img = frequency_domain_filter(noisy_img, selected_noise_type);
    subplot(2,4,4); imshow(freq_filtered_img); title([selected_noise_type, ' - 频域滤波']);
end

function noisy_img = add_noise(img, noise_type, param)
    switch lower(noise_type)
        case '高斯'
            % 添加均值为0，指定方差的高斯噪声
            noisy_img = imnoise(img, 'gaussian', 0, param);
        case '椒盐'
            % 添加指定密度的椒盐噪声
            noisy_img = imnoise(img, 'salt & pepper', param);
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