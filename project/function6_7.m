function function6_7()
    % 从文件夹中选择图片
    [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files'}, 'Select an image');
    if isequal(filename, 0)
        disp('用户选择了取消');
        return;
    else
        imagePath = fullfile(pathname, filename);
        disp(['用户选择的图像: ', imagePath]);
    end

    % 读入图像
    try
        Image = imread(imagePath);
    catch ME
        error('读取图像文件失败: %s', ME.message);
        return;
    end

    % 转换为灰度图
    gray = im2double(rgb2gray(Image));

    % 形态学梯度
    se = strel('disk', 2);
    edgeI = imdilate(gray, se) - imerode(gray, se);

    % 对比度增强
    enedgeI = imadjust(edgeI);

    % 梯度图像二值化
    BW = zeros(size(gray));
    BW(enedgeI > 0.1) = 1;

    % 闭运算闭合边界
    BW1 = imclose(BW, se);

    % 区域填充
    BW2 = imfill(BW1, 'holes');

    % 目标模板
    template = cat(3, BW2, BW2, BW2);

    % 目标提取
    result = template .* im2double(Image);

    % 显示结果
    figure;
    subplot(231), imshow(Image), title('原始图像');
    subplot(232), imshow(edgeI), title('形态学梯度');
    subplot(233), imshow(enedgeI), title('对比度增强');
    subplot(234), imshow(BW), title('梯度图像二值化');
    subplot(235), imshow(BW2), title('目标掩模');
    subplot(236), imshow(result), title('提取的目标');

    % 特征提取：LBP和HOG
    % LBP特征提取
    lbpFeaturesOrig = extractLBPFeatures(gray);
    lbpFeaturesTarget = extractLBPFeatures(rgb2gray(result));

    % HOG特征提取
    hogFeaturesOrig = extractHOGFeatures(Image);
    hogFeaturesTarget = extractHOGFeatures(result);

    % 显示特征提取结果
    figure;
    subplot(221), bar(lbpFeaturesOrig), title('原始图像的LBP特征');
    subplot(222), bar(lbpFeaturesTarget), title('提取目标的LBP特征');
    subplot(223), plot(hogFeaturesOrig), title('原始图像的HOG特征');
    subplot(224), plot(hogFeaturesTarget), title('提取目标的HOG特征');
end

% 提取LBP特征的辅助函数
function features = extractLBPFeatures(grayImage)
    P = 8; R = 1; % LBP参数
    [height, width] = size(grayImage);
    lbpImage = zeros(size(grayImage), 'like', grayImage);
    
    for i = R+1:height-R
        for j = R+1:width-R
            centerPixel = double(grayImage(i, j));
            code = 0;
            for n = 1:P
                angle = 2 * pi / P * (n-1);
                x = round(i + R * cos(angle));
                y = round(j - R * sin(angle));

                % 确保坐标在图像边界内
                if x >= 1 && x <= height && y >= 1 && y <= width
                    value = double(grayImage(x, y));
                    code = bitshift(code, 1) + double(value >= centerPixel);
                end
            end
            lbpImage(i, j) = code;
        end
    end
    
    % 计算并归一化直方图
    histogram = histcounts(double(lbpImage(:)), 0:(2^P)-1);
    features = histogram / sum(histogram);
end