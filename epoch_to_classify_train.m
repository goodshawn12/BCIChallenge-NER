function [classifier_model, norm_model, fscore_model] = epoch_to_classify_train(in_data, svm_param, norm_setting)
%% Vectorize
[nsubj, nsession] = size(in_data);
for sub = 1:nsubj
    for ses = 1:nsession
        ntrial = length(in_data{sub, ses});
        for tri = 1:ntrial
            in_data{sub, ses}(tri).data  = in_data{sub, ses}(tri).data(:);            
        end
    end
end
%% Normalization
% get all data first, as normalization may need training
[data, label] = get_data(in_data);
% normalization
[data, norm_model] = normalization_function(data, norm_setting);
%% F-score selection
[fscore_model.FsValue, fscore_model.FsIndex, fscore_model.PValue]= ...
    Feat_Fscore(data, label);
id = find(fscore_model.PValue < 0.05); % p-value
if isempty(id) % if p value is too small, choose first two features
    id = 1:2;
end
target_idx = fscore_model.FsIndex(id);
% put data back
i = 1;
for sub = 1:nsubj
    for ses = 1:nsession
        ntrial = length(in_data{sub, ses});
        for tri = 1:ntrial
            in_data{sub, ses}(tri).data  = data(target_idx,i);
            i = i+1;
        end
    end
end
%% Classifier training
[classifier_model] = classifier_training(in_data, svm_param);

end

%% auxilary function
function [data, label] = get_data(in_data)
    data = [];
    label = [];
    [nsubj, nsession] = size(in_data);
    for sub = 1:nsubj        
        for ses = 1:nsession
            ntrial = length(in_data{sub, ses});
            for tri = 1:ntrial
                data = [data in_data{sub, ses}(tri).data]; 
                label = [label in_data{sub, ses}(tri).label];
            end
        end
    end
end

function [data] = get_data2(in_data, lll)
    data = [];
    [nsubj, nsession] = size(in_data);
    for sub = 1:nsubj        
        for ses = 1:nsession
            ntrial = length(in_data{sub, ses});
            for tri = 1:ntrial
                if in_data{sub, ses}(tri).label == lll
                    data = [data in_data{sub, ses}(tri).data];
                end
            end
        end
    end
end