

load('cleanTrainEEGBySubjectAndResponseAccuracy.mat');
EEGtemp = pop_loadset('Data_S01_Sess01.set');
chanlocs = EEGtemp.chanlocs;

EEG1 = EEG;
EEG2 = EEG;

W = cell(1,length(train0));
CSPTrain = {struct('data',[],'label',[])};
CSPTrain = repmat(CSPTrain,length(train0),1);

% need empty EEG set (can be done by simply opening eeglab)
for subj = 1:length(train0)
    ALLEEG = [];
    
    EEG1.data = train1{subj};
    EEG1.srate = 80;
    EEG1.chanlocs = chanlocs;
    EEG1 = eeg_checkset(EEG1);
    
    EEG2.data = train0{subj};
    EEG2.srate = 80;
    EEG2.chanlocs = chanlocs;
    EEG2 = eeg_checkset(EEG2);
    [ALLEEG] = eeg_store(ALLEEG, EEG1);
    [ALLEEG] = eeg_store(ALLEEG, EEG2);
    
    datasetlist = [1 2]; chansubset = 1:EEG1.nbchan; chansubset2 = 1:EEG2.nbchan; trainingwindowlength = EEG1.pnts; trainingwindowoffset = 1;
    [ALLEEG, W{subj}, D] = pop_csp_mod(ALLEEG,datasetlist, chansubset, chansubset2, trainingwindowlength, trainingwindowoffset);

    for tr = 1:EEG1.trials
        CSPTrain{subj}(tr).data = W{subj}*EEG1.data(:,:,tr);
        CSPTrain{subj}(tr).label = 1;
    end
    for tr = EEG1.trials+1:EEG1.trials+EEG2.trials
        CSPTrain{subj}(tr).data = W{subj}*EEG2.data(:,:,tr-EEG1.trials);
        CSPTrain{subj}(tr).label = 0;
    end

%     pop_topoplot(ALLEEG(1),0,chansubset);
%     figure, imagesc(W{subj});
    close
end

save CSPweights16.mat CSPTrain W

% visualize the difference
subj = 3;
data1 = zeros(56,80); data2 = data1;
count1 = 0;
for tr = 1:340
    if CSPTrain{subj}(tr).label == 1
        data1 = data1 + CSPTrain{subj}(tr).data;
        count1 = count1 + 1;
    else
        data2 = data2 + CSPTrain{subj}(tr).data;
    end
end
data1 = data1 ./ count1;
data2 = data2 ./ (340-count1);

figure,imagesc(data1);
figure,imagesc(data2);
figure,imagesc(data2-data1);

