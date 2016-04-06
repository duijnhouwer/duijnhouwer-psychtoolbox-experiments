function rdDpxExpAdaptDepth()
% Displays binoclar rivalry stimulus, and after a set time brings up
% kinetic depth cylinders.

%%%%%%%%%%%%%%%%%%
% STIMULUS INPUT %
%%%%%%%%%%%%%%%%%%
global IN

% adaptation
IN.adapSec     = 10;

% cylinders
IN.cylRepeats  = 20;
IN.cylOnSec    = 1;
IN.cylOffSec   = 1.5;
IN.disparities = [-.4 -.2 0 .2 .4];
IN.cylPosition = 1;
IN.reps        = 20;
IN.rotSpeed    = [120 -120];
IN.modes       = 'stereo';

%%%%%%%%%%%%%%%%%%%%%
%   START STUFF     %
%%%%%%%%%%%%%%%%%%%%%
E=dpxCoreExperiment;
E.paradigm      = mfilename;
E.txtStart      = 'intro';
E.outputFolder  = 'C:\tempdata_PleaseDeleteMeSenpai';
E.window.set('scrNr',0,'rectPx',[1440 0 1600+1440 1200],'stereoMode','mirror'); % 'rectPx',[1440 0 1600+1440 1200]
E.window.set('distMm',1000,'interEyeMm',65,'widHeiMm',[394 295]);
E.window.set('gamma',0.49,'backRGBA',[.5 .5 .5 1],'skipSyncTests',1);

%%%%%%%%%%%%%%%%%%%%%%%%%
%   FIRST ADAPTATION    %
%%%%%%%%%%%%%%%%%%%%%%%%%
adapC=dpxCoreCondition;
adapC = defineAdaptationStimulation(E.window,'adap',adapC);
adapC = defineCylinderStimulinder(false,adapC,0,0);
E.addCondition(adapC);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   AFTER 1800 SEC CYLINDER STIMULUS  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for disp = 1:numel(IN.disparities)
    for speeds = 1:numel(IN.rotSpeed)
    cylC = dpxCoreCondition;
    cylC = defineCylinderStimulinder(true,cylC,IN.disparities(disp),IN.rotSpeed(speeds));
    cylC = defineAdaptationStimulation(E.window,'cyl',cylC);
    E.addCondition(cylC);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%% 
% ALL STIMULI COLLECTED %
%%%%%%%%%%%%%%%%%%%%%%%%%
%        ! RUN !        %
%%%%%%%%%%%%%%%%%%%%%%%%%

cylSequence = repmat(2:numel(IN.disparities)+1,1,IN.cylRepeats);

E.conditionSequence=[1 cylSequence(randperm(numel(cylSequence)))];

E.run;

end

function C = defineAdaptationStimulation(W,state,C)
global IN

if strcmp(state,'adap'); visible = 1; 
C.durSec    = IN.adapSec;
%left stimulus
ML = dpxStimMaskGaussian;
ML.name='MaskLeft';
ML.xDeg=0;
ML.hDeg = 3*sqrt(2); %(50*sqrt(2))/W.deg2px;
ML.wDeg = 3*sqrt(2); %(50*sqrt(2))/W.deg2px;
ML.sigmaDeg = ML.hDeg/8;
ML.durSec=IN.adapSec;
ML.visible=visible;
C.addStimulus(ML);

GL = dpxStimGrating;
GL.name = 'gratingLeft';
GL.xDeg=0;
GL.dirDeg=-45;
GL.contrastFrac=1;
GL.squareWave=false;
GL.cyclesPerSecond=0;
GL.cyclesPerDeg=2.5;
GL.wDeg= 3; %(50)/W.deg2px;
GL.hDeg= 3; %(50)/W.deg2px;
GL.durSec=IN.adapSec;
GL.buffer=0;
GL.visible=visible;
C.addStimulus(GL);

%right stimulus
MR = dpxStimMaskGaussian;
MR.name='MaskRite';
MR.xDeg=0;
MR.hDeg = 3*sqrt(2); % (50*sqrt(2))/W.deg2px;
MR.wDeg = 3*sqrt(2); % (50*sqrt(2))/W.deg2px;
MR.sigmaDeg = MR.hDeg/8;
MR.durSec=IN.adapSec;
MR.visible=visible;
C.addStimulus(MR);

GR = dpxStimGrating;
GR.name = 'gratingRight';
GR.xDeg=0;
GR.dirDeg=45;
GR.squareWave=false;
GR.cyclesPerSecond=0;
GR.cyclesPerDeg=2.5;
GR.wDeg= 3; % (50)/W.deg2px;
GR.hDeg= 3; % (50)/W.deg2px;
GR.durSec=IN.adapSec;
GR.buffer=1;
GR.visible=visible;
C.addStimulus(GR);

