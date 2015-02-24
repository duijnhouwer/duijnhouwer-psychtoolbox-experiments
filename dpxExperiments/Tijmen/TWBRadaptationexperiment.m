 function TWBRadaptationexperiment
% 09-02-15 
% Binocular rivalry experiment with gratings 

clear all; clf;  

E=dpxCoreExperiment;
E.expName='TWBRadaptationexperiment';

Language = input('NL(1)/EN(2):');
if Language ==1
E.txtStart=sprintf('Druk op $STARTKEY en laat deze los \n om het experiment te starten.\n\n Druk eenmalig op de \n linker- en rechter controltoets.\n Interrupties: druk voor elke interruptie. \n  Continu: druk bij elke nieuwe waarneming.');
E.txtEnd= 'Einde van het experiment';
end

if Language ==2
E.txtStart = sprintf('Press and release $STARTKEY \n to start the experiment.\n\n Press left and right\n control key once to respond.\n Interruption: press before each interruption. \n Continuous: press for every new percept.');
E.txtEnd= 'End of the experiment';
end

E.breakFixTimeOutSec=0;
E.outputFolder='C:\dpxData';

set=0;                                                                      % screen settings for philips screen
if set ==0
E.scr.set('winRectPx',[],'widHeiMm',[390 295],'distMm',1000, ...
        'interEyeMm',65,'gamma',1,'backRGBA',[.5 .5 .5 1], ...
        'stereoMode','mirror','skipSyncTests',0,'scrNr',0); 
else 
E.scr.set('winRectPx',[1440 0 1600+1440 1200],'widHeiMm',[390 295], ...     % screen settings for eyelink
        'distMm',1000, 'interEyeMm',65,'gamma',1,'backRGBA',[.5 .5 .5 1], ...
        'stereoMode','mirror','skipSyncTests',0,'scrNr',1);
end

