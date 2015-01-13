function [x,xp] = example_post_process(y)

order = 4;
nyquist = 200/2;
passband_ripple = 1;
stopband_ripple = 20;
bw = [0.1/nyquist, 60/nyquist];
[b, a] = ellip(order, passband_ripple, stopband_ripple, bw);

x = (filtfilt(b, a, y));
[delta, theta, alpha, beta, gamma] = eeg_elfilter(x,200);
% % 
X = { delta, theta, alpha, beta, gamma}; 

xp = zeros(size(x,1),length(X)); 
for k = 1 : length(X)
    xp(:,k) = X{k}; 
end

