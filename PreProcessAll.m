addpath('trainDataEEGLAB2/')
addpath('testDataEEGLAB2/')
temp = dir('trainDataEEGLAB2/');

test = [1 3 4 5 8 9 10 15 19 25];
train = setdiff(1:26,test);


dataTrain = {struct('data',[],'label',[])};
dataTrain = repmat(dataTrain,length(train),5);
for itSub = 1:length(train)
    subj = train(itSub);
    disp(num2str(subj))
    for itSes = 1:5;
        EEG2 = pop_loadset(['Data_S' num2str(subj,'%.2d') '_Sess0' num2str(itSes) '.set']);
        % keep only Cz
        EEG2 = pop_select(EEG2,'channel',{'Cz'});
        % epoch
        [EEG2.event.type] = deal('result');
        EEG2 = pop_epoch(EEG2,{'result'},[0 0.6]);
        % bp filter
        EEG2 = pop_eegfiltnew(EEG2,0.5,50);
        % down sample
        EEG2 = pop_resample(EEG2,100);
        % save
        for itTrial = 1:size(EEG2.data,3)
            dataTrain{itSub,itSes}(itTrial).data = EEG2.data(:,:,itTrial)';
            dataTrain{itSub,itSes}(itTrial).label = EEG2.event(itTrial).correct;
        end
    end
end

dataTest = {struct('data',[],'label',[])};
dataTest = repmat(dataTest,length(test),5);
for itSub = 1:length(test)
    subj = test(itSub);
    disp(num2str(subj))
    for itSes = 1:5;
        EEG2 = pop_loadset(['Data_S' num2str(subj,'%.2d') '_Sess0' num2str(itSes) '.set']);
        % keep only Cz
        EEG2 = pop_select(EEG2,'channel',{'Cz'});
        % epoch
        [EEG2.event.type] = deal('result');
        EEG2 = pop_epoch(EEG2,{'result'},[0 0.6]);
        % bp filter
        EEG2 = pop_eegfiltnew(EEG2,0.5,50);
        % down sample
        EEG2 = pop_resample(EEG2,100);
        % save
        for itTrial = 1:size(EEG2.data,3)
            dataTest{itSub,itSes}(itTrial).data = EEG2.data(:,:,itTrial)';
        end
    end
end

save('inputData','dataTrain','dataTest')