%% path setting
addpath(genpath('./'));
%% search space setting
norm_search = {[5], [6], [7], [8], [9], [3 9], [6 9]};
    % supported normalization
    %   0: nothing
    %   1: sum to one
    %   2: square root
    %   3: cube root
    %   4: tf-idf
    %   5: z-score
    %   6: z-score (normalize to self)
    %   7: Euclidean
    %   8: normalize each row of a matrix to [0 1] (along 2nd dimension)
    %   9: normalize to [0 1] to self
svm_param.classifier_type = 'LINEARSVM';
svm_param.linearsvm = [];
svm_param.libsvm = [];
svm_param.gnb = [];
%% search
best_i = 0;
best_acc = 0;
for i = 1:length(norm_search)
    norm_setting = norm_search{i};
    [labPr, acc] = xros_validation(train_data, test_data, norm_setting, svm_param);
    if best_acc < acc
        best_i = i;
        best_labPr = labPr;
        best_acc = acc;
    end
end