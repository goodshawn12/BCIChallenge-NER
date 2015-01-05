% This function normalize the input training feature
% Ping-Keng Jao 2014/12/31
% Chin-Chia Yeh 2013/8/17
%
% [tr, fun] = normalization_function(tr, meth)
% Input
%     tr: the data used to calculate the normalization parameter It should
%         be a NxD matrix, where D is the number of feature dimension, and
%         N is the number of data.
%     meth: a vector indicate the desired normalization methods and orders.
%           In the current version, the included methods are:
%               1: sum2one
%               2: square root
%               3: cube root
%               4: tf-idf
%               5: z-score
%           Example input: [4, 3, 5]
%                          In this example the normalization sequeance is 
%                          first, if-idf, second, cube root, then z-score.
% Output
%    tr: the normalized input data.
%    fun: the function used to any unseen data.
%

function [tr, fun] = normalization_function(tr, meth)
if nargin == 0
    [tr, fun] = selfdemo;
    return;
end

if length(meth) > 1
    [tr, fun_p] = normalization_function(tr, meth(1:end-1));
    meth = meth(end);
end

switch meth
    case 0 % no normalization
        fun = @(x) x;
    case 1 % sum2one
        % fun = @(x) bsxfun(@rdivide, abs(x), sum(abs(x), 2));
        fun = @(x) ni2zero(bsxfun(@rdivide, abs(x), sum(abs(x), 2)));
    case 2 % square root normalization
        fun = @(x) nthroot(abs(x), 2);
    case 3 % cube root normalization
        fun = @(x) nthroot(abs(x), 3);
    case 4 % tf-idf
        tr_Ft = sum(abs(tr), 1);
        tr_nt_t = bsxfun(@rdivide, abs(tr), tr_Ft);
        tr_nt = - ni2zero(sum(tr_nt_t .* ni2zero(log(tr_nt_t)), 1));
        tr_idf = 1 - tr_nt./size(abs(tr), 1);
        fun = @(x) bsxfun(@times, log(1 + abs(x)), tr_idf);
    case 5 % z score
        tr_mean = mean(tr, 1);
        tr_std = std(tr, [], 1);
        fun_mi = @(x) bsxfun(@minus, x, tr_mean);
        fun_rd = @(x) bsxfun(@rdivide, x, tr_std);
        % fun = @(x) fun_rd(fun_mi(ni2zero(x)));
        fun = @(x) ni2zero(fun_rd(fun_mi(x)));
    case 6 % z-score (normalize to self)        
        fun_mean = @(x) mean(x, 2);
        fun_std  = @(x) std(x, [], 2);        
        fun_mi = @(x, y) bsxfun(@minus, x, y);
        fun_rd = @(x, y) bsxfun(@rdivide, x, y);        
        fun = @(x) ni2zero(fun_rd(fun_mi(x, fun_mean(x)), fun_std(x)));
    case 7 % Euclidean
        fun = @(x) l2norm(x);
    case 8 % normalize to [0 1]        
        fun = @(x) o1norm(x);
    case 9 % normalize to [0 1] to self
        fun = @(x) self_o1norm(x);
end

tr = fun(tr);

if exist('fun_p', 'var')
    fun = @(x) fun(fun_p(x));
end

%% Normaliz to [0 1] to self
function x = self_o1norm(x)    
    M = max(x, [], 1);
    m = min(x, [], 1);
    d = M - m;
    num = size(x, 1);
    x = x - repmat(m, [num, 1]); % shift, such that minimum is zero)
    x = x./(repmat(d, [num, 1]));
    x = ni2zero(x); % set NaN and Inf to zero


%% Normaliz to [0 1]
function x = o1norm(x)    
    M = max(x, [], 2);
    m = min(x, [], 2);
    d = M - m;
    num = size(x, 2);
    x = x - repmat(m, [1, num]); % shift, such that minimum is zero)
    x = x./(repmat(d, [1, num]));
    x = ni2zero(x); % set NaN and Inf to zero

%% L2-norm
function x = l2norm(x)
n = size(x, 1);
for i=1:n
    ratio(i,1) = sqrt(x(i,:)*x(i,:)');
    x(i,:) = x(i,:)./ratio(i,1);
end

%% set NaN and Inf to zero
function x = ni2zero(x)
x(isinf(x)) = 0;
x(isnan(x)) = 0;

%% self demo
function [tr, fun] = selfdemo
clc;
tr = rand(4, 3);
meth = [3, 1];
[tr_, fun] = normalization_function(tr, meth);
disp(tr_);
