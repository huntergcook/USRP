try release(rx); end
clc; clear;

barker = [1 1 1 1 1 0 0 1 1 0 1 0 1];
barker_len = 13;

Fc = 915e6; %Center Frequency
Gain = 0; %Recieve Gain
SamplesPerSymbol = 2; %Should match TX for downsample
Fs = 60e6/60; %Sampling Rate (Based on radio params below)
SamplesPerFrame = (80 + barker_len)*SamplesPerSymbol;

rx = comm.SDRuReceiver('Platform','B210', ...
    'SerialNum','316405A', ...
    'CenterFrequency',Fc, ...
    'Gain',Gain, ...
    'PPSSource','External', ...
    'ClockSource','External', ...
    'SamplesPerFrame',2*(SamplesPerFrame),...
    'MasterClockRate',60e6,...
    'DecimationFactor',60);
rx.EnableBurstMode = false;

bpskMod = comm.BPSKModulator;
modBarker = bpskMod(barker');
modBarker_upsample = my_upsample(modBarker,SamplesPerSymbol)';
mod = comm.OFDMModulator;
demod = comm.OFDMDemodulator(mod);

while(1)
    %% RX
    % See MATLAB manual and readme
    len = 0;
    while len<=0
        [rx_samples,len] = rx();
    end
    rx_samples = double(rx_samples);
    [r lag] = my_maxcorr(modBarker_upsample,rx_samples(1:SamplesPerFrame));
    intermediate = r*rx_samples;
    modData = r*rx_samples(lag:lag+SamplesPerFrame-barker_len-1);

    %downsample
%     data = resample(double(data_upsample),1,SamplesPerSymbol); %Downsample
%     data_normed = normalize(data); %Normalize for plotting
%     I = double(real(data_normed)); %Seperate In-Phase
%     Q = double(imag(data_normed)); %Seperate Quadrature
    
    %demod
    [dataOut, pilotOut] = demod(modData);

    % TIME PLOTS
%     figure(1)
%     dscatter(I,Q);
%     xlim([-1.5 1.5]); ylim([-1.5 1.5]);
%     grid on
%     xlabel('Real'); ylabel('Imaginary');
%     title('RX Constellation');
    
    %FFT
%     figure(3)
%     spectrum = fftshift(fft(data));
%     ylim([-10 1000]);
%     fspan = (-SamplesPerFrame/2:SamplesPerFrame/2-1)*(Fs/SamplesPerFrame)/1e3;
%     semilogy(fspan,abs(spectrum.^2)/SamplesPerFrame);
%     title('FFT of Signal');
%     ylabel('Power'); xlabel('KHz');
%     grid on;
end