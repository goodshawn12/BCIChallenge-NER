%% path setting
addpath(genpath('./'));

%% Main script for BCI challenge

% 1. import data - EEG sturcture
% 2. pre-processing steps (BPF, Re-sampling, artifact removal)
% 3. feature extraction (time-domain, frequency, derivative information,
% multi-scale entropy)
% 4. convert features to train_data / test_data
% 5. throw features into classifiers
% 6. output results


%% Import EEG data and labels

data = load('inputDataCz.mat');
train_data = data.dataTrain;
test_data = data.dataTest;

%% Pre-process the data of each subject
% loaded data are already processed 
% % band-pass filtering
% lowcut = 0.5; highcut = 50; filterorder = [];
% EEG = pop_eegfiltnew(EEG, lowcut, highcut, filterorder, 0, [], 1);
% 
% % resampling
% resampleRate = 100;
% EEG = pop_resample(EEG, resampleRate);
% 
% % artifact removal


%% Feature extractions


%% Define settings
% normalization method
norm_setting = 6; % 5: z-score {[5], [6], [7], [8], [9], [3 9], [6 9]};
% classifier parameters
svm_param.classifier_type = 'LINEARSVM';
svm_param.linearsvm = [];
svm_param.libsvm = [];
svm_param.gnb.csfold = 5;

%% Training and cross validation
[classifier_model, norm_model] = epoch_to_classify_train(train_data, svm_param, norm_setting);

% evaluate performance
% evalPerf(predictions, true_labels);

%% Classification of testing data
predictions = epoch_to_classify_test(test_data, classifier_model, norm_model, svm_param);


%% Write output file
filename = 'Results.csv';
writeOutput(predictions, filename);



%% search
    % supported normalization
    %   0: nothing
    %   1: sum to one
    %   2: square root
    %   3: cube root
    %   4: tf-idf]
    %   5: z-score
    %   6: z-score (normalize to self)
    %   7: Euclidean
    %   8: normalize each row of a matrix to [0 1] (along 2nd dimension)
    %   9: normalize to [0 1] to self

% best_i = 0;
% best_acc = 0;
% for i = 1:length(norm_search)
%     norm_setting = norm_search{i};
%     [labPr, acc] = xros_validation(train_data, test_data, norm_setting, svm_param);
%     if best_acc < acc
%         best_i = i;
%         best_labPr = labPr;
%         best_acc = acc;
%     end
% end