trialLength=60; 
% generate ToffTimes with a shuffled order
Toff = [0.25,0.5,1]; 
shuffle = [randperm(3); Toff]; 
Toff = sortrows(shuffle',1); 
Toff = Toff(:,2);
k = 0; 

for Ton=[8, 1];   
    k=k+1;
    C=dpxCoreCondition;    
    D=dpxCoreCondition; 
    C.durSec = Ton;
     
        R=dpxRespKeyboard;
        R.name='keyboard1';
        R.kbNames= 'space' ;
        R.allowAfterSec=0;
        R.correctEndsTrialAfterSec=0;
        D.addResp(R);
     
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presntation at the left side of the screen
                 
        LeftCheck=dpxStimCheckerboard;
        LeftCheck.name='checksLeft';
        LeftCheck.RGBAfrac=[.5 .5 .5 1];
        LeftCheck.xDeg=0;
        LeftCheck.wDeg=5.6;
        LeftCheck.hDeg=5.6;
        LeftCheck.contrast=.8;
        LeftCheck.nHoleHori=8;
        LeftCheck.nHoleVert=8;
        LeftCheck.sparseness=0;
        LeftCheck.durSec = Ton; 
        C.addStim(LeftCheck);
        
        ML = dpxStimMask;
        ML.name='maskLeft';
        ML.xDeg=0;
        ML.hDeg = 3.2; 
        ML.wDeg = 3.2;
        ML.innerDiamDeg=0;
        ML.outerDiamDeg=2.2;
        ML.RGBAfrac=[.5 .5 .5 1];
        ML.durSec=Ton; 
        C.addStim(ML);
    
        GL = dpxStimGrating;
        GL.name = 'gratingLeft';
        GL.xDeg=0;
        GL.dirDeg=-45;
        GL.squareWave=false;
        GL.cyclesPerSecond=0;
        GL.cyclesPerDeg=6./2.2;
        GL.wDeg=2.2;
        GL.hDeg=2.2;    
        GL.durSec=Ton; 
        C.addStim(GL);
          
        Dot = dpxStimDot;
        Dot.name = 'Dot';
        Dot.xDeg=0; 
        Dot.wDeg=0;
        Dot.hDeg=0;
        C.addStim(Dot);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presentation at the right side of the screen
        
        RightCheck=dpxStimCheckerboard;
        RightCheck.name='checksRight';
        RightCheck.RGBAfrac=[.5 .5 .5 1];
        RightCheck.xDeg=0;
        RightCheck.wDeg=5.6;
        RightCheck.hDeg=5.6;
        RightCheck.contrast=.8;
        RightCheck.nHoleHori=8;
        RightCheck.nHoleVert=8;
        RightCheck.sparseness=0;
        %RightCheck.rndSeed=LeftCheck.rndSeed;
        C.addStim(RightCheck);
        
        MR = dpxStimMask;
        MR.name='maskRight';
        MR.xDeg=0;
        MR.hDeg = 3.2; 
        MR.wDeg = 3.2;
        MR.innerDiamDeg=0;
        MR.outerDiamDeg=2.2;
        MR.RGBAfrac=[.5 .5 .5 1];
        MR.durSec=Ton; 
        C.addStim(MR);

        GR = dpxStimGrating;
        GR.name = 'gratingRight';
        GR.xDeg=0;
        GR.dirDeg=45;
        GR.squareWave=false;
        GR.cyclesPerSecond=0;
        GR.cyclesPerDeg=6./2.2;
        GR.wDeg=2.2;
        GR.hDeg=2.2;      
        GR.durSec=Ton;
        C.addStim(GR);
        
        if Ton==8
        R=dpxRespKeyboard;
        R.name='keyboard1';
        R.kbNames='LeftControl,RightControl';
        R.allowAfterSec=0;
        R.correctEndsTrialAfterSec=Ton;
        C.addResp(R);
        end  
           
        E.addCondition(D);
        E.addCondition(C);        
end
        A = dpxCoreCondition; 
        A.durSec = Inf;
        PA = dpxStimPause;
        PA.name = 'PA2'; 
        PA.durSec=Inf;
        PA.onSec = 0; 

        if  Language==1  
            PA.textPause1 = 'Intermezzo';  
            PA.textPause2 = 'Druk op spatiebar om door te gaan';
        else
            PA.textPause1 = 'Intermission'; 
            PA.textPause2 = 'Press spacebar to continue';
        end
        
        A.addStim(PA); 

        R=dpxRespKeyboard;
        R.name='keyboard2';
        R.kbNames= 'space' ;
        R.allowAfterSec=0;
        R.correctEndsTrialAfterSec=0;
        A.addResp(R);
        
        E.addCondition(A); 
        
for i = 1:length(Toff)
    
    if i<3
        cont = 30; 
        adap= 30;  
    else 
        cont = []; 
        adap = [];                                                          % scraps the two (unnecessary) adaptation trials at the end 
    end
    
    rep = trialLength./(1+Toff(i));                                         % length of interleaved percept choice sequences = 60 seconds (1 min)  
    if mod(rep,1) ~0
        error('The trial length should be divisble by 30'); 
    end
    
    j = 0; 
    for Ton = [trialLength, cont, adap];
        j = j+1;
        C = dpxCoreCondition; 
        B = dpxCoreCondition;
        
        if Ton==60
        offTime = Toff(i); 
        else 
        offTime = 0;
        end
        
        C.durSec = Ton;
        
        PA = dpxStimPause;
        PA.name = 'PA3'; 
        PA.durSec=5; 
        PA.onSec = 0; 
        
        if  Language==1
            if j==1
            PA.textPause1 = 'Conditie: Interrupties (1 min)';
            PA.textPause2 = 'Kijk en gebruik beide controltoetsen'; 
            elseif j==2
            PA.textPause1 = 'Conditie: Continu (30 sec)';
            PA.textPause2 = 'Kijk en gebruik beide controltoetsen';
            else 
         	PA.textPause1 = 'Conditie: Continu (30 sec)';  
            PA.textPause2 = 'Alleen kijken';
            end
        else   
        if j==1
            PA.textPause1 = 'Condition: Interruptions (1 min)';
            PA.textPause2 = 'View and use both control keys'; 
            elseif j==2
            PA.textPause1 = 'Condition: Continuous (30 sec)';    
            PA.textPause2 = 'View and use both control keys'; 
            else 
            PA.textPause1 = 'Condition: Continuous (30 sec)';    
            PA.textPause2 = 'View only'; 
        end
       
        end
        B.addStim(PA);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presentation at the left side of the screen     
        
       
        LeftCheck=dpxStimCheckerboard;
        LeftCheck.name='checksLeft';
        LeftCheck.RGBAfrac=[.5 .5 .5 1];
        LeftCheck.xDeg=0;
        LeftCheck.wDeg=5.6;
        LeftCheck.hDeg=5.6;
        LeftCheck.contrast=.9;
        LeftCheck.nHoleHori=8;
        LeftCheck.nHoleVert=8;
        LeftCheck.sparseness=0;
        LeftCheck.durSec = Inf; 
        LeftCheck.onSec = 0; 
        C.addStim(LeftCheck);
        
        for nRepeats=1:rep
        ML = dpxStimMask;
        ML.name = sprintf('MaskLeft%d', nRepeats);
        ML.xDeg=0;
        ML.hDeg = 3.2; 
        ML.wDeg = 3.2;
        ML.innerDiamDeg=0;
        ML.outerDiamDeg=2.2;
        ML.RGBAfrac=[.5 .5 .5 1];
        ML.durSec = 1;
        ML.onSec =(offTime + 1)*(nRepeats-1) ;
        C.addStim(ML);
             
        GL = dpxStimGrating;
        GL.name = sprintf('GratingLeft%d', nRepeats);
        GL.xDeg=0;
        GL.dirDeg=-45;
        GL.squareWave=false;
        GL.cyclesPerSecond=0;
        GL.cyclesPerDeg=6./2.2;
        GL.wDeg=2.2;
        GL.hDeg=2.2;    
        GL.durSec = 1; 
        GL.onSec = (offTime + 1)*(nRepeats-1) ;
        C.addStim(GL);
        end
        
        Dot = dpxStimDot;
        Dot.name = 'Dot';
        Dot.xDeg=0; 
        Dot.wDeg=0;
        Dot.hDeg=0;
        C.addStim(Dot);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presentation at the right side of the screen
        
        RightCheck=dpxStimCheckerboard;
        RightCheck.name='checksRight';
        RightCheck.RGBAfrac=[.5 .5 .5 1];
        RightCheck.xDeg=0;
        RightCheck.wDeg=5.6;
        RightCheck.hDeg=5.6;
        RightCheck.contrast=.9;
        RightCheck.nHoleHori=8;
        RightCheck.nHoleVert=8;
        RightCheck.sparseness=0;
        RightCheck.rndSeed=LeftCheck.rndSeed;
        RightCheck.durSec = Inf; 
        RightCheck.onSec = 0; 
        C.addStim(RightCheck);
        
        for nRepeats =1:rep
        MR = dpxStimMask;
        MR.name = sprintf('MaskRight%d', nRepeats);
        MR.xDeg = 0;
        MR.hDeg = 3.2; 
        MR.wDeg = 3.2;
        MR.innerDiamDeg=0;
        MR.outerDiamDeg=2.2;
        MR.RGBAfrac=[.5 .5 .5 1];
        MR.durSec = 1; 
        MR.onSec = (offTime + 1)*(nRepeats-1) ;
        C.addStim(MR);

        GR = dpxStimGrating;
        GR.name = sprintf('GratingRight%d', nRepeats);
        GR.xDeg=0;
        GR.dirDeg=45;
        GR.squareWave=false;
        GR.cyclesPerSecond=0;
        GR.cyclesPerDeg=6./2.2;
        GR.wDeg=2.2;
        GR.hDeg=2.2;      
        GR.durSec = 1;
        GR.onSec = (offTime + 1)*(nRepeats-1) ;
        C.addStim(GR);
        end
        
        if j < 3
        R=dpxRespKeyboard;
        R.name='keyboard3';
        R.kbNames='LeftControl,RightControl';
        R.allowAfterSec=0;
        R.correctEndsTrialAfterSec=Ton;
        C.addResp(R);
        end
        
      E.addCondition(B);   
      E.addCondition(C); 
    end
    
        PA = dpxStimPause;
        PA.name = 'PA4'; 
        PA.durSec=Inf; 
        PA.onSec = 0; 
        if  Language==1
        PA.textPause1=sprintf('Uitgevoerd: %d/3', i);
        PA.textPause2='Druk op spatiebar om door te gaan'; 
        else
        PA.textPause1=sprintf('Completed part: %d/3', i);
        PA.textPause2='Press and release spacekey to continue';
        end
        D.addStim(PA);
      
        R=dpxRespKeyboard;
        R.name='keyboard4';
        R.kbNames= 'space' ;
        R.allowAfterSec=0;
        R.correctEndsTrialAfterSec=0;
        D.addResp(R);
        
        E.addCondition(D);
end 
    E.conditionSequence = 1:numel(E.conditions);
    E.nRepeats=1; 
    E.run;
    sca; 
end