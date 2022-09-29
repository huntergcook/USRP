try release(tx); end
clc; clear;

load('refs.mat','seq1');
load('refs.mat','seq2');
load('refs.mat','seq3');

Fc = 915e6; %Center Frequnecy
Gain = 30; %Transmit Gain
OSFactor = 10;
SamplesPerFrame = OSFactor*numel(seq1); %Sampling Rate (Based on radio params below)
Fs = 60e6/10;

tx = comm.SDRuTransmitter('Platform','B210', ...
    'SerialNum','316407B', ...
    'CenterFrequency',Fc, ...
    'Gain',Gain, ...
    'PPSSource','External', ...
    'ClockSource','External', ...
    'MasterClockRate',60e6,...
    'InterpolationFactor',10);
tx.EnableBurstMode = false;
% tx.NumFramesInBurst = 1;

sinGen1 = dsp.SineWave("Frequency",100e3,...
        'SampleRate',Fs,...
        'SamplesPerFrame',SamplesPerFrame,...
        'ComplexOutput',false);
sinGen2 = dsp.SineWave("Frequency",300e3,...
        'SampleRate',Fs,...
        'SamplesPerFrame',SamplesPerFrame,...
        'ComplexOutput',false);
sinGen3 = dsp.SineWave("Frequency",500e3,...
        'SampleRate',Fs,...
        'SamplesPerFrame',SamplesPerFrame,...
        'ComplexOutput',false);
carrier1 = sinGen1();
carrier2 = sinGen2();
carrier3 = sinGen3();

mod = comm.BPSKModulator();
modData1 = my_upsample(mod(seq1'),OSFactor)';
modData2 = my_upsample(mod(seq2'),OSFactor)';
modData3 = my_upsample(mod(seq3'),OSFactor)';

signalOut = (carrier1.*modData1 + carrier2.*modData2 + carrier3.*modData3) / 3;

%% TX
i = 0
% See MATLAB manual and readme
while 1 %Continuously transmit
    underruncount = 0;
    tx(signalOut);
    i = i +1
end