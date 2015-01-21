% Support vector machine training for two class problem using libSVM
% Ping-Keng Jao 2014/10/24
% modified from liblinearTr by Chin Chia Yeh 2013/3/21
%
% svm_mod = libSVMTr(inst, lab, param)
%
% OUTPUT
% svm_mod: the result svm model
%
% INPUT
% inst: bag of instance
% lab: true label for each bag
% param: a structure to overwrite parameters
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

function svm_mod = libSVMTr(inst, lab, param)
%% initialization
if ~issparse(inst)
    inst = sparse(inst);
end
lab = double(lab);
if issparse(lab)
    lab = full(lab);
end
verbose = 0;
csearch = 2 .^ (-10:10);
s = 0;
kernel = 2;
degree = 3;
w0 = 1;
gammasearch = 1/size(inst, 2);
coef0 = 0;
nu = 0.5;
% be sure that  nu <= 2 * min(#y_i == + 1, #y_i == - 1) / l <= 1, wher l is
% number of samples. 
% Reference: http://stackoverflow.com/questions/10176434/libsvm-in-java-exits-after-0-iterations-no-result
nu_upperbound = 2*min([length(find(lab==1)), length(find(lab==-1))])/length(lab);
if nu > nu_upperbound
    nu = nu_upperbound - (1/length(lab));
end

epsi = 0.1;
cache = 100;
err_eps = 0.001;
shrink = 1;
prob = 0;
csfold = 5;
if ~isempty(param)
    param_set = fieldnames(param);
else
    param_set = [];
end
for i = 1:length(param_set)
    if strcmpi('csearch', param_set(i))
        csearch = param.csearch;
    elseif strcmpi('gammasearch', param_set(i))
        gammasearch = param.gammasearch;
    else
        eval([param_set{i} ' = ' num2str(getfield(param, param_set{i})) ';']);
    end
end

%% parameter serach (c, gamma)
best_acc = 0;
if kernel == 0 % linear kernel has no gamma
    gammasearch = 0;
end
if length(gammasearch) == 1
    best_gamma = gammasearch;
    if length(csearch) == 1 % avoid any search for efficiency if possible
        best_c = csearch;
        gammasearch = [];
        csearch = [];
    end
end
% start search
for c = csearch    
    for gamma = gammasearch
        if verbose
%             acc_ = svmtrain(lab, inst, [' -c ' num2str(c) ' -s ' num2str(s) ...
%                 ' -t ' num2str(kernel) ' -d ' num2str(degree) ' -w0 ' num2str(w0)...
%                 ' -g ' num2str(gamma) ' -r ' num2str(coef0) ' -n ' num2str(nu) ...
%                 ' -p ' num2str(epsi) ' -m ' num2str(cache) ' -e ' num2str(err_eps) ...
%                 ' -h ' num2str(shrink) ' -b ' num2str(prob) ' -v ' num2str(csfold) ...
%                 ' -q']);
            acc_ = balanced_kfold_crossvalidation(lab, inst, c, s, kernel, ...
                                                  degree, w0, gamma, coef0, nu, ...
                                                  epsi, cache, err_eps, shrink, ...
                                                  prob, csfold);
            disp(['current c: ' num2str(c) ...
                ' current accuracy:' num2str(acc_)]);
        else
%             train_cmd = ['acc_ = svmtrain(lab, inst, ['' -c '' num2str(c) '' -s '' num2str(s) '...
%                 ''' -t '' num2str(kernel) '' -d '' num2str(degree) '' -w0 '' num2str(w0) '...
%                 ''' -g '' num2str(gamma) '' -r '' num2str(coef0) '' -n '' num2str(nu) '...
%                 ''' -p '' num2str(epsi) '' -m '' num2str(cache) '' -e '' num2str(err_eps) '...
%                 ''' -h '' num2str(shrink) '' -b '' num2str(prob) '' -v '' num2str(csfold) '...
%                 ''' -q'']);'];
            train_cmd = [ 'acc_ = balanced_kfold_crossvalidation(lab, inst, c, s, kernel, '...
                           'degree, w0, gamma, coef0, nu, epsi, cache, err_eps, shrink, '...
                           'prob, csfold);'];
            [~] = evalc(train_cmd);
        end
        if isempty(acc_) % some parameter maybe infeasible, for example, nu
%             acc_ = svmtrain(lab, inst, [' -c ' num2str(c) ' -s ' num2str(s) ...
%                 ' -t ' num2str(kernel) ' -d ' num2str(degree) ' -w0 ' num2str(w0)...
%                 ' -g ' num2str(gamma) ' -r ' num2str(coef0) ' -n ' num2str(nu*0.8) ...
%                 ' -p ' num2str(epsi) ' -m ' num2str(cache) ' -e ' num2str(err_eps) ...
%                 ' -h ' num2str(shrink) ' -b ' num2str(prob) ' -v ' num2str(csfold) ...
%                 ' -q']);
            acc_ = balanced_kfold_crossvalidation(lab, inst, c, s, kernel, ...
                                                  degree, w0, gamma, coef0, nu*0.8, ...
                                                  epsi, cache, err_eps, shrink, ...
                                                  prob, csfold);
        end
        if acc_ >= best_acc
            best_acc = acc_;
            best_c = c;
            best_gamma = gamma;
        end
    end
end

%% train the svm model
display(['best acc: ', num2str(best_acc)]);
% note: no -v, so output is model
svm_mod = svmtrain(lab, inst, [' -c ' num2str(best_c) ' -s ' num2str(s) ...
                ' -t ' num2str(kernel) ' -d ' num2str(degree) ' -w0 ' num2str(w0)... 
                ' -g ' num2str(best_gamma) ' -r ' num2str(coef0) ' -n ' num2str(nu) ...                
                ' -p ' num2str(epsi) ' -m ' num2str(cache) ' -e ' num2str(err_eps) ...
                ' -h ' num2str(shrink) ' -b ' num2str(prob) ...
                ' -q']);
end

%% balanced samples
function acc = balanced_kfold_crossvalidation(lab, inst, c, s, kernel, ...
                                              degree, w0, gamma, coef0, nu, ...
                                              epsi, cache, err_eps, shrink, ...
                                              prob, csfold)
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
%     te_idx = false(inst_n, 1);
    te_idx = fold_idx{i};
    ss = 1:csfold;
    ss(i) = [];
    tr_idx = [];
    for j =1:length(ss)
        tr_idx = [tr_idx; fold_idx{ss(j)}];
    end
    
    te_lab = lab(te_idx);
    tr_lab = lab(tr_idx);
    te_inst = inst(te_idx, :);
    tr_inst = inst(tr_idx, :);
    svm_mod = svmtrain(tr_lab, tr_inst, [' -c ' num2str(c) ' -s ' num2str(s) ...
                ' -t ' num2str(kernel) ' -d ' num2str(degree) ' -w0 ' num2str(w0)...
                ' -g ' num2str(gamma) ' -r ' num2str(coef0) ' -n ' num2str(nu) ...
                ' -p ' num2str(epsi) ' -m ' num2str(cache) ' -e ' num2str(err_eps) ...
                ' -h ' num2str(shrink) ' -b ' num2str(prob) ' -q']);
    [labPr, acc(i), ~]  = svmpredict(te_lab, te_inst, svm_mod);
%     acc(i) = sum(labPr == te_lab)/length(te_lab);
end
acc = mean(acc);
end

%% not totally balanced samples
function acc = kfold_crossvalidation(lab, inst, c, s, kernel, ...
                                     degree, w0, gamma, coef0, nu, ...
                                     epsi, cache, err_eps, shrink, ...
                                     prob, csfold)
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
    svm_mod = svmtrain(tr_lab, tr_inst, [' -c ' num2str(c) ' -s ' num2str(s) ...
                ' -t ' num2str(kernel) ' -d ' num2str(degree) ' -w0 ' num2str(w0)...
                ' -g ' num2str(gamma) ' -r ' num2str(coef0) ' -n ' num2str(nu) ...
                ' -p ' num2str(epsi) ' -m ' num2str(cache) ' -e ' num2str(err_eps) ...
                ' -h ' num2str(shrink) ' -b ' num2str(prob) ' -q']);
    [labPr, acc(i), ~]  = svmpredict(te_lab, te_inst, svm_mod);
%     acc(i) = sum(labPr == te_lab)/length(te_lab);
end
acc = mean(acc);
end

