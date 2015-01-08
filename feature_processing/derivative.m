function out = derivative(x)
% Ping-Keng Jao Jan. 5 2015
% This function calculates x + delta (1st and 2nd order derivatives along 2nd dimension)
% where the corresponding output of last 2 column of input 'x' 
% is not calculated
for i = 1 : size(x, 2) - 2
    delta1(:, i) = x(:, i+1) - x(:,i);
    delta2(:, i) = x(:, i+2) - x(:,i+1);
    delta2(:, i) = delta2(i) - delta1(i);
%     out(:, i) = [x(:, i); delta1; delta2];
end
out = [x delta1 delta2];
end