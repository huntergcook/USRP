try release(rx); end
clc; clear;

Fc = 915e6; %Center Frequency
Gain = 0; %Recieve Gain
Fs = 60e6/60; %Sampling Rate (Based on radio params below)
SamplesPerFrame = 1e5;
TimePerFrame = SamplesPerFrame / Fs;

rx = comm.SDRuReceiver('Platform','B210', ...
    'SerialNum','316405A', ...
    'CenterFrequency',Fc, ...
    'Gain',Gain, ...
    'PPSSource','External', ...
    'ClockSource','External', ...
    'SamplesPerFrame',SamplesPerFrame,...
    'MasterClockRate',60e6,...
    'DecimationFactor',60);
rx.EnableBurstMode = false;


%% RX
% See MATLAB manual and readme
len = 0;
while len<=0
    [data,len] = rx();
end

%% TIME PLOTS
% figure(1)
% plot(real(data))
% figure(2)
% plot(imag(data))

%% FFT
figure(3)
spectrum = fftshift(fft(data));
fspan = (-SamplesPerFrame/2:SamplesPerFrame/2-1)*(Fs/SamplesPerFrame)/1e3;
semilogy(fspan,abs(spectrum.^2)/SamplesPerFrame);
title('FFT of Signal');
ylabel('Power'); xlabel('KHz');
grid on;