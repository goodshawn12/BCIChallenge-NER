function [train_data, test_data, selectCSPmodel] = CSP_processor(train_data,test_data,CSPmodel)

% apply CSP model on training and testing data
selectCSPmodel = CSPmodel{1}; % first subject
% train data
[nsubj, nsession] = size(train_data);
for sub = 1:nsubj
    for ses = 1:nsession
        ntrial = length(train_data{sub, ses});
        for tri = 1:ntrial
            train_data{sub, ses}(tri).data = selectCSPmodel * reshape(train_data{sub, ses}(tri).data,56,[]);          
        end
    end
end
% test data
[nsubj, nsession] = size(test_data);
for sub = 1:nsubj
    for ses = 1:nsession
        ntrial = length(test_data{sub, ses});
        for tri = 1:ntrial
            test_data{sub, ses}(tri).data = selectCSPmodel * reshape(train_data{sub, ses}(tri).data,56,[]);          
        end
    end
end


