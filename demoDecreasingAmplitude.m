clear all;
close all;
clc;
 
samplingRate = 500;
dataPoints = 1000;
frequency = 5;
% amplitude = 10;
dt = 1/samplingRate;
T = 1/frequency;
t = 0:dt:dataPoints/samplingRate-dt;
% sineWave = amplitude*sin(2*pi*frequency*t);

for amplitude = 10:-1:1
    
    sineWave = [];
    sineWave = amplitude*sin(2*pi*frequency*t);
    
    subplot(1,3,1);
    plot(t,sineWave);

    subplot(1,3,2);
    [fftOut fftFreq] =  doFourier(sineWave,samplingRate);
    bar(fftOut(1:30));
    ylim([0 50]);
    title('DECREASING AMPLITUDE');

    subplot(1,3,3);
    [wavOut,wavPer,wavFreq] = doWavelet(sineWave,t,[],1,30,30,7,samplingRate);
    surf(squeeze(wavOut));
    shading interp; 
    view(2);
    caxis([0 20]);
    ylim([1 30]);
    
    pause;
    
end