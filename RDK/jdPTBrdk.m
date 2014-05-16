% jdPTBrdk
% Random dot kinematogram
% Jacob Duijnhouwer, May 2014

function jdPTBrdk
    [E,stimwin]=prepExperiment;
    E=runExperiment(E,stimwin);
    saveExperiment(E)
    endExperiment(E)
end

% --- FUNCTIONS -----------------------------------------------------------

function [E,stimwin]=prepExperiment
    Screen('CloseAll')
    warning off %#ok<WNOFF>
    E.subjectID=upper(input('Subject ID > ','s'));
    E.scriptinfo=getInfoCurrentScript;
    [~,E.psychtoolboxversion]=PsychtoolboxVersion;
    E.openglinfo=opengl('data');
    [E.cond,E.nBlocks,E.setup]=rdkSettings;
    [E.physScr,stimwin]=jdPTBopenStimWindow(E.setup); % physScr contains info on all physical display properties, stimwin is a pointer to window
end


function E=runExperiment(E,stimwin)
    try
        tr=0;
        for b=1:E.nBlocks
            for i=randperm(numel(E.cond))
                tr=tr+1;
                E.trial(tr).stim=createStimBasedOnSettings(E.cond(i),E.physScr);
                fillBackgroundStimWindow(stimwin,E.trial(tr).stim);
                Screen('Flip',stimwin);
                [escape,E.trial(tr).resp]=showStimulus(E.physScr,stimwin,E.trial(tr).stim);
                if escape
                    disp('Escape was pressed, the experiment is terminated');
                    E.trial(tr).message='This experiment was terminated manually (ESC)';
                    break;
                end
            end
        end
    catch %#ok<CTCH>
        saveExperiment(E);
        endExperiment(E);
        psychrethrow(psychlasterror);
    end
end


function scriptinfo=getInfoCurrentScript
    % Get all the lines of this file for future reference
    scriptinfo.name=[mfilename('fullpath') '.m'];
    fid=fopen(scriptinfo.name,'r');
    tline = fgetl(fid);
    nLines=0;
    while ischar(tline)
        nLines=nLines+1;
        scriptinfo.line{nLines}=tline;
        tline = fgetl(fid);
    end
    fclose(fid);
end


function fillBackgroundStimWindow(stimwin,stim)
    Screen('FillRect',stimwin,stim.colBack);
end


function stim=createStimBasedOnSettings(cond,physScr)
    N=cond.ndots;
    stim.nFlips.total=round(cond.durS/physScr.frameDurS);
    stim.nFlips.pre=round(cond.preS/physScr.frameDurS);
    stim.nFlips.post=round(cond.postS/physScr.frameDurS);
    stim.apert=cond.apert.type;
    stim.widPx=cond.apert.widdeg*physScr.deg2px;
    stim.heiPx=cond.apert.heideg*physScr.deg2px;
    stim.pospx.x=physScr.widPx/2+cond.apert.xDeg*physScr.deg2px;
    stim.pospx.y=physScr.heiPx/2+cond.apert.yDeg*physScr.deg2px;
    stim.xPx=rand(1,N)*stim.widPx-stim.widPx/2;
    stim.yPx=rand(1,N)*stim.heiPx-stim.heiPx/2;
    stim.dotdirdeg=ones(1,N)*cond.dirdeg;
    nNoiseDots=round(N*(1-cond.cohereFrac));
    stim.noiseDot=Shuffle([true(1,nNoiseDots) false(1,N-nNoiseDots)]);
    noiseDirs=rand(1,N)*360;
    stim.dotdirdeg(stim.noiseDot)=noiseDirs(stim.noiseDot);
    stim.dotsize=repmat(cond.dotradiusdeg*physScr.deg2px,1,N);
    stim.dotage=floor(rand(1,N)*(cond.nSteps+1));
    stim.maxage=cond.nSteps;
    stim.colBack=cond.colBack*physScr.whiteIdx;
    stim.pxpflip=cond.degps*physScr.deg2px*physScr.frameDurS;
    stim.dotlums=repmat(Shuffle([repmat(cond.colA*physScr.whiteIdx,1,ceil(N/2)) repmat(cond.colB*physScr.whiteIdx,1,floor(N/2))]),3,1);
    stim.fix.xy=cond.fix.xy+[physScr.widPx/2 physScr.heiPx/2];
    stim.fix.rgb=cond.fix.rgb;
    stim.fix.dotsize=cond.fix.radiusdeg*physScr.deg2px;
