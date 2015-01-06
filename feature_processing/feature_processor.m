function [train_data] = feature_processor(train_data)
%% Taking derivative
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

% %% PCA
% % training
% [mappedX, model.pca_mapping] = pca(X, no_dims, verbose)
% feat = pca_maping(feat, map)

end