classdef dpxBasicStim < hgsetget
    
    properties (Access=public)
        visible=true;
        onSec=0;
        durSec=1;
        xDeg=0;
        yDeg=0;
        zDeg=0;
        wDeg=1;
        hDeg=1;
        class='dpxBasicStim';
        name=''; % defaults to class when added to condition
    end
    properties (Access=protected)
        onFlip=0;
        offFlip=0;
        xPx=0;
        yPx=0;
        zPx=0;
        wPx=0;
        hPx=0;
        winCntrXYpx=[];
        physScrVals=struct;
        flipCounter=0;
    end
    methods (Access=public)
        function S=dpxBasicStim
        end
        function init(S,physScrVals)
            if nargin~=2 || ~isstruct(physScrVals)
                error('Needs get(dpxStimWindow-object) struct');
            end
            if isempty(physScrVals.windowPtr)
                error('dpxCoreWindow object has not been initialized');
            end
            S.flipCounter=0;
            S.onFlip = S.onSec * physScrVals.measuredFrameRate;
            S.offFlip = (S.onSec + S.durSec) * physScrVals.measuredFrameRate;
            S.winCntrXYpx = [physScrVals.widPx/2 physScrVals.heiPx/2];
            S.xPx = S.xDeg * physScrVals.deg2px;
            S.yPx = S.yDeg * physScrVals.deg2px;
            S.wPx = S.wDeg * physScrVals.deg2px;
            S.hPx = S.hDeg * physScrVals.deg2px;
            S.physScrVals=physScrVals;
            S.myInit;
        end
        function draw(S)
            S.flipCounter=S.flipCounter+1;
            if ~S.visible || S.flipCounter<S.onFlip || S.flipCounter>=S.offFlip
                return;
            end
            S.myDraw;
        end
        function step(S)
            if S.flipCounter<S.onFlip || S.flipCounter>=S.offFlip
                return;
            end
            S.myStep;
        end
        function clear(S)
            S.myClear;
        end
    end
    methods (Access=protected)
        % overwrite these "my" functions is your stimulus class
        function myInit(S), end     
        function myDraw(S), end
        function myStep(S), end
        function myClear(S), end
    end
    methods
        function set.visible(S,value)
            if ~islogical(value) && ~isnumeric(value)
                error('Enable should be numeric or (preferably) logical');
            end
            S.visible=logical(value);
        end
    end
end