elseif strcmp(state,'cyl'); 
C.durSec    = IN.cylOnSec+IN.cylOffSec;
%left stimulus
ML = dpxStimMaskGaussian;
ML.name='MaskLeft';
ML.xDeg=0;
ML.hDeg = (50*sqrt(2))/W.deg2px;
ML.wDeg = (50*sqrt(2))/W.deg2px;
ML.sigmaDeg = ML.hDeg/8;
ML.onSec=IN.cylOnSec;
ML.durSec=IN.cylOffSec;
C.addStimulus(ML);

GL = dpxStimGrating;
GL.name = 'gratingLeft';
GL.xDeg=0;
GL.dirDeg=-45;
GL.contrastFrac=1;
GL.squareWave=false;
GL.cyclesPerSecond=0;
GL.cyclesPerDeg=2.5;
GL.wDeg=(50)/W.deg2px;
GL.hDeg=(50)/W.deg2px;
GL.onSec=IN.cylOnSec;
GL.durSec=IN.cylOffSec;
GL.buffer=0;
C.addStimulus(GL);

%right stimulus
MR = dpxStimMaskGaussian;
MR.name='MaskRite';
MR.xDeg=0;
MR.hDeg = (50*sqrt(2))/W.deg2px;
MR.wDeg = (50*sqrt(2))/W.deg2px;
MR.sigmaDeg = MR.hDeg/8;
MR.onSec=IN.cylOnSec;
MR.durSec=IN.cylOffSec;
C.addStimulus(MR);

GR = dpxStimGrating;
GR.name = 'gratingRight';
GR.xDeg=0;
GR.dirDeg=45;
GR.squareWave=false;
GR.cyclesPerSecond=0;
GR.cyclesPerDeg=2.5;
GR.wDeg= (50)/W.deg2px;
GR.hDeg= (50)/W.deg2px;
GR.onSec=IN.cylOnSec;
GR.durSec=IN.adapSec;
GR.buffer=1;
C.addStimulus(GR);
end
end

function C = defineCylinderStimulinder(state,C,disp,speed)
global IN

if state; visible = 1; C.durSec = IN.cylOnSec+IN.cylOffSec;
elseif ~state; visible = 0; C.durSec    = IN.adapSec;
end

% The fixation cross
S=dpxStimCross;
set(S,'wDeg',.25,'hDeg',.25,'lineWidDeg',.05,'name','fix','visible',visible);
C.addStimulus(S);

% The feedback stimulus for correct responses
S=dpxStimDot;
set(S,'wDeg',.25,'enabled',false,'durSec',.1,'RGBAfrac',[.75 .75 .75 .75],'name','fbCorrect');
C.addStimulus(S);

% The full cylinder stimulus
S=dpxStimRotCylinder;
set(S,'dotsPerSqrDeg',12,'xDeg',IN.cylPosition*1.75,'wDeg',3,'hDeg',3,'dotDiamDeg',0.11 ...
    ,'rotSpeedDeg',speed,'disparityFrac',0,'sideToDraw','both' ...
    ,'onSec',0,'durSec',IN.cylOnSec,'stereoLumCorr',1,'fogFrac',0,'dotDiamScaleFrac',0 ...
    ,'name','fullTargetCyl','visible',visible);
C.addStimulus(S);

% The half cylinder stimulus
% % The half cylinder stimulus
% if strcmpi(IN.modes,'mono')
%     lumcorr=1;
%     dFog=dsp;
%     dScale=IN.disp;
%     dispa=0;
% elseif strcmpi(IN.modes,'stereo')
%     lumcorr=1;
%     dFog=0;
%     dScale=0;
%     dispa=IN.disp;
% elseif strcmpi(IN.modes,'anti-stereo')
%     lumcorr=-1;
%     dFog=0;
%     dScale=0;
%     dispa=IN.disp;
% else
%     error('what you trying fool!?')
% end

S=dpxStimRotCylinder;
set(S,'dotsPerSqrDeg',12,'xDeg',IN.cylPosition*-1.75,'wDeg',3,'hDeg',3,'dotDiamDeg',0.11 ...
    ,'rotSpeedDeg',speed,'disparityFrac',disp,'sideToDraw','front' ...
    ,'onSec',0,'durSec',IN.cylOnSec,'name','halfInducerCyl','visible',visible);
C.addStimulus(S);

% The response object
R=dpxRespKeyboard;
R.name='rightHand';
if state; R.allowAfterSec=S.onSec+S.durSec;
elseif ~state R.allowAfterSec=IN.adapSec; end
R.kbNames='UpArrow,DownArrow';
R.correctStimName='fbCorrect';
R.correctKbNames='1';
R.correctEndsTrialAfterSec=inf;
R.wrongEndsTrialAfterSec=inf;
C.addResponse(R);
end


