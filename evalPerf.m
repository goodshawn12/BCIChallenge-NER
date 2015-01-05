% Evaluation of binary classification result
% Reference: http://en.wikipedia.org/wiki/Receiver_operating_characteristic
function evalPerf(predictions, true_labels)

% use Matlab stat toolbox
[ X, Y, ~, auc ] = perfcurve(true_labels, predictions, 1);

% display results
fprintf('AUC:%f\n',auc);
figure, plot(X,Y); xlabel('false-positive rate (FP/N)'); ylabel('true-positive rate (TP/P)');
title('Receiver operating characteristic (ROC)'); 
