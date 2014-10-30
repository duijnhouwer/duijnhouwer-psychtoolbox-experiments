function agDpxDDQbiasTactile
    
    % agDpxDDQbiasTactile
    
    E=dpxCoreExperiment;
    E.expName='agDpxDDQbiasTactile';
    E.outputFolder='/Users/iMac_2Photon/Dropbox/dpxData';    E.scr.set('winRectPx',[],'widHeiMm',[400 300],'distMm',600,'interEyeMm',65,'gamma',1,'backRGBA',[0.5 0.5 0.5 1],'stereoMode','mono','skipSyncTests',1); % Generated using dpxToolStimWindowGui on 2014-09-22
    %
    javaaddpath(which('BrainMidi.jar'));
    
    
    durS=2 ;
    flashSec=.5; %the alternative is 1 sec
    ddqWid=4;
    dotSize=1;
    for ddqRightFromFix=[0]
        for ddqHei=ddqWid * [1.1496]%it is the point of subjective equality
            for ori=0
                for bottomLeftTopRightFirst=[true]
                    for antiJump=false
                        for i=1:4
                            if ddqHei==ddqWid && antiJump
                                continue;
                            end
                            %
                            
                            C=dpxCoreCondition;
                            C.durSec=3600;
                            %
                            F=dpxStimDot;
                            % type get(F) to see a list of parameters you can set
                            set(F,'xDeg',0); % set the fix dot 10 deg to the left
                            set(F,'name','fix','wDeg',0.5);
                            C.addStim(F);
                            %
                            DDQ=dpxStimDynDotQrt;
                            set(DDQ,'name','ddqRight','wDeg',ddqWid,'hDeg',ddqHei,'flashSec',flashSec);
                            set(DDQ,'oriDeg',ori,'onSec',0.5,'durSec',durS,'antiJump',antiJump);
                            set(DDQ,'bottomLeftTopRightFirst',bottomLeftTopRightFirst);
                            set(DDQ,'xDeg',get(F,'xDeg')+ddqRightFromFix);
                            if i==1
                                set(DDQ,'diamsDeg',[dotSize dotSize 0 0]); % diamsDeg is diameter of disks in degrees
                            elseif i==2
                                set(DDQ,'diamsDeg',[0 dotSize dotSize 0]); % diamsDeg is diameter of disks in degrees
                                
                            elseif i==3
                                set(DDQ,'diamsDeg',[ 0 0  dotSize dotSize]); % diamsDeg is diameter of disks in degrees
                                
                            elseif i==4
                                set(DDQ,'diamsDeg',[dotSize 0 0 dotSize]); % diamsDeg is diameter of disks in degrees
                            else
                                error('i>4???');
                            end
                            C.addStim(DDQ);
                            
                            R=dpxRespKeyboard;
                            R.name='keyboard';
                            R.kbNames='LeftArrow,DownArrow';
                            R.allowAfterSec=DDQ.onSec+DDQ.durSec; % allow the response no sooner than the end of the DDQ stim
                            R.correctEndsTrialAfterSec=0;
                            C.addResp(R);
                            %
                            FB=dpxStimDot;
                            set(FB,'xDeg',F.xDeg,'yDeg',F.yDeg);
                            set(FB,'name','respfeedback','wDeg',1,'visible',0);
                            C.addStim(FB);
                            %
                            T=dpxStimTactileMIDI;
                            T.onSec=DDQ.onSec;
                            T.durSec=Inf;
                            T.tapOnSec=kron(flashSec:flashSec:durS,[1 1])-flashSec;
                            T.tapDurSec=2/60;
                            T.tapNote=[0 1 8 9];
                            C.addStim(T);
                            %
                            E.addCondition(C);
                        end
                    end
                end
            end
        end
    end
    E.nRepeats=5;
    nTrials=numel(E.conditions)*E.nRepeats;
    expectedSecs=nTrials*(durS);
    dpxDispFancy(['This experiment is expected to take about ' dpxSeconds2readable(expectedSecs) '.']);
    E.run;
end
