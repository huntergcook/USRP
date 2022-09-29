try release(rx); end
clc; clear;

load('refs.mat','seq1');
load('refs.mat','seq2');
load('refs.mat','seq3');

Fc = 915e6; %Center Frequnecy
Gain = 0; %Transmit Gain
OSFactor = 10;
SamplesPerFrame = OSFactor*numel(seq1); %Sampling Rate (Based on radio params below)
Fs = 60e6/10;

rx = comm.SDRuReceiver('Platform','B210', ...
    'SerialNum','316405A', ...
    'CenterFrequency',Fc, ...
    'Gain',Gain, ...
    'PPSSource','External', ...
    'ClockSource','External', ...
    'SamplesPerFrame',2*SamplesPerFrame,...
    'MasterClockRate',60e6,...
    'DecimationFactor',10);
rx.EnableBurstMode = false;


%% RX
% See MATLAB manual and readme
while 1
    len = 0;
    while len<=0
        [rx_samples,len] = rx();
    end
    rx_samples = double(rx_samples);
    
   sinGen1 = dsp.SineWave("Frequency",100e3,...
        'SampleRate',Fs,...
        'SamplesPerFrame',SamplesPerFrame,...
        'ComplexOutput',true);
    sinGen2 = dsp.SineWave("Frequency",300e3,...
        'SampleRate',Fs,...
        'SamplesPerFrame',SamplesPerFrame,...
        'ComplexOutput',true);
    sinGen3 = dsp.SineWave("Frequency",500e3,...
        'SampleRate',Fs,...
        'SamplesPerFrame',SamplesPerFrame,...
        'ComplexOutput',true);
    carrier1 = sinGen1();
    carrier2 = sinGen2();
    carrier3 = sinGen3();

    mod = comm.BPSKModulator();
    modData1 = my_upsample(mod(seq1'),OSFactor)';
    modData2 = my_upsample(mod(seq2'),OSFactor)';
    modData3 = my_upsample(mod(seq3'),OSFactor)';
    signal1 = carrier1.*modData1;
    signal2 = carrier2.*modData2;
    signal3 = carrier3.*modData3;

    rx1_filt = lowpass(rx_samples,[200e3],Fs);
    rx2_filt = bandpass(rx_samples,[200e3 400e3],Fs);
    rx3_filt = bandpass(rx_samples,[400e3 600e3],Fs);

    [r1 lag1] = my_maxcorr(signal1,rx1_filt);
    [r2 lag2] = my_maxcorr(signal2,rx2_filt);
    [r3 lag3] = my_maxcorr(signal3,rx3_filt);

    data = rx_samples(lag1:lag1+SamplesPerFrame-1);
   

    if lag1 == lag2 && lag2 == lag3
        % PHASE
        figure(1)
        compass([r1 r2 r3])
        
        % FFT
        figure(2)
        spectrum = fftshift(fft(data));
        fspan = (-SamplesPerFrame/2:SamplesPerFrame/2-1)*(Fs/SamplesPerFrame)/1e3;
        semilogy(fspan,abs(spectrum.^2)/SamplesPerFrame);
        title('FFT of Signal');
        ylabel('Power'); xlabel('KHz');
        grid on;
    end
end