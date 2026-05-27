function xw_r=tst_WD1r(Fs, xw_i)
% record from the microphone
%Fs=10e3;			% 10780
%Fs = 8000; 
Ts = 1/Fs;
%Tf = 3;	% 8e3, 8Khz with final time of 3 sec
Tf=size(xw_i,1)/Fs;
%xw_i=wavrecord(16000, 8000, 'double');	
%load xw_i; load xw_i_2k;
%xw_i=xw_i+xw_i_2k; 	% with 2k noise
%xw_i=wavrecord(Fs*Tf, Fs, 'double');	% 3sec with 8KHz sampling
%recObj=audiorecorder(Fs,16,1); recordblocking(recObj,Tf); xw_i=getaudiodata(recObj,'double');

% play it back
%wavplay(xw_i)
%player = audioplayer(xw_i, Fs); play(player);

% play it back at the right sampling rate
%wavplay(xw_i, 8000)
%wavplay(xw_i, Fs)
player = audioplayer(xw_i, Fs); play(player);
disp('Press <ENTER> key to continue');		% read "Digital Signal Processing"
pause	

% FFT before
do_display_fft_Fs(xw_i,Fs)

% Channel, Filter (FIR Windowing, Causal!)
figure;
%Fs = 8000;		% filter sampling frequency
%Ts = 1/Fs; Tf = 3;
fc = 1050; wc=2*pi*fc;	% 2.5, 5, 10, 20, 1000
t=0:1:round(Tf*Fs);	% t=0:1:Tf*Fs;

t_zc=1/(2*fc);	% t_zc=pi/(2*pi*fc)
n_zc=floor(Fs*t_zc);

N=20*n_zc+1;	%N=size(t,2); 
Ftype=2; WnL=wc/Fs; WnH=wc/Fs; Wtype=3; % LPH(1),HPF(2)
B=firwd(N,Ftype,WnL,WnH,Wtype); 
h9=B; sum_h9=sum(h9); h9=h9/sum_h9;
ct_i=floor(N/2+1);
h9=h9(ct_i-n_zc:end);
sum_h9=sum(h9); h9=h9/sum_h9;
subplot(3,1,1); stem(t(1:size(h9,2))*Ts, h9); xlabel('Time (sec)'); ylabel('h(t)');

title('impulse response of channel h_9(t)');
%xc=0+0*cos(10*2*pi*t*Ts) + 1*sin(1*2*pi*t*Ts);	% f1=10Hz, f2=1Hz
xa=xw_i; xa=[xa' zeros(1,1)];	% size matching by zero padding
subplot(3,1,2); stem(t*Ts, xa); xlabel('Time (sec)'); ylabel('x(t)');
title('input signal x_a(t)');
%plot(t,h9)	% plot(t/pi,y)
y1=conv(xa,h9);
subplot(3,1,3);
% plot(y1); 
stem(t*Ts, y1(1:length(xa))); xlabel('Time (sec)'); ylabel('y_1(t)');
title('filtered output with f_c=1.05KHz, f_s=8.0KHz');
y2=y1(1:length(xa));
%y2=decimate(y2,2);

% FFT of Filter
figure;
xw_i=h9';		% xw_i=h9(1:end-1)'
do_display_fft_Fs(xw_i,Fs)


% FFT after
figure;
xw_i=y2(1:end-1)';
do_display_fft_Fs(xw_i,Fs)

%wavplay(y2)
%wavplay(y2,Fs)
%wavwrite(y2,Fs,'yourfile.wav');
xw_r=xw_i;
