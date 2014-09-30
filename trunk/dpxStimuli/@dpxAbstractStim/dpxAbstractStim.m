classdef (Abstract) dpxAbstractStim < hgsetget
    
    properties (Access=public)
        visible=true;
        onSec=0;
        durSec=Inf;
        xDeg=0;
        yDeg=0;
        zDeg=0;
        wDeg=1;
        hDeg=1;
        name=''; % defaults to class when added to condition
    end
    properties (SetAccess=public,GetAccess=protected)
        initialPublicState=[];
    end
    properties (Access=protected)
        onFlip;
        offFlip;
        xPx;
        yPx;
        zPx;
        wPx;
        hPx;
        winCntrXYpx=[];
        scrGets=[];
        flipCounter=0;
    end
    methods (Access=public)
        function S=dpxAbstractStim
            % dpxAbstractStim - Abstract class for dpxStim classes.
            %
            % Abstract means no objects can be created from this class, it
            % only serves to be inherited. The names of all derived classes
            % should be of the format dpxStimXXX where XXX is a placeholder
            % for the name of your stimulus.
            %
            % See also: dpxBasicResp, dpxStimRdk
            %
            % Jacob Duijnhouwer, 2014-09-05
        end
        function lockInitialPublicState(S)
            % addStim of the condition class will call this function to
            % store a copy of all publicly settable parameters of this
            % stimulus in initialPublicState. Before a repeat of the
            % condition is presented, this struct is used to restore this
            % stimulus to it's starting state. So when, for example, the
            % property 'visible' was toggled during a condition-presenation
            % (trial), is will be reset prior to the next trial of this
            % condition.
            if ~isempty(S.initialPublicState)
                error('lockInitialPublicState should be called only once on a stimulus, during addStim');
            end
            S.initialPublicState=dpxGetSetables(S);
        end
        function restoreInitialPublicState(S)
            if isempty(S.initialPublicState)
                error('lockInitialPublicState should have been called during addStim');
            end
            fns=fieldnames(S.initialPublicState);
            for i=1:numel(fns)
                S.(fns{i})=S.initialPublicState.(fns{i});
            end
        end
        function init(S,scrGets)
            if nargin~=2 || ~isstruct(scrGets)
                error('Needs get(dpxCoreWindow-object) struct');
            end
            if isempty(scrGets.windowPtr)
                error('dpxCoreWindow object has not been initialized');
            end
            S.restoreInitialPublicState; % keep at top of init
            S.flipCounter=0;
            S.onFlip = S.onSec * scrGets.measuredFrameRate;
            S.offFlip = (S.onSec + S.durSec) * scrGets.measuredFrameRate;
            S.winCntrXYpx = [scrGets.widPx/2 scrGets.heiPx/2];
            S.xPx = S.xDeg * scrGets.deg2px;
            S.yPx = S.yDeg * scrGets.deg2px;
            S.wPx = S.wDeg * scrGets.deg2px;
            S.hPx = S.hDeg * scrGets.deg2px;
            S.scrGets=scrGets;
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