function agDpxOnlyTactile

% agDpxOnlytactile

E=dpxCoreExperiment;
E.expName='agDpxOnlyTactile';
% E.outputFolder='C:\dpxData\';
E.scr.set('winRectPx',[],'widHeiMm',[400 300],'distMm',600,'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1],'stereoMode','mono','skipSyncTests',1); % Generated using dpxToolStimWindowGui on 2014-09-22
E.windowed(true); % true, false, [0 0 410 310]+100
%
javaaddpath(which('BrainMidi.jar'));
% We will make 8 conditions...
for i=1:8
    C=dpxCoreCondition;
    % Make a fixation dot that each condition will have
    F=dpxStimDot;
    set(F,'xDeg',0);
    set(F,'name','fix','wDeg',0.5);
    % Make a response object that each condition will have
    R=dpxRespKeyboard;
    R.name='kb';
    R.kbNames='LeftArrow,UpArrow';
    R.allowAfterSec=0;
    R.correctEndsTrialAfterSec=0.1;
    R.correctStimName='respfeedback';
    
    C.durSec=2;
    C.addStim(F);
    C.addResp(R);
    T=dpxStimTactileMIDI;
    T.tapOnSec=[0.5 1 1.5 2];
    if i==1
        T.tapNote=[8 9 8 9];
    elseif i==2
        T.tapNote=[8 9 8 9];
    elseif i==3
        T.tapNote=[8 9 8 9];
    elseif i==4
        T.tapNote=[8 9 8 9];
    elseif i==5
        T.tapOnSec=[0.5 0.5  1 1  1.5 1.5  2 2];
        T.tapNote=[0 8  5 9  0 8  5 9];
    elseif i==6
        T.tapOnSec=[0.5 0.5  1 1  1.5 1.5  2 2];
        T.tapNote=[0 8  5 9  0 8  5 9];
    elseif i==7
        T.tapOnSec=[0.5 0.5  1 1  1.5 1.5  2 2];
        T.tapNote=[0 8  5 9  0 8  5 9];
    elseif i==8
        T.tapOnSec=[0.5 0.5  1 1  1.5 1.5  2 2];
        T.tapNote=[0 8  5 9  0 8  5 9];
    else
        error('Unknown condition number ....');
    end
    T.tapDurSec=T.tapOnSec + 0.020;
    C.addStim(T);
    E.addCondition(C);
    if i==4
        E.addCondition(C);
        E.addCondition(C);
    end
end
E.nRepeats=20;
nTrials=numel(E.conditions)*E.nRepeats;
expectedSecs=nTrials*(2.5);
dpxDispFancy(['This experiment is expected to take about ' dpxSeconds2readable(expectedSecs) '.']);
E.run;
end
