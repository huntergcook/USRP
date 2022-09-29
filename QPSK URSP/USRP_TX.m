try release(tx); end
clc; clear;

Fc = 915e6; %Center Frequnecy
Gain = 50; %Transmit Gain
SamplesPerSymbol = 10;
SymbolsPerFrame = 1e3; %Sampling Rate (Based on radio params below)
Fs = (60e6/60);

tx = comm.SDRuTransmitter('Platform','B210', ...
    'SerialNum','316407B', ...
    'CenterFrequency',Fc, ...
    'Gain',Gain, ...
    'PPSSource','External', ...
    'ClockSource','External', ...
    'MasterClockRate',60e6,...
    'InterpolationFactor',60);
tx.EnableBurstMode = false;

qpskmod = comm.QPSKModulator; %QPSK
data = qpskmod(randi([0 3],SymbolsPerFrame,1))'; %QPSK symbols
jj = 1;
for ii = 1:length(data) %Upsample by symbol redundancy
    upsamples(1:SamplesPerSymbol) = data(ii);
    data_upsample(jj:jj+SamplesPerSymbol-1) = upsamples;
    jj = jj + SamplesPerSymbol;
end

% figure(1)
% dscatter(double(real(data)),double(imag(data)));
% grid on
% xlabel('Real'); ylabel('Imaginary');
% title('TX Constellation');

%FFT
% figure(2)
% spectrum = fftshift(fft(data));
% fspan = (-SamplesPerFrame/2:SamplesPerFrame/2-1)*(Fs/SamplesPerFrame)/1e3;
% semilogy(fspan,abs(spectrum.^2)/SamplesPerFrame);
% title('FFT of Signal');
% ylabel('Power'); xlabel('KHz');
% grid on;

%% TX
i = 0
% See MATLAB manual and readme
while 1 %Continuously transmit
    underruncount = 0;
    tx(data_upsample');
    i = i +1
end