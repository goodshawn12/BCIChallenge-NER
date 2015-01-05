function model = GNB_train(inst, lab, param)
%% generate more balanced random fold split
inst_n = length(lab);
class = unique(lab);
p_idx = find(lab == max(class));
n_idx = find(lab == min(class));
sample_num = min(length(p_idx), length(n_idx));

csfold = param.csfold;
if sample_num < csfold * 2
   warning(['Your csfold is too large, you only have %d ', ... 
       'examples while your csfold is %d.'], sample_num, csfold);
   csfold = floor(sample_num/2); % GNB need at least 2 samples
end

p_idx = p_idx(randperm(length(p_idx)));
n_idx = n_idx(randperm(length(n_idx)));


idx = [p_idx(1:sample_num); n_idx(1:sample_num)];

fold_idx = cell(csfold, 1);
for i = 1:csfold
   fold_idx{i} = idx(i:csfold:length(idx));
end

%% corss-validataion
best_acc = 0;
acc = zeros(csfold, 1);
for i = 1:csfold
    te_idx = false(inst_n, 1);
    te_idx(fold_idx{i}) = true;
    tr_idx = ~te_idx;
    
    te_lab = lab(te_idx);
    tr_lab = lab(tr_idx);
    te_inst = inst(te_idx, :);
    tr_inst = inst(tr_idx, :);
    v_model=NaiveBayes.fit(tr_inst, tr_lab);
    [~, labPr, ~] = posterior(v_model, te_inst);
    acc = sum(labPr == te_lab)/length(te_lab);
    if acc > best_acc
        best_acc = acc;
        model = v_model;
    end
end
end