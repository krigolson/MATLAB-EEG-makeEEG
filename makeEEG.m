clear all;
close all;
clc;

% creates four channels of EEG data with two conditions and n trials with four different size burts of different
% frequencies for m participants
% developed by Olav Krigolson, January 2019

% variables to set
startTime = -500;
endTime = 1498;
samplingRate = 500;
numberOfTrials = 100;
noiseScaling = 0;                       % default noise range is -0.5 to 0.5
channelScaling = [1 0.5 0.1 0.1];       % the multiplier for the second channel to simulate channel reduction in signal
conditionScaling = [1 0.3];             % scales the conditions relative to each other to create simple "effects"
participantScaling = [1 1 1 1 1];       % scaling the data to simulate participant difference
waveletBaseline = [];
morletParameter = 6;                    % recommend 6, range is 3 to 8
minWaveletFrequency = 1;
maxWaveletFrequency = 30;
waveletSteps = 30;

% define a series of frequency bursts to insert into the data, you can
% specify the number of cycles to be inserted, the code can handle up to
% four bursts. If you want a continuous burst of EEG set the burstCentre to
% be equal to 0.
bursts{1}.frequency = 6;                % frequency of the burst
bursts{1}.burstCentre = 250;            % timepoint for burst center, set to 0 to span waveform
bursts{1}.burstTimingNoise = 0;         % the jitter in ms of the burst center
bursts{1}.amplitude = -4;               % peak burst amplitude
bursts{1}.amplitudeNoise = 0;           % the jitter in the burst amplitude            
bursts{1}.cycles = 0.5;                 % how long the burst spans (for bursts not spanning waveform)

bursts{2}.frequency = 2;
bursts{2}.burstCentre = 350;
bursts{2}.burstTimingNoise = 0;        % the jitter in ms of the burst center
bursts{2}.amplitude = 6;
bursts{2}.amplitudeNoise = 0;
bursts{2}.cycles = 0.5;

bursts{3}.frequency = 0;
bursts{3}.burstCentre = 0;
bursts{3}.burstTimingNoise = 0;        % the jitter in ms of the burst center
bursts{3}.amplitude = 0;
bursts{3}.amplitudeNoise = 0;
bursts{3}.cycles = 0;

bursts{4}.frequency = 0;
bursts{4}.burstCentre = 0;
bursts{4}.burstTimingNoise = 0;        % the jitter in ms of the burst center
bursts{4}.amplitude = 0;
bursts{4}.amplitudeNoise = 0;
bursts{4}.cycles = 0;

%%% only change the code below here if you know what you are doing

% determine the number of channels
numberOfChannels = length(channelScaling);
numberOfConditions = length(conditionScaling);
numberOfParticipants = length(participantScaling);

% define a time vector
timePoints = startTime:(1/samplingRate*1000):endTime;
interval = length(timePoints)/8;
tickPoints(1) = 1;
tickLabels(1) = startTime;
for counter = 2:8
    tickPoints(counter) = tickPoints(counter-1) + interval;
    tickLabels(counter) = timePoints(tickPoints(counter));
