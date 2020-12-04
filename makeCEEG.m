function eeg = makeCEEG(wAmp,wLength,sRate,fAmp,fReq,fLength,howOften,varargin)

    % by O. Krigolson
    % makes a continuous EEG waveform
    % if you want the frequency data to be continuous, set wLength to be
    % equal to fLength and howOften is not needed and set it to zero
    % e.g., eeg = makeCWave(5,1,500,[2 3 5],[2 30 60],1,0,1);
    % if you want "bursts" then make fLength shorter and
    % specifcy how often you want the burst
    % e.g., eeg = makeCEEG(1,10,250,[2 3 3],[2 30 60],1,0.4,1);
    % all time units are in seconds
    
    showPlot = 0;
    if length(varargin) > 0
        showPlot = varargin{1};
    end
    
    % covert howOften to data points
    howOften = howOften * sRate;
    
    sPeriod = 1/sRate; %seconds
    t = (0:sPeriod:wLength); % seconds 

    noise = rand(1,length(t))*(wAmp*2) - wAmp; % random noise centered at zero 
    
    eeg = noise;
    
    x1 = 1;
    x2 = round(fLength * sRate);
    
    while x2 < length(eeg)
    
        fPeriod = 1/sRate; %seconds
        t = (0:fPeriod:fLength); % seconds 
        sinWave(1:length(t)) = 0;
        for i = 1:length(fReq)

            F = fReq(i); % Sine wave frequency (hertz)
            sinBurst = [];
            sinBurst = sin(2*pi*F*t)*fAmp(i);
            sinWave = sinWave + sinBurst;

        end
        
        eeg(x1:x2+1) = eeg(x1:x2+1) + sinWave;
        
        x1 = x2 + howOften + 1;
        x2 = x2 + round(fLength * sRate) + howOften;
        
    end
    
    
    if showPlot == 1
        subplot(3,1,1);
        plot(noise);
        title('noise');
        subplot(3,1,2);
        plot(sinWave);
        title('sin wave');
        subplot(3,1,3);
        plot(eeg);
        title('eeg');
    end
    
end

    