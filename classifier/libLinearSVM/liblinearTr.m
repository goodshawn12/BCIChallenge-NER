% Support vector machine training for two class problem using liblinear
% Ping-Keng Jao 2014/12/31
% Chin Chia Yeh 2013/3/21
%
% svm_mod = liblinearTr(inst, lab)
%
% OUTPUT
% svm_mod: the result svm model
%
% INPUT
% bag: bag of instance
% lab: true label for each bag
%
% OPTIONAL INPUTS
% 'csearch': a vector contains all the possible c's for prarmeter search.
%            if the input is a scaler, c will be set to the input value.
%            default = 2 ^ 3;
%
% 'csfold': the number of fold for parameter search.
%           default = 5;
%
% 'verbose': how much you want this function to annoy you
%  0: no output
%  1: output
% default = 1;
%

function svm_mod = liblinearTr(inst, lab, param)
%% initialization
if ~issparse(inst)
    inst = sparse(inst);
end
lab = double(lab);
if issparse(lab)
    lab = full(lab);
end
csearch = 2 ^ 3;
csfold = 5;
w0 = 1;
verbose = 0;
s = 2;
B = 1;

if isfield(param, 's')
    verbose = param.s;
end
if isfield(param, 'csearch')
    csearch = param.csearch;
end
if isfield(param, 'csfold')
    csfold = param.csfold;
end
if isfield(param, 'w0')
    w0 = param.w0;
end
if isfield(param, 'B')
    verbose = param.B;
end
if isfield(param, 'verbose')
    verbose = param.verbose;
end


%% parameter serach (c)
if length(csearch) ~= 1
    best_acc = 0;
    best_c = 1;
    for c = csearch
        if verbose
%             acc_ = train(lab, inst, [' -c ' num2str(c) ' -s ' num2str(s) ...
%                 ' -B ' num2str(B) ' -v ' num2str(csfold) ' -w0 ' num2str(w0) ' -q']);
            acc_ = balanced_kfold_crossvalidation(lab, inst, c, s, B, w0, csfold);
            disp(['current c: ' num2str(c) ...s
                ' current accuracy:' num2str(acc_)]);
        else
%             train_cmd = ['acc_ = train(lab, inst, ['' -c '' num2str(c) ' ...
%                 ''' -s '' num2str(s) '' -B '' num2str(B) '' -v '' num2str(csfold) '...
%                 ''' -w0 '' num2str(w0) '' -q'']);'];
            train_cmd = ['acc_ = balanced_kfold_crossvalidation(lab, inst, c, s, B, w0, csfold);'];
            [~] = evalc(train_cmd);
        end
        if acc_ >= best_acc
            best_acc = acc_;
            best_c = c;
        end
    end
else
    best_c = csearch;
end

%% train the svm model
% note: no -v, so output is model
svm_mod = train(lab, inst, [' -c ' num2str(best_c) ' -s ' num2str(s) ' -B ' ...
                            num2str(B) ' -w0 ' num2str(w0) ' -q']);

end                 
%% balanced samples
function acc = balanced_kfold_crossvalidation(lab, inst, c, s, B, w0, csfold)
%% generate more balanced random fold split
inst_n = length(lab);
class = unique(lab);
p_idx = find(lab == max(class));
n_idx = find(lab == min(class));

if length(p_idx) < csfold
   warning(['Your csfold is too large, you only have %d positive ', ... 
       'examples while your csfold is %d.'], length(p_idx), csfold); 
   csfold = length(p_idx);
end

p_idx = p_idx(randperm(length(p_idx)));
n_idx = n_idx(randperm(length(n_idx)));

sample_num = min(length(p_idx), length(n_idx));
idx = [p_idx(1:sample_num); n_idx(1:sample_num)];

fold_idx = cell(csfold, 1);
for i = 1:csfold
   fold_idx{i} = idx(i:csfold:length(idx));
end

%% corss-validataion
acc = zeros(csfold, 1);
for i = 1:csfold
    te_idx = false(inst_n, 1);
    te_idx(fold_idx{i}) = true;
    tr_idx = ~te_idx;
    
    te_lab = lab(te_idx);
    tr_lab = lab(tr_idx);
    te_inst = inst(te_idx, :);
    tr_inst = inst(tr_idx, :);
    svm_mod = train(tr_lab, tr_inst, [' -c ' num2str(c) ' -s ' num2str(s) ...
                ' -B ' num2str(B) ' -w0 ' num2str(w0) ' -q']);
    [labPr, ~]  = liblinearPr(te_inst, svm_mod)
    acc(i) = sum(labPr == te_lab)/length(te_lab);
end
acc = mean(acc);
end

%% not totally balanced samples
function acc = kfold_crossvalidation(lab, inst, c, s, B, w0, csfold)
%% generate more balanced random fold split
inst_n = length(lab);
class = unique(lab);
p_idx = find(lab == max(class));
n_idx = find(lab == min(class));

if length(p_idx) < csfold
   warning(['Your csfold is too large, you only have %d positive ', ... 
       'examples while your csfold is %d.'], length(p_idx), csfold); 
   csfold = length(p_idx);
end

p_idx = p_idx(randperm(length(p_idx)));
n_idx = n_idx(randperm(length(n_idx)));

idx = [p_idx; n_idx];

fold_idx = cell(csfold, 1);
for i = 1:csfold
   fold_idx{i} = idx(i:csfold:inst_n);
end

%% corss-validataion
acc = zeros(csfold, 1);
for i = 1:csfold
    te_idx = false(inst_n, 1);
    te_idx(fold_idx{i}) = true;
    tr_idx = ~te_idx;
    
    te_lab = lab(te_idx);
    tr_lab = lab(tr_idx);
    te_inst = inst(te_idx, :);
    tr_inst = inst(tr_idx, :);
    svm_mod = train(tr_lab, tr_inst, [' -c ' num2str(c) ' -s ' num2str(s) ...
                ' -B ' num2str(B) ' -w0 ' num2str(w0) ' -q']);
    [labPr, ~]  = liblinearPr(te_inst, svm_mod)
    acc(i) = sum(labPr == te_lab)/length(te_lab);
end
acc = mean(acc);
end
