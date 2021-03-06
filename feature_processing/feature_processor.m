function [train_data, test_data, trained_model] = feature_processor(train_data, test_data, param)
%% Taking derivative
% train data
[nsubj, nsession] = size(train_data);
for sub = 1:nsubj
    for ses = 1:nsession
        ntrial = length(train_data{sub, ses});
        for tri = 1:ntrial
            train_data{sub, ses}(tri).data = ...
                derivative(train_data{sub, ses}(tri).data')';            
        end
    end
end
% test data
[nsubj, nsession] = size(test_data);
for sub = 1:nsubj
    for ses = 1:nsession
        ntrial = length(test_data{sub, ses});
        for tri = 1:ntrial
            test_data{sub, ses}(tri).data = ...
                derivative(test_data{sub, ses}(tri).data')';            
        end
    end
end



%% Sparse coding
[data] = get_data(train_data);
if ~isfield(param, 'ODL')
    param.ODL = [];
end
% dictionary learning
if ~isfield(param.ODL, 'K') % set default value of dictionary size
    param.ODL.K = size(data,1) * 4;
end
if ~isfield(param.ODL, 'lambda') % set default value of alpha
    param.ODL.lambda = 1/sqrt(min(param.ODL.K, size(data,1)));
end
if ~isfield(param.ODL, 'pos') % set default value of positive constraint
    param.ODL.pos = 1;
end
if ~isfield(param.ODL, 'mode') % set default value of positive constraint
    param.ODL.mode = 2;
end
if ~isfield(param.ODL, 'iter') % set default value of positive constraint
    param.ODL.iter = 100;
end
[data, ~] = normalization_function(data', 7);
data = data';
[trained_model.ODL_D] = mexTrainDL_Memory(data, param.ODL);

% set default value of alpha in sparse coding
if ~isfield(param, 'LASSO') % set default value of alpha
    param.LASSO = [];
end
if ~isfield(param.LASSO, 'lambda') % set default value of alpha
    param.LASSO.lambda = 1/sqrt(min(param.ODL.K, size(data,1)));
end
if ~isfield(param.LASSO, 'pos') % set default value of positive constraint
    param.LASSO.pos = 1;
end

data = mexLasso(data, trained_model.ODL_D, param.LASSO);
% put data back
i = 1;
[nsubj, nsession] = size(train_data);
for sub = 1:nsubj
    for ses = 1:nsession
        ntrial = length(train_data{sub, ses});
        for tri = 1:ntrial            
            train_data{sub, ses}(tri).data = data(:,i);
            i = i+1;
        end
    end
end
% taking care with test data
clear data
data = get_data(test_data);
[data, ~] = normalization_function(data', 7);
data = data';
data = mexLasso(data, trained_model.ODL_D, param.LASSO);
% put data back
i = 1;
[nsubj, nsession] = size(test_data);
for sub = 1:nsubj
    for ses = 1:nsession
        ntrial = length(test_data{sub, ses});
        for tri = 1:ntrial
            test_data{sub, ses}(tri).data = data(:,i);
            i = i+1;
        end
    end
end


% %% PCA
% % training
% [mappedX, model.pca_mapping] = pca(X, no_dims, verbose)
% feat = pca_maping(feat, map)

end

%% auxilary function
function [data] = get_data(in_data)
    data = [];
    [nsubj, nsession] = size(in_data);
    for sub = 1:nsubj        
        for ses = 1:nsession
            ntrial = length(in_data{sub, ses});
            for tri = 1:ntrial
                data = [data in_data{sub, ses}(tri).data];               
            end
        end
    end
end