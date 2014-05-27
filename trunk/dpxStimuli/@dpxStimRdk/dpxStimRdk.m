classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) ...
        dpxStimRdk < dpxBasicStim
    
    properties (Access=public)
        dirDeg=180;
        speedDps=10;
        dotsPerSqrDeg=10;
        dotDiamDeg=.1;
        dotRBGAfrac1=[0 0 0 1];
        dotRBGAfrac2=[1 1 1 1];
        nSteps=2;
        cohereFrac=1; % negative coherence flips directions
        wDeg=10;
        hDeg=10;
        apert='circle';
    end
    properties (Access=private)
        nDots;
        dotXPx;
        dotYPx;
        xCenterPx;
        yCenterPx;
        wPx;
        hPx;
        onFlip;
        offFlip;
        flipCounter=0;
        dotdirdeg=[];
        dotsize;
        dotage;
        pxpflip; % the speed in pixels per flip
        dotcols;
        noiseDot;
    end
    methods (Access=public)
        function S=dpxStimRdk
        end
        function init(S,physScr)
            if nargin~=2 || ~isobject(physScr) || ~strcmp(physScr.type,'dpxStimWindow')
                error('Needs dpxStimWindow object');
            end
            if isempty(physScr.windowPtr)
                error('dpxStimWindow object has not been initialized');
            end
            S.type='dpxStimRdk';
            D2P=physScr.deg2px; % degrees to pixels
            F2I=physScr.whiteIdx; % fraction to index (for colors)
            % Convert settings to stimulus properties
            S.nDots=max(0,round(S.dotsPerSqrDeg * S.wDeg * S.hDeg));
            N=S.nDots;
            S.wPx = S.wDeg * D2P;
            S.hPx = S.hDeg * D2P;
            S.xCenterPx = physScr.widPx/2 + S.xDeg*D2P;
            S.yCenterPx = physScr.heiPx/2 + S.yDeg*D2P;
            S.dotXPx = rand(1,N) * S.wPx-S.wPx/2;
            S.dotYPx = rand(1,N) * S.hPx-S.hPx/2;
            S.dotdirdeg = ones(1,N) * S.dirDeg;
            nNoiseDots = max(0,min(N,round(N * (1-abs(S.cohereFrac)))));
            S.noiseDot = Shuffle([true(1,nNoiseDots) false(1,N-nNoiseDots)]);
            noiseDirs = rand(1,N) * 360;
            S.dotdirdeg(S.noiseDot) = noiseDirs(S.noiseDot);
            if S.cohereFrac<0, S.dotdirdeg = S.dotdirdeg + 180; end % negative coherence flips directions
            S.dotsize = max(1,repmat(S.dotDiamDeg*D2P,1,N));
            S.dotage = floor(rand(1,N) * (S.nSteps + 1));
            S.pxpflip = S.speedDps * D2P / physScr.measuredFrameRate;
            idx = rand(1,N)<.5;
            S.dotcols(:,idx) = repmat(S.dotRBGAfrac1(:)*F2I,1,sum(idx));
            S.dotcols(:,~idx) = repmat(S.dotRBGAfrac2(:)*F2I,1,sum(~idx));
            S.onFlip = S.onSecs * physScr.measuredFrameRate;
            S.offFlip = (S.onSecs + S.durSecs) * physScr.measuredFrameRate;
            S.flipCounter=0;
        end
        function draw(S,windowPtr)
            S.flipCounter=S.flipCounter+1;
            if S.flipCounter<S.onFlip || S.flipCounter>=S.offFlip
                return;
            else
                ok=applyTheAperture(S);
                if ~any(ok), return; end
                xy=[S.dotXPx(:) S.dotYPx(:)]';
                Screen('DrawDots',windowPtr,xy(:,ok),S.dotsize(ok),S.dotcols(:,ok),[S.xCenterPx S.yCenterPx],2);
            end
        end
        function step(S)
            % Reposition the dots, use shorthands for clarity
            x=S.dotXPx;
            y=S.dotYPx;
            w=S.wPx;
            h=S.hPx;
            dx=cosd(S.dotdirdeg)*S.pxpflip;
            dy=sind(S.dotdirdeg)*S.pxpflip;
            % Update dot lifetime
            S.dotage=S.dotage+1;
            expired=S.dotage>S.nSteps;
            % give new position if expired
            x(expired)=rand(1,sum(expired))*w-w/2-dx(expired);
            y(expired)=rand(1,sum(expired))*h-h/2-dy(expired);
            % give new random direction if expired and dot is noise
            rndDirs=rand(size(x))*360;
            S.dotdirdeg(expired&S.noiseDot)=rndDirs(expired&S.noiseDot);
            S.dotage(expired)=0;
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
            S.dotXPx=x;
            S.dotYPx=y;
        end
    end
end

% ---

function ok=applyTheAperture(S)
    if strcmpi(S.apert,'CIRCLE')
        r=min(S.wPx,S.hPx)/2;
        ok=hypot(S.dotXPx,S.dotYPx)<r;
    elseif strcmpi(S.apert,'RECT')
        % no need to do anything
    else
        error(['Unknown apert option: ' S.apert ]);
    end
end
