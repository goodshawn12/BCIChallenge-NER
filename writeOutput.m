function writeOutput(predictions)

nSubj = 10;
nSess = 5;
nTr = 60; % 5th session has 100 trials
extraTr = 40;
subjTr = nSess*nTr+extraTr;
totalTr = nSubj*subjTr;

subjIdx = [ 1, 3, 4, 5, 8, 9, 10, 15, 19, 25];

% subjIdx = ['01', '03', '04', '05', '08', '09', '10', '15', '19', '25'};
% RESULTS = {};
% for it = 1:totalTr
%     subjID = subjIdx{ceil(it/(nSess*nTr+40))};
%     sessID = ceil(rem(it,nSess*nTr+40)/nTr);
%     if sessID == 6, sessID = 5; end
%     
%     id = sprintf('S%s_Sess%s_FB%3s',subjIdx(), )
% RESULTS = {RESULTS; 'S01_Sess01_FB001', 0}';

RESULTS = cell(totalTr,2);
for it1 = 1:nSubj
    for it2 = 1:nSess
        for it3 = 1:nTr
            idNum = it3+(it2-1)*nTr+(it1-1)*subjTr;
            idTr = sprintf('S%02d_Sess%02d_FB%03d',subjIdx(it1),it2,it3);
            RESULTS(idNum,:) = {idTr, predictions(idNum)};
        end
        if it2 == nSess
            for it3 = nTr+1:nTr+extraTr
                idNum = it3+(it2-1)*nTr+(it1-1)*subjTr;
                idTr = sprintf('S%02d_Sess%02d_FB%03d',subjIdx(it1),it2,it3);
                RESULTS(idNum,:) = {idTr, predictions(idNum)};
            end
        end
    end
end
              
T = cell2table(RESULTS,'VariableNames',{'IdFeedBack','Prediction'});
writetable(T,'Sample.csv');
% type Sample.csv
