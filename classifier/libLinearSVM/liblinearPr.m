% Support vector machine prediction for two class problem using liblinear
% Ping-Keng Jao 2014/12/31
% Chin Chia Yeh 2013/3/21
%
% [labPr, decVal] = liblinearPr(inst, svm_mod)
%
% OUTPUT
% labPr: predicted label
% decVal: decision value
%
% INPUT
% bag: bag of instance
% svm_mod: a trained svm model
%
% OPTIONAL INPUTS
% 'verbose': how much you want this function to annoy you
%  0: no output
%  1: output
% default = 1;
%

function [labPr, decVal]  = liblinearPr(inst, svm_mod, varargin)
%% initialization
verbose = 0;
for var_i = 1:length(varargin)
    if strcmp(varargin{var_i}, 'verbose')
        verbose = varargin{var_i + 1};
    end
end

instN = size(inst, 1);
if ~issparse(inst)
    inst = sparse(inst);
end
lab_dummy = full(double(zeros(instN, 1)));

%% predict
if verbose
    [labPr, ~, decVal] = predict(lab_dummy, inst, svm_mod);
else
    [~] = evalc('[labPr, ~, decVal] = predict(lab_dummy, inst, svm_mod);');
end
[~, tru_pos_idx] = max(svm_mod.Label);
if tru_pos_idx == 2
    decVal = - decVal;
end