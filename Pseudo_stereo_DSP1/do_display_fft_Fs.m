function do_display_fft_Fs(xw_i,Fs)
% global Fs;
% a simple spectrum analyzer, fft based on Fs
L=size(xw_i,1);
%Fs=10e3;
%Fs=8000;	% 8e3, 8Khz
NFFT = 2^nextpow2(L); 	% next power of 2 from length of y
Y = fft(xw_i,NFFT)/L;
% Y = fft(xw_i,NFFT); Y = Y/sum(Y);
f = Fs/2*linspace(0,1,NFFT/2);

% Plot single-sided amplitude spectrum.
plot(f,2*abs(Y(1:NFFT/2))) 
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)'); ylabel('|Y(f)|'); 