end
for participantCounter = 1:numberOfParticipants
    
    % determine current condition scaling
    currentParticipantScaling = participantScaling(participantCounter);

    for conditionCounter = 1:length(conditionScaling)

        % make waveform
        data = [];
        data(1:numberOfChannels,1:length(timePoints),1:numberOfTrials) = 0;

        % determine current condition scaling
        currentConditionScaling = conditionScaling(conditionCounter);

        % add some noise
        for channelCounter = 1:numberOfChannels
            eegNoise = (rand(length(timePoints),numberOfTrials)-0.5)*noiseScaling;
            data(channelCounter,:,:) = eegNoise;
        end

        for channelCounter = 1:numberOfChannels

            % determine channel scaling
            currentChannelScaling = channelScaling(channelCounter);

            for trialCounter = 1:numberOfTrials

                for burstCounter = 1:size(bursts,2)

                    % make the sine Wave;
                    fs=samplingRate;
                    dt = 1/fs;
                    f=bursts{burstCounter}.frequency;
                    T=1/f;
                    if bursts{burstCounter}.burstCentre == 0
                        t = 0:dt:size(data,2)/samplingRate-dt;
                    else
                        t = 0:dt:(T*bursts{burstCounter}.cycles)+dt;
                    end
                    burstNoise = (randn(1)-0.5)*bursts{burstCounter}.amplitudeNoise;
                    burstAmplitude = (bursts{burstCounter}.amplitude + burstNoise) * currentChannelScaling * currentConditionScaling * currentParticipantScaling;
                    sineWave = [];
                    sineWave = burstAmplitude * sin(2*pi*f*t);
                    try
                        burthWidth = round(length(t)/2);
                        insertionMiddle = find(timePoints == bursts{burstCounter}.burstCentre);
                        burstJitter = (round((randn(1)-0.5) * bursts{burstCounter}.burstTimingNoise));
                        insertionMiddle = insertionMiddle + burstJitter;
                        insertionStart = insertionMiddle - burthWidth;
                        insertionEnd = insertionMiddle + burthWidth;
                    catch
                        error('Time point for burst insertion is not valid');
                    end

                    tempWave = [];
                    tempWave = squeeze(data(channelCounter,:,trialCounter));
                    addWave(1:length(tempWave)) = 0;
                    if bursts{burstCounter}.burstCentre == 0
                        addWave = addWave + sineWave;
                    else
                        addWave(insertionStart:insertionStart+length(sineWave)-1) = addWave(insertionStart:insertionStart+length(sineWave)-1) + sineWave;
                    end
                    tempWave = tempWave + addWave;
                    bursts{burstCounter}.burst = addWave;
                    data(channelCounter,:,trialCounter) = tempWave;

                end

            end    % trial loop

        end    % channel loop

        EEG.data(:,:,:,conditionCounter,participantCounter) = data;
        
        ERP.data(:,:,conditionCounter,participantCounter) = mean(data,3);
        
        [fftoutput frequencies] = doFFT(data,samplingRate,length(tempWave));
        
        FFT.data(:,:,conditionCounter,participantCounter) = fftoutput;
        
        [waveletData,waveletDataPercent,frex] = doWavelet(data,timePoints,waveletBaseline,minWaveletFrequency,maxWaveletFrequency,waveletSteps,morletParameter,samplingRate);
        
        WAV.data(:,:,:,conditionCounter,participantCounter) = waveletData;

    end     % condition loop

end    % participant counter

% visualize burts
figure;
subplot(1,4,1);
plot(timePoints,bursts{1}.burst);
subplot(1,4,2);
plot(timePoints,bursts{2}.burst);
subplot(1,4,3);
plot(timePoints,bursts{3}.burst);
subplot(1,4,4);
plot(timePoints,bursts{4}.burst);

% visualize ERPs
figure;
grandERPs = mean(ERP.data,4);
minY = min(min(min(grandERPs)));
maxY = max(max(max(grandERPs)));
subplot(2,4,1);
plot(timePoints,grandERPs(1,:,1));
title('Channel One, Condition One');
ylim([minY,maxY]);
subplot(2,4,2);
plot(timePoints,grandERPs(2,:,1));
title('Channel Two, Condition One');
ylim([minY,maxY]);
subplot(2,4,3);
plot(timePoints,grandERPs(3,:,1));
title('Channel Three, Condition One');
ylim([minY,maxY]);
subplot(2,4,4);
plot(timePoints,grandERPs(4,:,1));
title('Channel Four, Condition One');
ylim([minY,maxY]);
subplot(2,4,5);
plot(timePoints,grandERPs(1,:,2));
title('Channel One, Condition Two');
ylim([minY,maxY]);
subplot(2,4,6);
plot(timePoints,grandERPs(2,:,2));
title('Channel Two, Condition Two');
ylim([minY,maxY]);
subplot(2,4,7);
plot(timePoints,grandERPs(3,:,2));
title('Channel Three, Condition Two');
ylim([minY,maxY]);
subplot(2,4,8);
plot(timePoints,grandERPs(4,:,2));
title('Channel Four, Condition Two');
ylim([minY,maxY]);

