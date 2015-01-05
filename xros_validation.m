function [best_labPr, best_acc] = xros_validation(train_data, test_data, norm_setting, svm_param)
%% Cross validation, although not implemented yet......
[classifier_model, norm_model] = epoch_to_classify_train(train_data, svm_param, norm_setting);
[best_labPr, best_acc] = epoch_to_classify_test(test_data, classifier_model, norm_model, svm_param);
end