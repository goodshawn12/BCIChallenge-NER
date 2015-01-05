function [labPr] = epoch_to_classify_test(in_data, classifier_model, norm_model, svm_param)
%% Vectorize
[nsubj, nsession] = size(in_data);
for sub = 1:nsubj
    for ses = 1:nsession
        ntrial = length(in_data(sub, ses));
        for tri = 1:ntrial
            in_data{sub, ses}(tri).data  = in_data{sub, ses}(tri).data(:);            
        end
    end
end
%% Normalization
% get all data first, as normalization may need training
data = get_data(in_data);
% normalization
for sub = 1:nsubj
    for ses = 1:nsession
        ntrial = length(in_data(sub, ses));
        for tri = 1:ntrial
            in_data{sub, ses}(tri).data  = ...
                norm_model(in_data{sub, ses}(tri).data);            
        end
    end
end
%% Classifier training
labPr = classifier_testing(in_data, classifier_model, svm_param);

end

%% auxilary function
function [data] = get_data(in_data)
    data = [];
    [nsubj, nsession] = size(in_data);
    for sub = 1:nsubj        
        for ses = 1:nsession
            ntrial = length(in_data(sub, ses));
            for tri = 1:ntrial
                data = [data in_data{sub, ses}(tri).data];               
            end
        end
    end
end