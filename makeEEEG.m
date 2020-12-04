function eeg = makeEEEG(wAmp,wLength,sRate,fAmp,fReq,bLength,bDelay,nEpochs,bJitter,varargin)

    % by O. Krigolson
    % make epoched EEG waveform
    % specificy the amplitude of the noise (wAmp), the length of the epoch
    % (wLength), the sampling rate (sRate), the frequency amplitude(s)
    % (fAmp), the frequency frequecies (fReq), the length of the frequency
    % burst (bLength), the delay from the start of the epoch (bDelay), the
    % number of epochs (nEpochs), the jitter of the frequency burst
    % (bJitter), and if you want to plot a sample epoch and the epoch
    % average (1) optional.
    % set flength to be less that the epoch length to create a burst in the
    % epoch and delay it from the start with fDelay
    % all time units are in seconds
    % sample call
    % eeg = makeEEEG(1,1,500,[4 6],[60 10],[0.1],[0.6],100,[0.1],1);
    
    showPlot = 0;
    if length(varargin) > 0
        showPlot = varargin{1};
    end
    
    for trialCounter = 1:nEpochs
    
        % set up the epoch
        sPeriod = 1/sRate; %seconds
        t = (0:sPeriod:wLength); % seconds
        
        % create noise in the epoch
        noise = rand(1,length(t))*(wAmp*2) - wAmp; % random noise centered at zero 

        fPeriod = 1/sRate; %seconds
        t = (0:fPeriod:bLength); % seconds 
        sinWave(1:length(t)) = 0;
        for i = 1:length(fReq)

            F = fReq(i); % Sine wave frequency (hertz)
            sinBurst = [];
            sinBurst = sin(2*pi*F*t)*fAmp(i);
            sinWave = sinWave + sinBurst;

        end

        trialeeg = [];
        trialeeg = noise;
        
        bStart = round(bDelay * sRate);
        bJit = round(bJitter * sRate);
        bJit = round(rand(1)*bJit*2 - bJit);
        bStart = bStart + bJit;
        
        trialeeg(bStart:bStart+length(sinWave)-1) = trialeeg(bStart:bStart+length(sinWave)-1) + sinWave;
       
        eeg(:,trialCounter) = trialeeg;
        
    end
    
    if showPlot == 1
        subplot(3,1,1);
        plot(sinWave);
        title('sin wave');
        subplot(3,1,2);
        plot(trialeeg);
        title('sample trial');
        subplot(3,1,3);
        meeg = mean(eeg,2);
        plot(meeg);
        title('average eeg');
    end
    
end

    