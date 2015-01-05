function [labPr, detail_acc] = classifier_testing(feature_flow_test, classifier_model, param)
% Ping-Keng Jao Jan. 5 2015
[test_data,  test_label]  = get_data(feature_flow_test);
%% run classifier
switch upper(param.classifier_type)
    case 'LINEARSVM'
        %% testing        
        test_data = sparse(test_data)';
        test_label(test_label==2) = -1;
        [labPr, decVal]  = liblinearPr(test_data, classifier_model);
    case 'LIBSVM'
        %% testing        
        test_data = sparse(test_data)';
        test_label(test_label==2) = -1;
        [labPr, decVal]  = libSVMPr(test_data, classifier_model);
    case 'GNB' % Gaussian Naive Bayesian
        %% testing
        test_data = sparse(test_data)';
        test_label(test_label==2) = -1;
        [post, labPr, logp] = posterior(classifier_model, test_data);
end % end of classifier
%% calculate accuracy
detail_acc = sum(labPr == test_label)/length(test_label);
end % end of function


%% auxilary function
function [data, label] = get_data(in_data)
    data = [];
    label = [];
    [nsubj, nsession, ntrial] = size(in_data);
    for sub = 1:nsubj        
        for ses = 1:nsession
            for tri = 1:ntrial
                data  = [data in_data(sub, ses, tri).data];
                label = [label; in_data(sub, ses, tri).lab];
            end
        end
    end
end