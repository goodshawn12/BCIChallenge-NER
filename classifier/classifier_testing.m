function [labPr] = classifier_testing(feature_flow_test, classifier_model, param)
% Ping-Keng Jao Jan. 5 2015
test_data = get_data(feature_flow_test);
%% run classifier
switch upper(param.classifier_type)
    case 'LINEARSVM'
        %% testing        
        test_data = sparse(test_data)';
        [labPr, decVal]  = liblinearPr(test_data, classifier_model);
    case 'LIBSVM'
        %% testing        
        test_data = sparse(test_data)';
        [labPr, decVal]  = libSVMPr(test_data, classifier_model);
    case 'GNB' % Gaussian Naive Bayesian
        %% testing
        test_data = sparse(test_data)';
        [post, labPr, logp] = posterior(classifier_model, test_data);
end % end of classifier
%% calculate accuracy
% detail_acc = sum(labPr == test_label)/length(test_label);
end % end of function


%% auxilary function
function [data] = get_data(in_data)
    data = [];
    [nsubj, nsession] = size(in_data);
    for sub = 1:nsubj        
        for ses = 1:nsession
            ntrial = length(in_data(sub, ses));
            for tri = 1:ntrial
                data  = [data in_data{sub, ses}(tri).data];
%                 label = [label; in_data{sub, ses}(tri).lab];
            end
        end
    end
end