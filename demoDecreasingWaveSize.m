clear all;
close all;
clc;
 
samplingRate = 500;
dataPoints = 500;
frequency = 5;
amplitude = 5;
dt = 1/samplingRate;
T = 1/frequency;
t = 0:dt:dataPoints/samplingRate-dt;
% sineWave = amplitude*sin(2*pi*frequency*t);

startX = 1;
startIn = 25;
endIn = 475
endX = 500;
adjustSize = 25;

for counter = 1:10
    
    sineWave = [];
    sineWave = amplitude*sin(2*pi*frequency*t);
    
    if counter ~= 1
        sineWave(startX:startIn) = 0;
        sineWave(endIn:endX) = 0;
        startIn = startIn + adjustSize;
        endIn = endIn - adjustSize;
    end
    
    subplot(1,3,1);
    plot(t,sineWave);

    subplot(1,3,2);
    [fftOut fftFreq] =  doFourier(sineWave,samplingRate);
    bar(fftOut(1:30));
    ylim([0 50]);
    title('DECREASING WAVE SIZE');

    subplot(1,3,3);
    [wavOut,wavPer,wavFreq] = doWavelet(sineWave,t,[],1,30,30,7,samplingRate);
    surf(squeeze(wavOut));
    shading interp; 
    view(2);
    caxis([0 2.5]);
    ylim([1 30]);
    
    pause;
    
end