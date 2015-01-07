% Fscore():  Sorting the variable with Fscore value in descending order.
% 
% Input:     Data (NumFeat,NumPoint)
%            Label (1,NumPoint)
%
% Output:    FsValue (NumFeat, 1): Fscore value (descending)
%            FsIndex (NumFeat, 1): associated feat index 
%            PValue (NumFeat, 1): associated Pvalue 
%
% Modified date: 2013.4.23 YPL  - initial version

function [FsValue,FsIndex,PValue]=Feat_Fscore(Data,Label)

NumFeat=size(Data,1);
Matrix=zeros(NumFeat,2);
for FeatIdx=1:NumFeat
   [Pvalue,table]=anovan(Data(FeatIdx,:),Label','display','off');
   Matrix(FeatIdx,1) = table{2,6};          % Fscore
   Matrix(FeatIdx,2) = Pvalue;              % P-value
end  
[FsValue,FsIndex]=sort(Matrix(:,1),'descend');
PValue=Matrix(FsIndex,2);