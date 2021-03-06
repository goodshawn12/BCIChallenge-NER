function outEEG = epochEOG(inEEG)

outEEG = inEEG;

tempEEG.data = inEEG.eog;
tempEEG.srate = 200;
tempEEG.pnts = length(inEEG.eog);
tempEEG.nbchan = 1;
tempEEG.trials = 1;
tempEEG.event = [];
tempEEG.setname = [];
tempEEG.xmin = 0;
tempEEG.xmax = 1;

tempEEG = pop_eegfiltnew(tempEEG,1,inEEG.srate/2);
tempEEG = pop_resample(tempEEG,inEEG.srate);
outEEG.eog = tempEEG.data;

eventt = round(inEEG.srate*[inEEG.event.init_time]);
zerot1 = find(inEEG.times==0)-1;
zerot2 = inEEG.pnts-find(inEEG.times==0);

eog = [];
for it = 1:length(eventt)
    eog(:,it) = outEEG.eog(eventt(it)-zerot1:eventt(it)+zerot2);
end

outEEG.eog = eog;
end

% 
% % pop_eegfiltnew() - Filter data using Hamming windowed sinc FIR filter
% %
% % Usage:
% %   >> [EEG, com, b] = pop_eegfiltnew(EEG); % pop-up window mode
% %   >> [EEG, com, b] = pop_eegfiltnew(EEG, locutoff, hicutoff, filtorder,
% %                                     revfilt, usefft, plotfreqz, minphase);
% %
% % Inputs:
% %   EEG       - EEGLAB EEG structure
% %   locutoff  - lower edge of the frequency pass band (Hz)
% %               {[]/0 -> lowpass} 
% %   hicutoff  - higher edge of the frequency pass band (Hz)
% %               {[]/0 -> highpass}
% %
% % Optional inputs:
% %   filtorder - filter order (filter length - 1). Mandatory even
% %   revfilt   - [0|1] invert filter (from bandpass to notch filter)
% %               {default 0 (bandpass)}
% %   usefft    - ignored (backward compatibility only)
% %   plotfreqz - [0|1] plot filter's frequency and phase response
% %               {default 0} 
% %   minphase  - scalar boolean minimum-phase converted causal filter
% %               {default false}
% %
% % Outputs:
% %   EEG       - filtered EEGLAB EEG structure
% %   com       - history string
% %   b         - filter coefficients
% %
% % Note:
% %   pop_eegfiltnew is intended as a replacement for the deprecated
% %   pop_eegfilt function. Required filter order/transition band width is
% %   estimated with the following heuristic in default mode: transition band
% %   width is 25% of the lower passband edge, but not lower than 2 Hz, where
% %   possible (for bandpass, highpass, and bandstop) and distance from
% %   passband edge to critical frequency (DC, Nyquist) otherwise. Window
% %   type is hardcoded to Hamming. Migration to windowed sinc FIR filters
% %   (pop_firws) is recommended. pop_firws allows user defined window type
% %   and estimation of filter order by user defined transition band width.
% %
% % Author: Andreas Widmann, University of Leipzig, 2012
% %
% % See also:
% %   firfilt, firws, windows
% 
% %123456789012345678901234567890123456789012345678901234567890123456789012
% 
% % Copyright (C) 2008 Andreas Widmann, University of Leipzig, widmann@uni-leipzig.de
% %
% % This program is free software; you can redistribute it and/or modify
% % it under the terms of the GNU General Public License as published by
% % the Free Software Foundation; either version 2 of the License, or
% % (at your option) any later version.
% %
% % This program is distributed in the hope that it will be useful,
% % but WITHOUT ANY WARRANTY; without even the implied warranty of
% % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% % GNU General Public License for more details.
% %
% % You should have received a copy of the GNU General Public License
% % along with this program; if not, write to the Free Software
% % Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
% 
% function [EEG, com, b] = pop_eegfiltnew(EEG, locutoff, hicutoff, filtorder, revfilt, usefft, plotfreqz, minphase)
% 
% com = '';
% 
% if nargin < 1
%     help pop_eegfiltnew;
%     return
% end
% if isempty(EEG.data)
%     error('Cannot filter empty dataset.');
% end
% 
% % GUI
% if nargin < 2
% 
%     geometry = {[3, 1], [3, 1], [3, 1], 1, 1, 1, 1};
%     geomvert = [1 1 1 2 1 1 1];
% 
%     uilist = {{'style', 'text', 'string', 'Lower edge of the frequency pass band (Hz)'} ...
%               {'style', 'edit', 'string', ''} ...
%               {'style', 'text', 'string', 'Higher edge of the frequency pass band (Hz)'} ...
%               {'style', 'edit', 'string', ''} ...
%               {'style', 'text', 'string', 'FIR Filter order (Mandatory even. Default is automatic*)'} ...
%               {'style', 'edit', 'string', ''} ...
%               {'style', 'text', 'string', {'*See help text for a description of the default filter order heuristic.', 'Manual definition is recommended.'}} ...
%               {'style', 'checkbox', 'string', 'Notch filter the data instead of pass band', 'value', 0} ...
%               {'Style', 'checkbox', 'String', 'Use minimum-phase converted causal filter (non-linear!; beta)', 'Value', 0} ...
%               {'style', 'checkbox', 'string', 'Plot frequency response', 'value', 1}};
% 
%     result = inputgui('geometry', geometry, 'geomvert', geomvert, 'uilist', uilist, 'title', 'Filter the data -- pop_eegfiltnew()', 'helpcom', 'pophelp(''pop_eegfiltnew'')');
% 
%     if isempty(result), return; end
% 
%     locutoff = str2num(result{1});
%     hicutoff = str2num(result{2});
%     filtorder = str2num(result{3});
%     revfilt = result{4};
%     minphase = result{5};
%     plotfreqz = result{6};
%     usefft = [];
% 
% else
%     
%     if nargin < 3
%         hicutoff = [];
%     end
%     if nargin < 4
%         filtorder = [];
%     end
%     if nargin < 5 || isempty(revfilt)
%         revfilt = 0;
%     end
%     if nargin < 6
%         usefft = [];
%     elseif usefft == 1
%         error('FFT filtering not supported. Argument is provided for backward compatibility in command line mode only.')
%     end
%     if nargin < 7 || isempty(plotfreqz)
%         plotfreqz = 0;
%     end
%     if nargin < 8 || isempty(minphase)
%         minphase = 0;
%     end
%     
% end
% 
% % Constants
% TRANSWIDTHRATIO = 0.25;
% fNyquist = EEG.srate / 2;
% 
% % Check arguments
% if locutoff == 0, locutoff = []; end
% if hicutoff == 0, hicutoff = []; end
% if isempty(hicutoff) % Convert highpass to inverted lowpass
%     hicutoff = locutoff;
%     locutoff = [];
%     revfilt = ~revfilt;
% end
% edgeArray = sort([locutoff hicutoff]);
% 
% if isempty(edgeArray)
%     error('Not enough input arguments.');
% end
% if any(edgeArray < 0 | edgeArray >= fNyquist)
%     error('Cutoff frequency out of range');
% end
% 
% if ~isempty(filtorder) && (filtorder < 2 || mod(filtorder, 2) ~= 0)
%     error('Filter order must be a real, even, positive integer.')
% end
% 
% % Max stop-band width
% maxTBWArray = edgeArray; % Band-/highpass
% if revfilt == 0 % Band-/lowpass
%     maxTBWArray(end) = fNyquist - edgeArray(end);
% elseif length(edgeArray) == 2 % Bandstop
%     maxTBWArray = diff(edgeArray) / 2;
% end
% maxDf = min(maxTBWArray);
% 
% % Transition band width and filter order
% if isempty(filtorder)
% 
%     % Default filter order heuristic
%     if revfilt == 1 % Highpass and bandstop
%         df = min([max([maxDf * TRANSWIDTHRATIO 2]) maxDf]);
%     else % Lowpass and bandpass
%         df = min([max([edgeArray(1) * TRANSWIDTHRATIO 2]) maxDf]);
%     end
% 
%     filtorder = 3.3 / (df / EEG.srate); % Hamming window
%     filtorder = ceil(filtorder / 2) * 2; % Filter order must be even.
%     
% else
% 
%     df = 3.3 / filtorder * EEG.srate; % Hamming window
%     filtorderMin = ceil(3.3 ./ ((maxDf * 2) / EEG.srate) / 2) * 2;
%     filtorderOpt = ceil(3.3 ./ (maxDf / EEG.srate) / 2) * 2;
%     if filtorder < filtorderMin
%         error('Filter order too low. Minimum required filter order is %d. For better results a minimum filter order of %d is recommended.', filtorderMin, filtorderOpt)
%     elseif filtorder < filtorderOpt
%         warning('firfilt:filterOrderLow', 'Transition band is wider than maximum stop-band width. For better results a minimum filter order of %d is recommended. Reported might deviate from effective -6dB cutoff frequency.', filtorderOpt)
%     end
% 
% end
% 
% filterTypeArray = {'lowpass', 'bandpass'; 'highpass', 'bandstop (notch)'};
% fprintf('pop_eegfiltnew() - performing %d point %s filtering.\n', filtorder + 1, filterTypeArray{revfilt + 1, length(edgeArray)})
% fprintf('pop_eegfiltnew() - transition band width: %.4g Hz\n', df)
% fprintf('pop_eegfiltnew() - passband edge(s): %s Hz\n', mat2str(edgeArray))
% 
% % Passband edge to cutoff (transition band center; -6 dB)
% dfArray = {df, [-df, df]; -df, [df, -df]};
% cutoffArray = edgeArray + dfArray{revfilt + 1, length(edgeArray)} / 2;
% fprintf('pop_eegfiltnew() - cutoff frequency(ies) (-6 dB): %s Hz\n', mat2str(cutoffArray))
% 
% % Window
% winArray = windows('hamming', filtorder + 1);
% 
% % Filter coefficients
% if revfilt == 1
%     filterTypeArray = {'high', 'stop'};
%     b = firws(filtorder, cutoffArray / fNyquist, filterTypeArray{length(cutoffArray)}, winArray);
% else
%     b = firws(filtorder, cutoffArray / fNyquist, winArray);
% end
% 
% if minphase
%     disp('pop_eegfiltnew() - converting filter to minimum-phase (non-linear!)');
%     b = minphaserceps(b);
% end
% 
% % Plot frequency response
% if plotfreqz
%     freqz(b, 1, 8192, EEG.srate);
% end
% 
% % Filter
% if minphase
%     disp('pop_eegfiltnew() - filtering the data (causal)');
%     EEG = firfiltsplit(EEG, b, 1);
% else
%     disp('pop_eegfiltnew() - filtering the data (zero-phase)');
%     EEG = firfilt(EEG, b);
% end
% 
% 
% % History string
% com = sprintf('%s = pop_eegfiltnew(%s, %s, %s, %s, %s, %s, %s);', inputname(1), inputname(1), mat2str(locutoff), mat2str(hicutoff), mat2str(filtorder), mat2str(revfilt), mat2str(usefft), mat2str(plotfreqz));
% 
% end
% 
% 
% 
% 
% % firfilt() - Pad data with DC constant, filter data with FIR filter,
% %             and shift data by the filter's group delay
% %
% % Usage:
% %   >> EEG = firfilt(EEG, b, nFrames);
% %
% % Inputs:
% %   EEG           - EEGLAB EEG structure
% %   b             - vector of filter coefficients
% %
% % Optional inputs:
% %   nFrames       - number of frames to filter per block {default 1000}
% %
% % Outputs:
% %   EEG           - EEGLAB EEG structure
% %
% % Note:
% %   Higher values for nFrames increase speed and working memory
% %   requirements.
% %
% % Author: Andreas Widmann, University of Leipzig, 2005
% %
% % See also:
% %   filter, findboundaries
% 
% %123456789012345678901234567890123456789012345678901234567890123456789012
% 
% % Copyright (C) 2005 Andreas Widmann, University of Leipzig, widmann@uni-leipzig.de
% %
% % This program is free software; you can redistribute it and/or modify
% % it under the terms of the GNU General Public License as published by
% % the Free Software Foundation; either version 2 of the License, or
% % (at your option) any later version.
% %
% % This program is distributed in the hope that it will be useful,
% % but WITHOUT ANY WARRANTY; without even the implied warranty of
% % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% % GNU General Public License for more details.
% %
% % You should have received a copy of the GNU General Public License
% % along with this program; if not, write to the Free Software
% % Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
% 
% function EEG = firfilt(EEG, b, nFrames)
% 
% if nargin < 2
%     error('Not enough input arguments.');
% end
% if nargin < 3 || isempty(nFrames)
%     nFrames = 1000;
% end
% 
% % Filter's group delay
% if mod(length(b), 2) ~= 1
%     error('Filter order is not even.');
% end
% groupDelay = (length(b) - 1) / 2;
% 
% % Find data discontinuities and reshape epoched data
% if EEG.trials > 1 % Epoched data
%     EEG.data = reshape(EEG.data, [EEG.nbchan EEG.pnts * EEG.trials]);
%     dcArray = 1 : EEG.pnts : EEG.pnts * (EEG.trials + 1);
% else % Continuous data
%     dcArray = [findboundaries(EEG.event) EEG.pnts + 1];
% end
% 
% % Initialize progress indicator
% nSteps = 20;
% step = 0;
% fprintf(1, 'firfilt(): |');
% strLength = fprintf(1, [repmat(' ', 1, nSteps - step) '|   0%%']);
% tic
% 
% for iDc = 1:(length(dcArray) - 1)
% 
%         % Pad beginning of data with DC constant and get initial conditions
%         ziDataDur = min(groupDelay, dcArray(iDc + 1) - dcArray(iDc));
%         [temp, zi] = filter(b, 1, double([EEG.data(:, ones(1, groupDelay) * dcArray(iDc)) ...
%                                   EEG.data(:, dcArray(iDc):(dcArray(iDc) + ziDataDur - 1))]), [], 2);
% 
%         blockArray = [(dcArray(iDc) + groupDelay):nFrames:(dcArray(iDc + 1) - 1) dcArray(iDc + 1)];
%         for iBlock = 1:(length(blockArray) - 1)
% 
%             % Filter the data
%             [EEG.data(:, (blockArray(iBlock) - groupDelay):(blockArray(iBlock + 1) - groupDelay - 1)), zi] = ...
%                 filter(b, 1, double(EEG.data(:, blockArray(iBlock):(blockArray(iBlock + 1) - 1))), zi, 2);
% 
%             % Update progress indicator
%             [step, strLength] = mywaitbar((blockArray(iBlock + 1) - groupDelay - 1), size(EEG.data, 2), step, nSteps, strLength);
%         end
% 
%         % Pad end of data with DC constant
%         temp = filter(b, 1, double(EEG.data(:, ones(1, groupDelay) * (dcArray(iDc + 1) - 1))), zi, 2);
%         EEG.data(:, (dcArray(iDc + 1) - ziDataDur):(dcArray(iDc + 1) - 1)) = ...
%             temp(:, (end - ziDataDur + 1):end);
% 
%         % Update progress indicator
%         [step, strLength] = mywaitbar((dcArray(iDc + 1) - 1), size(EEG.data, 2), step, nSteps, strLength);
% 
% end
% 
% % Reshape epoched data
% if EEG.trials > 1
%     EEG.data = reshape(EEG.data, [EEG.nbchan EEG.pnts EEG.trials]);
% end
% 
% % Deinitialize progress indicator
% fprintf(1, '\n')
% 
% end
% 
% function [step, strLength] = mywaitbar(compl, total, step, nSteps, strLength)
% 
% progStrArray = '/-\|';
% tmp = floor(compl / total * nSteps);
% if tmp > step
%     fprintf(1, [repmat('\b', 1, strLength) '%s'], repmat('=', 1, tmp - step))
%     step = tmp;
%     ete = ceil(toc / step * (nSteps - step));
%     strLength = fprintf(1, [repmat(' ', 1, nSteps - step) '%s %3d%%, ETE %02d:%02d'], progStrArray(mod(step - 1, 4) + 1), floor(step * 100 / nSteps), floor(ete / 60), mod(ete, 60));
% end
% 
% end
% 
% % pop_resample() - resample dataset (pop up window).
% %
% % Usage:
% %   >> [OUTEEG] = pop_resample( INEEG ); % pop up interactive window
% %   >> [OUTEEG] = pop_resample( INEEG, freq);
% %
% % Graphical interface:
% %   The edit box entitled "New sampling rate" contains the frequency in
% %   Hz for resampling the data. Entering a value in this box  is the same 
% %   as providing it in the 'freq' input from the command line.
% %
% % Inputs:
% %   INEEG      - input dataset
% %   freq       - frequency to resample (Hz)  
% %
% % Outputs:
% %   OUTEEG     - output dataset
% %
% % Author: Arnaud Delorme, CNL/Salk Institute, 2001
% %
% % Note: uses the resample() function from the signal processing toolbox
% %       if present. Otherwise use griddata interpolation method (it should be
% %       reprogrammed using spline interpolation for speed up).
% %
% % See also: resample(), eeglab()
% 
% % Copyright (C) 2001 Arnaud Delorme, Salk Institute, arno@salk.edu
% %
% % This program is free software; you can redistribute it and/or modify
% % it under the terms of the GNU General Public License as published by
% % the Free Software Foundation; either version 2 of the License, or
% % (at your option) any later version.
% %
% % This program is distributed in the hope that it will be useful,
% % but WITHOUT ANY WARRANTY; without even the implied warranty of
% % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% % GNU General Public License for more details.
% %
% % You should have received a copy of the GNU General Public License
% % along with this program; if not, write to the Free Software
% % Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
% 
% % 01-25-02 reformated help & license -ad 
% % 03-08-02 remove ica activity resampling (now set to []) -ad
% % 03-08-02 debug call to function help -ad
% % 04-05-02 recompute event latencies -ad
% 
% function [EEG, command] = pop_resample( EEG, freq); 
% 
% command = '';
% if nargin < 1
%     help pop_resample;
%     return;
% end;     
% if isempty(EEG(1).data)
%     disp('Pop_resample error: cannot resample empty dataset'); return;
% end;    
% 
% if nargin < 2 
% 
% 	% popup window parameters
% 	% -----------------------
% 	promptstr    = {['New sampling rate']};
% 	inistr       = { num2str(EEG(1).srate) };
% 	result       = inputdlg2( promptstr, 'Resample current dataset -- pop_resample()', 1,  inistr, 'pop_resample');
% 	if length(result) == 0 return; end;
% 	freq         = eval( result{1} );
% 
% end;
% 
% % process multiple datasets
% % -------------------------
% if length(EEG) > 1
%     [ EEG command ] = eeg_eval( 'pop_resample', EEG, 'warning', 'on', 'params', { freq } );
%     return;
% end;
% 
% % finding the best ratio
% [p,q] = rat(freq/EEG.srate, 0.0001); % not used right now 
% 
% % set variable
% % ------------
% EEG.data = reshape(EEG.data, EEG.nbchan, EEG.pnts, EEG.trials);
% oldpnts  = EEG.pnts;
% 
% % resample for multiple channels
% % -------------------------
% if isfield(EEG, 'event') & isfield(EEG.event, 'type') & isstr(EEG.event(1).type)
%     tmpevent = EEG.event;
%     bounds = strmatch('boundary', { tmpevent.type });
%     if ~isempty(bounds),
%         disp('Data break detected and taken into account for resampling');
%         bounds = [ tmpevent(bounds).latency ];
%         bounds(bounds <= 0 | bounds > size(EEG.data,2)) = []; % Remove out of range boundaries
%         bounds(mod(bounds, 1) ~= 0) = round(bounds(mod(bounds, 1) ~= 0) + 0.5); % Round non-integer boundary latencies
%     end;
%     bounds = [1 bounds size(EEG.data, 2) + 1]; % Add initial and final boundary event
%     bounds = unique(bounds); % Sort (!) and remove doublets
% else 
%     bounds = [1 size(EEG.data,2) + 1]; % [1:size(EEG.data,2):size(EEG.data,2)*size(EEG.data,3)+1];
% end;
% 
% eeglab_options;
% if option_donotusetoolboxes
%     usesigproc = 0;
% elseif exist('resample') == 2
%      usesigproc = 1;
% else usesigproc = 0;
%     disp('Signal Processing Toolbox absent: using custom interpolation instead of resample() function.');
%     disp('This method uses cubic spline interpolation after anti-aliasing (see >> help spline)');    
% end;
% 
% fprintf('resampling data %3.4f Hz\n', EEG.srate*p/q);
% eeglab_options;
% for index1 = 1:size(EEG.data,1)
%     fprintf('%d ', index1);	
%     sigtmp = reshape(EEG.data(index1,:, :), oldpnts, EEG.trials);
%     
%     if index1 == 1
%         tmpres = [];
%         indices = [1];
%         for ind = 1:length(bounds)-1
%             tmpres  = [ tmpres; myresample( double( sigtmp(bounds(ind):bounds(ind+1)-1,:)), p, q, usesigproc ) ];
%             indices = [ indices size(tmpres,1)+1 ];
%         end;
%         if size(tmpres,1) == 1, EEG.pnts  = size(tmpres,2);
%         else                    EEG.pnts  = size(tmpres,1);
%         end;
%         if option_memmapdata == 1
%              tmpeeglab = mmo([], [EEG.nbchan, EEG.pnts, EEG.trials]);
%         else tmpeeglab = zeros(EEG.nbchan, EEG.pnts, EEG.trials);
%         end;
%     else
%         for ind = 1:length(bounds)-1
%             tmpres(indices(ind):indices(ind+1)-1,:) = myresample( double( sigtmp(bounds(ind):bounds(ind+1)-1,:) ), p, q, usesigproc );
%         end;
%     end; 
%     tmpeeglab(index1,:, :) = tmpres;
% end;
% fprintf('\n');	
% EEG.srate   = EEG.srate*p/q;
% EEG.data = tmpeeglab;
% 
% % recompute all event latencies
% % -----------------------------
% if isfield(EEG.event, 'latency')
%     fprintf('resampling event latencies...\n');
% 
%     for iEvt = 1:length(EEG.event)
% 
%         % From >> help resample: Y is P/Q times the length of X (or the
%         % ceiling of this if P/Q is not an integer).
%         % That is, recomputing event latency by pnts / oldpnts will give
%         % inaccurate results in case of multiple segments and rounded segment
%         % length. Error is accumulated and can lead to several samples offset.
%         % Blocker for boundary events.
%         % Old version EEG.event(index1).latency = EEG.event(index1).latency * EEG.pnts /oldpnts;
% 
%         % Recompute event latencies relative to segment onset
%         if strcmpi(EEG.event(iEvt).type, 'boundary') && mod(EEG.event(iEvt).latency, 1) == 0.5 % Workaround to keep EEGLAB style boundary events at -0.5 latency relative to DC event; actually incorrect
%             iBnd = sum(EEG.event(iEvt).latency + 0.5 >= bounds);
%             EEG.event(iEvt).latency = indices(iBnd) - 0.5;
%         else
%             iBnd = sum(EEG.event(iEvt).latency >= bounds);
%             EEG.event(iEvt).latency = (EEG.event(iEvt).latency - bounds(iBnd)) * p / q + indices(iBnd);
%         end
%         
%     end
% 
%     if isfield(EEG, 'urevent') & isfield(EEG.urevent, 'latency')
%         try
%             for iUrevt = 1:length(EEG.urevent)
%                 % Recompute urevent latencies relative to segment onset
%                 if strcmpi(EEG.urevent(iUrevt).type, 'boundary') && mod(EEG.urevent(iUrevt).latency, 1) == 0.5 % Workaround to keep EEGLAB style boundary events at -0.5 latency relative to DC event; actually incorrect
%                     iBnd = sum(EEG.urevent(iUrevt).latency + 0.5 >= bounds);
%                     EEG.urevent(iUrevt).latency = indices(iBnd) - 0.5;
%                 else
%                     iBnd = sum(EEG.urevent(iUrevt).latency >= bounds);
%                     EEG.urevent(iUrevt).latency = (EEG.urevent(iUrevt).latency - bounds(iBnd)) * p / q + indices(iBnd);
%                 end
% 
%             end;
%         catch
%             disp('pop_resample warning: ''urevent'' problem, reinitializing urevents');
%             EEG = rmfield(EEG, 'urevent');
%         end;
%     end;
%     EEG = eeg_checkset(EEG, 'eventconsistency');
% end;
% 
% % resample for multiple channels ica
% EEG.icaact = [];
% 
% % store dataset
% fprintf('resampling finished\n');
% 
% EEG.setname = [EEG.setname ' resampled'];
% EEG.pnts    = size(EEG.data,2);
% EEG.xmax    = EEG.xmin + (EEG.pnts-1)/EEG.srate; % cko: recompute xmax, since we may have removed a few of the trailing samples
% EEG.times   = linspace(EEG.xmin*1000, EEG.xmax*1000, EEG.pnts);
% 
% command = sprintf('EEG = pop_resample( %s, %d);', inputname(1), freq);
% return;
% end
% 
% % resample if resample is not present
% % -----------------------------------
% function tmpeeglab = myresample(data, pnts, new_pnts, usesigproc);
%     
%     if length(data) < 2
%         tmpeeglab = data;
%         return;
%     end;
%     %if size(data,2) == 1, data = data'; end;
%     if usesigproc
%         % padding to avoid artifacts at the beginning and at the end
%         % Andreas Widmann May 5, 2011
%         
%         %The pop_resample command introduces substantial artifacts at beginning and end
%         %of data when raw data show DC offset (e.g. as in DC recorded continuous files)
%         %when MATLAB Signal Processing Toolbox is present (and MATLAB resample.m command
%         %is used).
%         %Even if this artifact is short, it is a filtered DC offset and will be carried
%         %into data, e.g. by later highpass filtering to a substantial amount (easily up
%         %to several seconds).
%         %The problem can be solved by padding the data at beginning and end by a DC
%         %constant before resampling.
% 
%         [p, q] = rat(pnts / new_pnts, 1e-12); % Same precision as in resample
%         N = 10; % Resample default
%         nPad = ceil((max(p, q) * N) / q) * q; % # datapoints to pad, round to integer multiple of q for unpadding
%         tmpeeglab = resample([data(ones(1, nPad), :); data; data(end * ones(1, nPad), :)], pnts, new_pnts);
%         nPad = nPad * p / q; % # datapoints to unpad
%         tmpeeglab = tmpeeglab(nPad + 1:end - nPad, :); % Remove padded data
%         return;
%     end;
%     
%     % anti-alias filter
%     % -----------------
%     data         = eegfiltfft(data', 256, 0, 128*pnts/new_pnts); % Downsample from 256 to 128 times the ratio of freq. 
%                                                                  % Code was verified by Andreas Widdman March  2014
%     
%     % spline interpolation
%     % --------------------
%     X            = [1:length(data)];
%     nbnewpoints  = length(data)*pnts/new_pnts;
%     nbnewpoints2 = ceil(nbnewpoints);
%     lastpointval = length(data)/nbnewpoints*nbnewpoints2;        
%     XX = linspace( 1, lastpointval, nbnewpoints2);
%     
%     cs = spline( X, data);
%     tmpeeglab = ppval(cs, XX)';
% end