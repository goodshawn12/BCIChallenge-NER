function [classifier_model] = classifier_training(feature_flow_train, param)
% Ping-Keng Jao Jan. 5 2015
[train_data, train_label] = get_data(feature_flow_train);
%% run classifier
switch upper(param.classifier_type)
    case 'LINEARSVM'
        %% training        
        train_data = sparse(train_data)';
        train_label(train_label==0) = -1; % original is {0,1}, but SVM needs {-1,1}
        [classifier_model] = liblinearTr(train_data, train_label, param.linearsvm);
    case 'LIBSVM'
        %% training        
        train_data = sparse(train_data)';
        train_label(train_label==2) = -1; % original is {0,1}, but SVM needs {-1,1}
        classifier_model = libSVMTr(train_data, train_label, param.libsvm);
    case 'GNB' % Gaussian Naive Bayesian
        %% training
        train_data = sparse(train_data)';
        train_label(train_label==2) = -1; % original is {0,1}. SVM needs {-1,1}, although it is GNB.
        classifier_model = GNB_train(train_data, train_label, param.gnb);
end % end of classifier
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