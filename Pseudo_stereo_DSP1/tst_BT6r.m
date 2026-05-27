function xw_r=tst_BT6r(Fs, xw_i)
% record from the microphone
%Fs=10e3;			% 10780
%Fs = 8000; Tf = 3;		% 8e3, 8Khz with final time of 3 sec
Tf=size(xw_i,1)/Fs;
%xw_i=wavrecord(16000, 8000, 'double');	
%load xw_i; load xw_i_2k;
%xw_i=xw_i+xw_i_2k; 	% with 2k noise
%xw_i=wavrecord(Fs*Tf, Fs, 'double');	% 3sec with 8KHz sampling
%recObj=audiorecorder(Fs,16,1); recordblocking(recObj,Tf); xw_i=getaudiodata(recObj,'double');

% play it back
%wavplay(xw_i)
player = audioplayer(xw_i, Fs); play(player);

% play it back at the right sampling rate
%wavplay(xw_i, 8000)
%wavplay(xw_i, Fs)
player = audioplayer(xw_i, Fs); play(player);
disp('Press <ENTER> key to continue');		% read "Digital Signal Processing"
pause	

% FFT before
do_display_fft_Fs(xw_i,Fs)

% Channel, Filter (IIR)
figure;
%Fs=8000; 
Ts=1/Fs; L=round(Fs*Tf);	% DT filter (step & convolution)
n=0:L-1;
x2=ones(L,1); x3=ones(L,1); x3(1)=0;
fc=550; wc=2*pi*fc;		% fc=5 cycle/sec[Hz], 1050
%n1 = [wc^2]; d1 = [1 sqrt(2)*wc wc^2]; sys=tf(n1, d1);
%b=[1]; a=[1 sqrt(2) 1];	% 2nd order Butterworth LP
%[n1,d1]=lp2lp(b,a,wc); sys1=tf(n1,d1);
c=get_butterworthD(6);	% 6th order BLP
b=[1]; a=conv(conv([1 1],conv([1 c(1) 1],[1 c(2) 1])),[1 c(3) 1]);
[n1,d1]=lp2lp(b,a,wc); sys1=tf(n1,d1);
[num,den] = bilinear(n1,d1,Fs);		
o2=filter(num,den,x2);	% step response s[n]
o3=filter(num,den,x3);	% step response s[n-1]
o1=o2-o3;		% h[n]=s[n]-s[n-1]
% sum_h=sum(o1); h9=o1'/sum_h;
h9=o1';
n_zc=2*ceil((Tf*Fs)/(2*fc))+1;	% zero crossing time
ws=n_zc;	%ws=Fs*Tf;
%wd_1=hamming(ws*2); wd = wd_1(ws+1:end);
%wd_1=boxcar(ws*2); wd = wd_1(ws+1:end);
h9=h9(1:n_zc)';	% h9=h9(1:n_zc).*wd'
sum_h9=sum(h9); h9=h9/sum_h9; 	% h9=1-h9;
subplot(3,1,1); stem(n(1:n_zc)*Ts, h9(1:n_zc)); xlabel('Time (sec)'); ylabel('h(t)');
title('impulse response of channel h_9(t)');

%xc=0+0*cos(10*2*pi*t*Ts) + 1*sin(1*2*pi*t*Ts);	% f1=10Hz, f2=1Hz
xa=xw_i';
subplot(3,1,2); stem(n*Ts, xa); xlabel('Time (sec)'); ylabel('x(t)');
title('input signal x_a(t)');
%plot(t,h9)	% plot(t/pi,y)
y1=conv(xa,h9);
subplot(3,1,3);
% plot(y1); 
stem(n*Ts, y1(1:length(xa))); xlabel('Time (sec)'); ylabel('y_1(t)');
title('filtered output with f_c=1.05KHz, f_s=8.0KHz');
y2=y1(1:length(xa));
%y2=decimate(y2,2);

% FFT of Filter
figure;
xw_i=h9;		% xw_i=h9(1:end-1)
do_display_fft_Fs(xw_i,Fs)


% FFT after
figure;
xw_i=y2(1:end-1)';
do_display_fft_Fs(xw_i,Fs)

%player = audioplayer(xw_i, Fs); play(player);	% wavplay(y2)
%wavplay(y2,Fs)
%wavwrite(y2,Fs,'yourfile.wav');
xw_r=xw_i;

%%%%%%%
%{
figure
subplot(2,1,1); stem(n(1:n_zc)*Ts, h9(1:n_zc)); 
xlabel('Time (sec)'); ylabel('h(t)');
title('impulse response of channel h_9(t)');
%
subplot(2,1,2); stem(n(1:n_zc)*Ts, o2(1:n_zc)); 
xlabel('Time (sec)'); ylabel('h(t)');
title('step response of channel s_9(t)');
%}
