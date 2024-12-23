function function6_7()
    % 1. 加载图像
    [filename, pathname] = uigetfile({'*.jpg; *.jpeg; *.png; *.bmp', '所有图像文件'; '*.*', '所有文件'}, '选择一个图像文件');
    if ischar(filename)
        img = imread(fullfile(pathname, filename));
    else
        error('没有选择文件');
    end

    % 2. 预处理：将图像转换为灰度图像
    gray_img = im2gray(img);

    % 3. 自适应阈值分割
    adapthist_eq = adapthisteq(gray_img);
    bw_img = imbinarize(adapthist_eq);

    % 4. 形态学操作：开运算和闭运算
    se = strel('disk', 5); % 定义圆形结构元素，半径为5
    bw_opened = imopen(bw_img, se); % 开运算
    bw_closed = imclose(bw_opened, se); % 闭运算

    % 5. 边界检测（可选）
    edges = edge(double(bw_closed), 'canny'); % 使用Canny算子检测边缘

    % 6. 提取连通组件
    cc = bwconncomp(bw_closed);
    stats = regionprops(cc, 'Area', 'Centroid', 'Eccentricity');
    areas = [stats.Area];
    [~, idx] = max(areas); % 找出面积最大的连通区域
    mask = false(size(bw_closed));
    mask(cc.PixelIdxList{idx}) = true; % 创建掩膜以显示最大连通区域

    % 7. 可视化结果
    figure;
    subplot(2,3,1); imshow(img); title('原始图像');
    subplot(2,3,2); imshow(gray_img, []); title('灰度图像');
    subplot(2,3,3); imshow(bw_img); title('二值化图像');
    subplot(2,3,4); imshow(bw_closed); title('清理后的二值图像');
    subplot(2,3,5); imshow(edges); title('边缘检测结果');
    subplot(2,3,6); imshow(label2rgb(mask, @jet, [.7 .7 .7])); title('提取的目标');

    % 8. 特征提取（LBP和HOG）
    % LBP特征提取
    lbp_features_original = extractLBPFeatures(gray_img);
    lbp_features_target = extractLBPFeatures(uint8(mask .* 255));

    % HOG特征提取
    hog_features_original = extractHOGFeatures(gray_img);
    hog_features_target = extractHOGFeatures(uint8(mask .* 255));

    % 显示特征向量
    disp('LBP特征（原始图像）:');
    disp(lbp_features_original);
    disp('LBP特征（提取目标）:');
    disp(lbp_features_target);
    disp('HOG特征（原始图像）:');
    disp(hog_features_original);
    disp('HOG特征（提取目标）:');
    disp(hog_features_target);
end

function lbp_features = extractLBPFeatures(image)
    % 将图像转换为灰度图像
    gray_image = image; % 已经是灰度图像
    
    % 计算LBP特征
    P = 8; % 半径为8个像素点
    R = 1; % 半径为1个像素点
    lbp_filter = localBinaryPattern(gray_image, P, R);
    
    % 计算直方图
    histogram = imhist(lbp_filter);
    
    % 归一化直方图
    lbp_features = histogram / sum(histogram);
end

function lbp = localBinaryPattern(image, P, R)
    % 计算局部二值模式 (LBP) 特征
    [height, width] = size(image);
    lbp = zeros(height, width);
    
    for i = 1:height
        for j = 1:width
            center_pixel = image(i, j);
            pattern = 0;
            
            for k = 1:P
                theta = 2 * pi * (k - 1) / P;
                x = round(R * cos(theta)) + j;
                y = round(R * sin(theta)) + i;
                
                if x >= 1 && x <= width && y >= 1 && y <= height
                    neighbor_pixel = image(y, x);
                    if neighbor_pixel >= center_pixel
                        pattern = pattern + 2^(k - 1);
                    end
                end
            end
            
            lbp(i, j) = pattern;
        end
    end
    
    return;
end

function hog_features = extractHOGFeatures(image)
    % 直接使用MATLAB内置的extractHOGFeatures函数计算HOG特征
    hog_features = extractHOGFeatures(image);
end