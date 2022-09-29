try release(rx); end
clc; clear;

Fc = 915e6; %Center Frequency
Gain = 0; %Recieve Gain
SamplesPerSymbol = 1; %Should match TX for downsample
Fs = 60e6/60; %Sampling Rate (Based on radio params below)
SymbolsPerFrame = 1e3;
SamplesPerFrame = SamplesPerSymbol*SymbolsPerFrame;
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


while(1)
    %% RX
    % See MATLAB manual and readme
    len = 0;
    while len<=0
        [data_upsample,len] = rx();
    end
    %downsample
    data = resample(double(data_upsample),1,SamplesPerSymbol); %Downsample
    data_normed = normalize(data); %Normalize for plotting
    I = double(real(data_normed)); %Seperate In-Phase
    Q = double(imag(data_normed)); %Seperate Quadrature
    
    % TIME PLOTS
    figure(1)
    dscatter(I,Q);
    xlim([-1.5 1.5]); ylim([-1.5 1.5]);
    grid on
    xlabel('Real'); ylabel('Imaginary');
    title('RX Constellation');
    
    % FFT
    % figure(3)
    % spectrum = fftshift(fft(data));
    % fspan = (-SamplesPerFrame/2:SamplesPerFrame/2-1)*(Fs/SamplesPerFrame)/1e3;
    % semilogy(fspan,abs(spectrum.^2)/SamplesPerFrame);
    % title('FFT of Signal');
    % ylabel('Power'); xlabel('KHz');
    % grid on;
end