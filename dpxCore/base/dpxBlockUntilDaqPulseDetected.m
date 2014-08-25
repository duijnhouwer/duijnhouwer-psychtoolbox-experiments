function detectTimeSeconds=dpxBlockUntilDaqPulseDetected(delaySeconds)        % function that waits until a pulse is detected on the DAQ        if nargin==0        delaySeconds=1;    end    daq=DaqDeviceIndex([],0); % Get Device-number    if isempty(daq)        error('No DAQ-unit detected. Is it connected?');    end    %DaqCInit(daq); % set pulse counter to zero    startCount=DaqCIn(daq);    while true        pulseCount=DaqCIn(daq);        if pulseCount-startCount==1            detectTimeSeconds=GetSecs;            break;        elseif pulseCount-startCount>1            % may also occur if the 32 counter on the DAQ goes through            % it's ceiling.            error('Missed the first pulse!?!? Try starting again ...');        else            ... keep waiting        end    end    if delaySeconds>0        disp(['Pulse detected on DAQ,  waiting an additional ' num2str(delaySeconds*1000,'%d') ' ms ...']);        alreadyPassed=GetSecs-detectTimeSeconds;        WaitSecs(alreadyPassed-delaySeconds)    endend            