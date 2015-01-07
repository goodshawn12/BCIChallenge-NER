addpath('trainDataEEGLAB2/')
addpath('testDataEEGLAB2/')
temp = dir('trainDataEEGLAB2/');

test = [1 3 4 5 8 9 10 15 19 25];
train = setdiff(1:26,test);

% high-pass --> re-referemce --> epoch --> remove baseline
dataTrain = {struct('data',[],'label',[])};
dataTrain = repmat(dataTrain,length(train),5);
for itSub = 1:length(train)
    subj = train(itSub);
    disp(num2str(subj))
    for itSes = 1:5;
        EEG2 = pop_loadset(['Data_S' num2str(subj,'%.2d') '_Sess0' num2str(itSes) '.set']);
        [EEG2.event.type] = deal('result');
        % bp filter
        EEG2 = pop_eegfiltnew(EEG2,1,45);
        % ASR
        EEG2 = clean_artifacts(EEG2,'WindowCriterion','off','ChannelCriterion','off');
        % down sample
        EEG2 = pop_resample(EEG2,100);
        % epoch
        EEG2 = pop_epoch(EEG2,{'result'},[-0.2 0.6]);
        EEG2.data = rmbase(EEG2.data,[]);
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
        [EEG2.event.type] = deal('result');
        % bp filter
        EEG2 = pop_eegfiltnew(EEG2,1,45);
        % ASR
        EEG2 = clean_artifacts(EEG2,'WindowCriterion','off','ChannelCriterion','off');
        % down sample
        EEG2 = pop_resample(EEG2,100);
        % epoch
        EEG2 = pop_epoch(EEG2,{'result'},[-0.2 0.6]);
        EEG2.data = rmbase(EEG2.data,[]);

%         % keep only Cz
%         EEG2 = pop_select(EEG2,'channel',{'Cz'});
%         % epoch
%         [EEG2.event.type] = deal('result');
%         EEG2 = pop_epoch(EEG2,{'result'},[0 0.6]);
%         % bp filter
%         EEG2 = pop_eegfiltnew(EEG2,0.5,50);
%         % down sample
%         EEG2 = pop_resample(EEG2,100);
%         % artifact removal
%         arg_flatline = 5; arg_highpass = [0.25 0.75]; arg_channel = 0.85; arg_noisy = 4; arg_burst = 5; arg_window = 0.25;
%         EEG2 = clean_rawdata(EEG2, arg_flatline, arg_highpass, arg_channel, arg_noisy, arg_burst, arg_window);
        % save
        for itTrial = 1:size(EEG2.data,3)
            dataTest{itSub,itSes}(itTrial).data = EEG2.data(:,:,itTrial)';
        end
    end
end

save('inputDataClean','dataTrain','dataTest')