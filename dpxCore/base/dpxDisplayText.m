function escPressed=dpxDisplayText(windowPtr,text,varargin)
    try
        p = inputParser;   % Create an instance of the inputParser class.
        p.addRequired('windowPtr',@(x)isnumeric(x));
        p.addRequired('instructStr',@(x)ischar(x));
        p.addParamValue('rgba',[1 1 1 1],@(x)isnumeric(x) && numel(x)==4 && all(x<=1) && all(x>=0));
        p.addParamValue('rgbaback',[0 0 0 1],@(x)isnumeric(x) && numel(x)==4 && all(x<=1) && all(x>=0));
        p.addParamValue('fadeInSec',0.25,@isnumeric);
        p.addParamValue('fadeOutSec',.5,@isnumeric);
        p.addParamValue('fontname','DefaultFontName',@(x)ischar(x));
        p.addParamValue('fontsize',18,@(x)isnumeric(x));
        p.addParamValue('dxdy',[0 0],@(x)isnumeric(x) && numel(x)==2);
        p.addParamValue('forceContinueAfterSec',Inf,@isnumeric);
        p.parse(windowPtr,text,varargin{:});
        %
        oldFontName=Screen('Textfont',windowPtr,p.Results.fontname);
        oldTextSize=Screen('TextSize',windowPtr,p.Results.fontsize);
        [sourceFactorOld, destinationFactorOld]=Screen('BlendFunction',windowPtr,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');
        startSec=GetSecs;
        % Fade-in the instructions
        fadeText(windowPtr,p.Results,'fadein');
        % wait for input ...
        KbName('UnifyKeyNames');
        keyIsDown=false;
        while ~keyIsDown
            if GetSecs-startSec>p.Results.forceContinueAfterSec
                keyIsDown=true; % emulate button press when time is up
                keyCode=false(1,256);
            else
                [keyIsDown,~,keyCode]=KbCheck;
            end
        end
        escPressed=keyCode(KbName('Escape'));
        if ~escPressed
            % Dont fade out if escape is pressed, hurry up instead
            escPressed=fadeText(windowPtr,p.Results,'fadeout');
            KbReleaseWait; % wait for key to be released
        end
        % Reset the original screen settings
        Screen('BlendFunction',windowPtr,sourceFactorOld,destinationFactorOld);
        Screen('Textfont',windowPtr,oldFontName);
        Screen('TextSize',windowPtr,oldTextSize);
    catch me
        error(me.message);
    end
end

function escPressed=fadeText(windowPtr,p,how)
    try
        escPressed=false;
        if ~any(strcmpi(how,{'fadein','fadeout'}))
            error(['Unknown fade option: ' how]);
        end
        framedur=Screen('GetFlipInterval',windowPtr);
        if strcmpi(how,'fadeout')
            nFlips=floor(p.fadeOutSec/framedur)+1;
        else
            nFlips=floor(p.fadeInSec/framedur)+1;
        end
        for f=1:nFlips
            opacity=(f-1)/(nFlips-1);
            if strcmpi(how,'fadeout')
                opacity=1-opacity;
            end
            printText(p.instructStr,windowPtr,p.rgba,p.rgbaback,opacity,p.dxdy);
            if dpxGetEscapeKey
                escPressed=true;
                break;
            end
        end
    catch me
        error(me.message);
    end
end



function printText(instructStr,windowPtr,RGBAfore,RGBAback,opacityFrac,dxdy)
    try
        if nargin<4 || isempty(opacityFrac)
            opacityFrac=1;
        end
        if nargin<5 || isempty(dxdy)
            dxdy=[0 0];
        end
        RGBAfore=RGBAfore*WhiteIndex(windowPtr);
        RGBAback=RGBAback*WhiteIndex(windowPtr);
        RGBAfore(4)=RGBAfore(4)*opacityFrac;
        for eye=[0 1]
            % works also in mono mode
            Screen('SelectStereoDrawBuffer', windowPtr, eye);
            Screen('FillRect',windowPtr,RGBAback);
            [w,h]=Screen('WindowSize',windowPtr);
            dx=dxdy(1);
            dy=dxdy(2);
            winRect=[max(0,dx) max(0,dy) min(w,w-dx) min(h,h-dy)];
            vLineSpacing=1.75;
            DrawFormattedText(windowPtr, instructStr, 'center','center', RGBAfore, [], [], [], vLineSpacing, [], winRect);
        end
        Screen('Flip',windowPtr);
    catch me
        error(me.message);
    end
end