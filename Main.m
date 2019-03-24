%% Project Title: Paddy Leaf Disease Detection

clc
close all 
clear all

while (1==1)
    choice=menu('Paddy Leaf Disease Detection','Detect Disease Or Not','Exit');
    
    if (choice==1)
        %% Image Read
        [filename, pathname] = uigetfile({'*.*';'*.bmp';'*.jpg';'*.gif'}, 'Pick a Leaf Image File');
        I = imread([pathname,filename]);
        I = imresize(I,[1000,260]);
        figure, imshow(I); title('RGB');

        
        %% Create Mask Or Segmentation Image
        [I3,RGB] = createMask(I);
        seg_img = RGB;
        figure, imshow(I3); title('BW Image');
        figure, imshow(seg_img); title('Segmented Image');
        
        
        %% Feature Extraction
        % Convert to grayscale if image is RGB
        img = rgb2gray(seg_img);
        figure, imshow(img); title('Grayscale Image');
        %figure, imshow(img); title('Gray Scale Image');

        % Create the Gray Level Cooccurance Matrices (GLCMs)
        glcms = graycomatrix(img);

        % Derive Statistics from GLCM
        stats = graycoprops(glcms,'Contrast Correlation Energy Homogeneity');

        Contrast = stats.Contrast;
        Energy = stats.Energy;
        Homogeneity = stats.Homogeneity;
        Mean = mean2(seg_img);
        Standard_Deviation = std2(seg_img);
        Entropy = entropy(seg_img);
        RMS = mean2(rms(seg_img));
        %Skewness = skewness(img)
        Variance = mean2(var(double(seg_img)));
        a = sum(double(seg_img(:)));
        Smoothness = 1-(1/(1+a));
        % Inverse Difference Movement
        m = size(seg_img,1);
        n = size(seg_img,2);
        in_diff = 0;
        for i = 1:m
            for j = 1:n
                temp = seg_img(i,j)./(1+(i-j).^2);
                in_diff = in_diff+temp;
            end
        end
        IDM = double(in_diff);

        feat_disease = [Contrast,Energy,Homogeneity, Mean, Standard_Deviation, Entropy, RMS, Variance, Smoothness, IDM]
        
        
        %% SVM Classifier
        % Load All The Features
        load('Training_Data.mat')

        % Put the test features into variable 'test'
        test = feat_disease;
        result = multisvm(Train_Feat,Train_Label,test);
        %disp(result);

        
        %% Visualize Results
        if result == 0
            helpdlg(' Disease Detect ');
            disp(' Disease Detect ');
        else
            helpdlg(' Disease not Detect ');
            disp('Disease not Detect');
        end
    end
    if (choice==2)
        close all;
        return;
    end
end