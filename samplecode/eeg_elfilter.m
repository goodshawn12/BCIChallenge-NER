function [delta, theta, alpha, beta, gamma, high_gamma] = eeg_elfilter(data,sampling_frequency)
%
% Inputs 
%   data: vector of raw EEG data from a single EEG channel
%   sampling_frequency: Sampling Frequency in Hz
%
% Outputs
%   EEG bands
%       delta: .5 to 3.9 Hz EEG data
%       theta: 4 to 7.9 Hz EEG data
%       alpha: 8 to 12.9 Hz EEG data
%       beta: 13 to 30.9 Hz EEG data
%       gamma: 31 to 43 Hz EEG data
%
% Example Function Call
%   [delta, theta, alpha, beta, gamma] = elfilter(rawdata, 200);


order = 4;
nyquist = sampling_frequency/2;
passband_ripple = 1;
stopband_ripple = 20;

delta_bw = [0.5/nyquist, 3.9/nyquist];
theta_bw = [4/nyquist, 7.9/nyquist];
alpha_bw = [8/nyquist, 12.9/nyquist];
beta_bw = [13/nyquist, 30.9/nyquist];
gamma_bw = [31/nyquist, 43/nyquist];
high_gamma_bw = [43.1/nyquist, 60/nyquist];
    
[b_delta, a_delta] = ellip(order, passband_ripple, stopband_ripple, delta_bw);
[b_theta, a_theta] = ellip(order, passband_ripple, stopband_ripple, theta_bw);
[b_alpha, a_alpha] = ellip(order, passband_ripple, stopband_ripple, alpha_bw);
[b_beta, a_beta] = ellip(order, passband_ripple, stopband_ripple, beta_bw);
[b_gamma, a_gamma] = ellip(order, passband_ripple, stopband_ripple, gamma_bw);
[b_gamma_high, a_gamma_high] = ellip(order, passband_ripple, stopband_ripple, high_gamma_bw);
% 
delta = filtfilt(b_delta, a_delta, data);
theta = filtfilt(b_theta, a_theta, data);
alpha = filtfilt(b_alpha, a_alpha, data);
beta = filtfilt(b_beta, a_beta, data);
gamma = filtfilt(b_gamma, a_gamma, data);
high_gamma = filtfilt(b_gamma_high,a_gamma_high,data); 

