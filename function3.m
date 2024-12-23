function function3()
    % 打开一幅图像
    [filename, pathname] = uigetfile({'*.jpg; *.jpeg; *.png; *.bmp', '所有图像文件'; '*.*', '所有文件'}, '选择一个图像文件');
    if ischar(filename)
        img = imread(fullfile(pathname, filename));
    else
        error('没有选择文件');
    end

    % 显示原始图像
    figure;
    subplot(2,3,1); imshow(img); title('原始图像');

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
end