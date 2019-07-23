clear all;
close all;
clc;
 
samplingRate = 500;
frequency = 33;
amplitude = 5;
dt = 1/samplingRate;
T = 1/frequency;
t = 0:dt:1-dt;
% sineWave = amplitude*sin(2*pi*frequency*t);

for counter = 10:-1:1
    
    frequency = frequency - 3;
    
    sineWave = [];
    sineWave = amplitude*sin(2*pi*frequency*t);
    
    subplot(1,3,1);
    plot(t,sineWave);

    subplot(1,3,2);
    [fftOut fftFreq] =  doFourier(sineWave,samplingRate);
    bar(fftOut(1:30));
    ylim([0 50]);
    title('DECREASING FREQUENCY');

    subplot(1,3,3);
    [wavOut,wavPer,wavFreq] = doWavelet(sineWave,t,[],1,30,30,6,samplingRate);
    surf(squeeze(wavOut));
    shading interp; 
    view(2);
    caxis([0 5]);
    
    pause;
    
end