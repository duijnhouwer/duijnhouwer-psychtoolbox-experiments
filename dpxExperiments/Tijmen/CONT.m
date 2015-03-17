function [ condition ] = CONT(Ton )

W =dpxCoreWindow;
E=dpxCoreExperiment;

for cont = Ton   
    C=dpxCoreCondition;    
    C.durSec = Ton;
     
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presentation at the left side of the screen (right side if mirror is active)
                 
        LeftCheck=dpxStimCheckerboard;
        LeftCheck.name='checksLeft';
        LeftCheck.RGBAfrac= [1 1 1 1];
        LeftCheck.contrast=0.25;
        LeftCheck.xDeg=0;
        LeftCheck.wDeg=125/W.deg2px;
        LeftCheck.hDeg=125/W.deg2px;
        LeftCheck.nHoleHori=10;
        LeftCheck.nHoleVert=10;
        LeftCheck.nHori=18;
        LeftCheck.nVert=18;
        LeftCheck.sparseness=2/3;
        LeftCheck.durSec = cont; 
        C.addStim(LeftCheck);
        
        ML = dpxStimMask;
        ML.grayFrac=.5;
        ML.name='MaskLeft';
        ML.typeStr='gaussian';
        ML.xDeg=0;
        ML.hDeg = (50*sqrt(2))/W.deg2px; 
        ML.wDeg = (50*sqrt(2))/W.deg2px;
        ML.durSec = cont; 
        C.addStim(ML);
    
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
        GL.durSec = cont; 
        C.addStim(GL);
          
        Dot = dpxStimDot;
        Dot.name = 'Dot';
        Dot.xDeg=0; 
        Dot.wDeg=0;
        Dot.hDeg=0;
        C.addStim(Dot);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % STIMULUS presentation at the right side of the screen (left side if mirror is active)
        
        RightCheck = dpxStimCheckerboard;
        RightCheck.name='checksRight';
        RightCheck.RGBAfrac=[1 1 1 1];
        RightCheck.contrast=0.25;
        RightCheck.xDeg=0;
        RightCheck.wDeg=125/W.deg2px;
        RightCheck.hDeg=125/W.deg2px;
        RightCheck.nHori=18;
        RightCheck.nVert=18;
        RightCheck.nHoleHori=10;
        RightCheck.nHoleVert=10;
        RightCheck.sparseness=2/3;
        RightCheck.rndSeed=LeftCheck.rndSeed;
        C.addStim(RightCheck);
        
        MR = dpxStimMask;
        MR.name='MaskRight';
        MR.grayFrac=.5;
        MR.typeStr='gaussian';
        MR.xDeg=0;
        MR.hDeg = (50*sqrt(2))/W.deg2px;
        MR.wDeg = (50*sqrt(2))/W.deg2px;
        MR.durSec = cont ; 
        C.addStim(MR);

        GR = dpxStimGrating;
        GR.name = 'gratingRight';
        GR.xDeg=0;
        GR.dirDeg=45;
        GR.squareWave=false;
        GR.cyclesPerSecond=0;
        GR.cyclesPerDeg=2.5;
        GR.wDeg= (50)/W.deg2px;
        GR.hDeg= (50)/W.deg2px;      
        GR.durSec = cont;
        C.addStim(GR);

        RL0 = dpxRespContiKeyboard;
        RL0.name='keyboardl';
        RL0.kbName='LeftControl';
        C.addResp(RL0); 
        
        RR0 = dpxRespContiKeyboard;
        RR0.name='keyboardr';
        RR0.kbName='RightControl';
        C.addResp(RR0);
        
        E.addCondition(C);  
end
condition = E.conditions
end

