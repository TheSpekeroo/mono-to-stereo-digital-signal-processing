% main code
[y, Fs] = audioread("VRSoundsMono.mp3");

% Process the entire input audio
xw_i = y;

% LPF
xw_rL = tst_WD1rL(Fs, xw_i(:, 1)); % Process left channel
xw_rL = repmat(xw_rL, 1, size(xw_i, 2))*2; % Repeat for all channels

% HPF
xw_rH = tst_WD1rH(Fs, xw_i(:, 1)); % Process left channel
xw_rH = repmat(xw_rH, 1, size(xw_i, 2))/20; % Repeat for all channels

% Haas Effect - Add a short delay to one channel (e.g., 20 milliseconds)
delay_samples = round(0.02 * Fs); % 20 milliseconds delay
xw_rL_delayed = [zeros(delay_samples, size(xw_i, 2)); xw_rL(1:end-delay_samples, :)];

% Chorus Effect - Modulate the delay time
depth = 5; % in milliseconds
rate = 1; % modulation rate in Hz
modulation = depth * sin(2 * pi * rate * (1:length(xw_rL_delayed))/Fs)';
xw_rL_chorus = interp1(1:length(xw_rL_delayed), xw_rL_delayed, 1:length(xw_rL_delayed) + modulation);
xw_rH_chorus = interp1(1:length(xw_rH), xw_rH, 1:length(xw_rH) + modulation);

% Panning - Adjust the amplitudes for left and right channels
panning_ratio = 0.25; % Adjust as needed

if panning_ratio >= 0
    xw_rL_chorus_panned = xw_rL_chorus * (1 - abs(panning_ratio));
    xw_rH_chorus_panned = xw_rH_chorus * abs(panning_ratio);
else
    xw_rL_chorus_panned = xw_rH_chorus * abs(panning_ratio);
    xw_rH_chorus_panned = xw_rL_chorus * (1 - abs(panning_ratio));
end

jj_o = [xw_rL_chorus_panned' xw_rH_chorus_panned']; % L/R (due to mismatching level)

% Normalize the audio data
jj_o = jj_o / max(abs(jj_o(:)));

% Save processed audio to a new file
audiowrite('processed_audio-315deg.mp3', jj_o, Fs);

% Play the processed audio
sound(jj_o, Fs);
