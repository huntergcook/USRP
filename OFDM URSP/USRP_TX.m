try release(tx); end
clc; clear;

barker = [1 1 1 1 1 0 0 1 1 0 1 0 1];
barker_len = 13;

Fc = 915e6; %Center Frequnecy
Gain = 50; %Transmit Gain
SamplesPerSymbol = 2;
SamplesPerFrame = (80 + barker_len)*SamplesPerSymbol; %Sampling Rate (Based on radio params below)
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

bpskMod = comm.BPSKModulator;
modBarker = bpskMod(barker');
mod = comm.OFDMModulator;
modDim = info(mod);
% showResourceMapping(mod);
dataIn = complex( ...
    randn(modDim.DataInputSize),randn(modDim.DataInputSize));
modData = mod(dataIn);
data = [modBarker; modData];
data_upsample = my_upsample(data,SamplesPerSymbol);

% figure(1)
    % dscatter(double(real(data)),double(imag(data)));
    % grid on
    % xlabel('Real'); ylabel('Imaginary');
    % title('TX Constellation');

% FFT
    % figure(2)
    % spectrum = fftshift(fft(data));
    % fspan = (-SamplesPerFrame/2:SamplesPerFrame/2-1)*(Fs/SamplesPerFrame)/1e3;
    % semilogy(fspan,abs(spectrum.^2)/SamplesPerFrame);
    % title('FFT of Signal');
    % ylabel('Power'); xlabel('KHz');
    % grid on;
    
%     figure(3)
%     spectrum = fftshift(fft(modData));
%     fspan = (-80/2:80/2-1)*(Fs/80)/1e3;
%     semilogy(fspan,abs(spectrum.^2)/80);
%     title('FFT of Signal');
%     ylabel('Power'); xlabel('KHz');
%     grid on;

%% TX
i = 0
% See MATLAB manual and readme
while 1 %Continuously transmit
    underruncount = 0;
    tx(data_upsample');
    i = i +1
end