end


function drawStim(stimwin,stim)
    ok=applyTheAperture(stim.xPx,stim.yPx,stim.apert,stim.widPx);
    xy=[stim.xPx(:) stim.yPx(:)];
    % offset the stimulus
    xy=xy';
    xy(1,:)=xy(1,:)+stim.pospx.x;
    xy(2,:)=xy(2,:)+stim.pospx.y;
    % draw the stimulus
    Screen('DrawDots',stimwin,xy(:,ok),stim.dotsize(ok),stim.dotlums(:,ok),[],1);
end

function drawFixDot(stimwin,fix)
    Screen('DrawDots',stimwin,fix.xy',fix.dotsize,fix.rgb',[],1);
end


function ok=applyTheAperture(x,y,apert,wid,hei)
    if strcmpi(apert,'CIRCLE')
        r=wid/2;
        ok=hypot(x,y)<r;
    else
        error(['Unknown apert option: ' apert ]);
    end
end
   

function stim=stepStim(stim)
    % Reposition the dots, use shorthands for clarity
    x=stim.xPx;
    y=stim.yPx;
    w=stim.widPx;
    h=stim.heiPx;
    dx=cosd(stim.dotdirdeg)*stim.pxpflip;
    dy=sind(stim.dotdirdeg)*stim.pxpflip;
    % Update dot lifetime
    stim.dotage=stim.dotage+1;
    expired=stim.dotage>stim.maxage;
    % give new position if expired
    x(expired)=rand(1,sum(expired))*w-w/2-dx(expired);
    y(expired)=rand(1,sum(expired))*h-h/2-dy(expired);
    % give new random direction if expired and dot is noise
    rndDirs=rand(size(x))*360;
    stim.dotdirdeg(expired&stim.noiseDot)=rndDirs(expired&stim.noiseDot);
    stim.dotage(expired)=0;
    % Move the dots
    x=x+dx;
    y=y+dy;
    if dx>0 
        x(x>=w/2)=x(x>=w/2)-w;
    elseif dx<0
        x(x<-w/2)=x(x<-w/2)+w;
    end
     if dy>0 
        y(y>=h/2)=y(y>=h/2)-h;
    elseif dy<0
        y(y<-h/2)=y(y<-h/2)+h;
    end
    stim.xPx=x;
    stim.yPx=y;
end


function [esc,resp]=showStimulus(physScr,stimwin,stim)
    vbl=Screen('Flip',stimwin);
    resp=[];
    for f=1:stim.nFlips.total
        esc=checkEscapeKey;
        if esc
            break;  
        end
        drawStim(stimwin,stim);
        drawFixDot(stimwin,stim.fix);
        stim=stepStim(stim);
        vbl=Screen('Flip',stimwin,vbl+0.75*physScr.frameDurS);
        %resp=getResp(resp,f,physScr);
    end
end




function escapePressed=checkEscapeKey
    escapePressed=false;
    KbName('UnifyKeyNames');
    [keyIsDown,~,keyCode]=KbCheck;
    if keyIsDown
        escapePressed=keyCode(KbName('Escape'));
    end
end


function saveExperiment(data)
    if isempty(data.subjectID)
        data.subjectID='0';
    end
    mkdir data;
    stop=false;
    i=1;
    while ~stop
        filename=fullfile('data',[mfilename '-' data.subjectID '-' num2str(i,'%.3d') '.mat']);
        if exist(filename,'file')
            i=i+1;
        else
            save(filename, 'data')
            disp(['Saved data to ''' fullfile(pwd,filename) ''''])
            stop=true;
        end
    end
end


function endExperiment(E)
    warning on %#ok<WNON>
    ShowCursor;
    Screen('Preference', 'Verbosity', E.physScr.oldVerbosityLevel);
    Screen('LoadNormalizedGammaTable',E.physScr.scrNr,E.physScr.oldGammaTab);
    Screen('CloseAll');
end