% visualize FFTs
figure;
maxFrequency = 50;
grandFFTs = mean(FFT.data,4);
minY = min(min(min(grandFFTs)));
maxY = max(max(max(grandFFTs)));
subplot(2,4,1);
bar(frequencies(1:maxFrequency),grandFFTs(1,1:maxFrequency,1));
title('Channel One, Condition One');
ylim([minY,maxY]);
subplot(2,4,2);
bar(frequencies(1:maxFrequency),grandFFTs(2,1:maxFrequency,1));
title('Channel Two, Condition One');
ylim([minY,maxY]);
subplot(2,4,3);
bar(frequencies(1:maxFrequency),grandFFTs(3,1:maxFrequency,1));
title('Channel Three, Condition One');
ylim([minY,maxY]);
subplot(2,4,4);
bar(frequencies(1:maxFrequency),grandFFTs(4,1:maxFrequency,1));
title('Channel Four, Condition One');
ylim([minY,maxY]);
subplot(2,4,5);
bar(frequencies(1:maxFrequency),grandFFTs(1,1:maxFrequency,2));
title('Channel One, Condition Two');
ylim([minY,maxY]);
subplot(2,4,6);
bar(frequencies(1:maxFrequency),grandFFTs(2,1:maxFrequency,2));
title('Channel Two, Condition Two');
ylim([minY,maxY]);
subplot(2,4,7);
bar(frequencies(1:maxFrequency),grandFFTs(3,1:maxFrequency,2));
title('Channel Three, Condition Two');
ylim([minY,maxY]);
subplot(2,4,8);
bar(frequencies(1:maxFrequency),grandFFTs(4,1:maxFrequency,2));
title('Channel Four, Condition Two');
ylim([minY,maxY]);

% visualize Wavelets
minColour = min(min(min(min(min(WAV.data)))));
maxColour = max(max(max(max(max(WAV.data)))));
figure;
maxFrequency = 50;
meanWAV = mean(WAV.data,5);
subplot(2,4,1);
surf(squeeze(meanWAV(1,:,:,1)));shading interp; view(2);
title('Channel One, Condition One');
caxis([minColour maxColour]);
ax = gca;
ax.XTick = tickPoints;
ax.XTickLabel = tickLabels;
ylim([minWaveletFrequency maxWaveletFrequency]);
subplot(2,4,2);
surf(squeeze(meanWAV(2,:,:,1)));shading interp; view(2);
title('Channel Two, Condition One');
caxis([minColour maxColour]);
ax = gca;
ax.XTick = tickPoints;
ax.XTickLabel = tickLabels;
ylim([minWaveletFrequency maxWaveletFrequency]);
subplot(2,4,3);
surf(squeeze(meanWAV(3,:,:,1)));shading interp; view(2);
title('Channel Three, Condition One');
caxis([minColour maxColour]);
ax = gca;
ax.XTick = tickPoints;
ax.XTickLabel = tickLabels;
ylim([minWaveletFrequency maxWaveletFrequency]);
subplot(2,4,4);
surf(squeeze(meanWAV(4,:,:,1)));shading interp; view(2);
title('Channel Four, Condition One');
caxis([minColour maxColour]);
ax = gca;
ax.XTick = tickPoints;
ax.XTickLabel = tickLabels;
ylim([minWaveletFrequency maxWaveletFrequency]);
subplot(2,4,5);
surf(squeeze(meanWAV(1,:,:,2)));shading interp; view(2);
title('Channel One, Condition Two');
caxis([minColour maxColour]);
ax = gca;
ax.XTick = tickPoints;
ax.XTickLabel = tickLabels;
ylim([minWaveletFrequency maxWaveletFrequency]);
subplot(2,4,6);
surf(squeeze(meanWAV(2,:,:,2)));shading interp; view(2);
title('Channel Two, Condition Two');
caxis([minColour maxColour]);
ax = gca;
ax.XTick = tickPoints;
ax.XTickLabel = tickLabels;
ylim([minWaveletFrequency maxWaveletFrequency]);
subplot(2,4,7);
surf(squeeze(meanWAV(3,:,:,2)));shading interp; view(2);
title('Channel Three, Condition Two');
caxis([minColour maxColour]);
ax = gca;
ax.XTick = tickPoints;
ax.XTickLabel = tickLabels;
ylim([minWaveletFrequency maxWaveletFrequency]);
subplot(2,4,8);
surf(squeeze(meanWAV(4,:,:,2)));shading interp; view(2);
title('Channel Four, Condition Two');
caxis([minColour maxColour]);
ax = gca;
ax.XTick = tickPoints;
ax.XTickLabel = tickLabels;
ylim([minWaveletFrequency maxWaveletFrequency]);