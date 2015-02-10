classdef lkDpxGratingExpAnalysis < hgsetget
    properties (Access=public)
        % name of todoListFile, 
        % organized.
        todoListFileName;
        anaFunc;
        anaOpts;
        pause;
    end
    properties (GetAccess=private,SetAccess=private)
        % The file and corresponding neuron todo lists can be viewed by the
        % user, but can not be set directly, only through loading a
        % todoListFile.
        filesToDo;
        neuronsToDo;
    end
    methods (Access=public)
        function A=lkDpxGratingExpAnalysis(neurotodoFile)
            % lkDpxGratingExpAnalysis
            % Analysis class for lkDpxGratingExp
            %
            % PROPERTIES:
            % todoListFileName = the absolute path to a NeuroTodoFile.
            %    A NeuroTodoFile is a text-file that ends in
            %    "todo.txt" that should contain the filenames including
            %    absolute paths to the the merged LasAF and DPX datafiles
            %    as created using lkDpxGratingExpAddResponse. I've included
            %    an example todoListFile called 'example_todo.txt' that
            %    contains more comments that explain in more detail how the
            %    items in that file should be.
            % anaFunc = name of analysis. All analysis are programmed to
            %    run on a cell to cell basis. This class is basically a
            %    wrapper to call them on the set of cells selected in the
            %    NeuroTodoFile. The analysis function can be found in the
            %    private folder within the "@lkDpxGratingExpAnalysis" class
            %    folder. They come in two separate functions, for an anaFunc
            %    named XXX these would be calcXXX.m and plotXXX.m (the names
            %    should be self-explanatory). It's always a good idea to keep
            %    the calculations of your analysis and the visualization of
            %    your data as separate as possible. At the time of writing
            %    (2014-12-1) there's only one anaFunc
            %    "DirectionTuningCurve". We will make more as needed.
            % anaOpts = cell array of options that are passed to
            %    calcXXX.m if XXX is your anaFunc
            %    "calcDirectionTuningCurve" doesnt do anything with those
            %    (at the moment).
            % pause = when to plot and wait for key to continue. Can be
            %    either 'perCell', 'perFile', or 'never'. If 'never', no plots
            %    are shown.
            %
            % METHODS:
            % Once you have set the properties to your liking, run the
            % analysis by excecuting
            %    A.run
            % Tip: you can like always in matlab interupt the analysis
            %    by typing CTRL-C, followed optionally by cf to close the
            %    figures
            %
            % OUTPUT:
            % A dpxd struct with N being the number of cells. The format of
            % this struct will depend on the calcXXX.m function that was
            % used, but N will always be the number of cells analysed. So
            % for "DirectionTuningCurve" this will contain, among other
            % things, a DirectionTuningCurve for each cell.
            %
            
            if nargin==0
                neurotodoFile='';
            end
            A.pause='perFile'; % 'perCell', 'perFile', 'never'
            A.todoListFileName=neurotodoFile; % note: this calls the function "set.todoListFileName"
            A.anaFunc='DirectionTuningCurve';
            A.anaOpts={};
        end
        function output=run(A)
            if isempty(A.todoListFileName)
                dpxDispFancy('The string "todoListFileName" is empty, no data files to run analyses on.');
                return;
            elseif numel(A.filesToDo)==0
                dpxDispFancy('A todo-list was loaded, but appears to contain no data files to run analyses on.');
                return
            end
            for f=1:numel(A.filesToDo)
                dpxd=dpxdLoad(A.filesToDo{f}); % dpxd is now an DPX-Data structure
                nList=parseNeuronsToDoList(A.neuronsToDo{f},getNeuronNrs(dpxd));
                calcCommandString=['calc' A.anaFunc]; % e.g. 'calcDirectionTuningCurve'
                plotCommandString=['plot' A.anaFunc]; % e.g. 'plotDirectionTuningCurve'
                tel=0;
                for c=1:numel(nList)
                    tel=tel+1;
                    output{tel}=eval([calcCommandString '(dpxd,nList(c),A.anaOpts{:});']); %#ok<AGROW>
                    % add filename and cell numer
                    output{tel}.file{1}=A.filesToDo{f}; %#ok<AGROW>
                    output{tel}.cellNumber=nList(c); %#ok<AGROW> 
                    if ~strcmpi(A.pause,'never')
                        figHandle=dpxFindFig([A.filesToDo{f} ' c' num2str(nList(c),'%.3d')]);
                        eval([plotCommandString '(output{tel});']);
                    end
                    if strcmpi(A.pause,'perCell')
                        dpxTileFigs;
                        [~,filestem]=fileparts(A.filesToDo{f});
                        input(['Showing ' plotCommandString ' of cell ' num2str(nList(c)) ' (' num2str(c) '/' num2str(numel(nList)) ') in file ''' filestem ''' (' num2str(f) '/' num2str(numel(A.filesToDo)) '). <<Any key to continue>>']);
                        close(figHandle);
                    end
                end
                if strcmpi(A.pause,'perFile')
                    dpxTileFigs;
                    [~,filestem]=fileparts(A.filesToDo{f});
                    input(['Showing ' plotCommandString ' of all cells in file ''' filestem ''' (' num2str(f) '/' num2str(numel(A.filesToDo)) '). <<Any key to continue>>']);
                    close all;
                end
                % Merge all the outputs into a single DPXD
                output=dpxdMerge(output);
            end
        end         
    end
    methods % set and get functions
        function set.todoListFileName(A,value)
            if isempty(value)
                [filename,pathname]=uigetfile({'*todo.txt'},'Select a NeuroTodoFile ...');
                if ~ischar(filename) && filename==0
                    dpxDispFancy('User canceled selecting todo-list file.');
                    A.todoListFileName='';
                    return;
                end
                value=fullfile(pathname,filename);
            end
            if ~exist(value,'file')
                error(['No such file: ''' value '''']);
            end
            A.todoListFileName=value;
            [A.filesToDo,A.neuronsToDo]=loadTodoList(A.todoListFileName); %#ok<MCSUP>
        end
        function set.pause(A,value)
            try
                options={'perCell','perFile','never'};
                if ~any(strcmpi(value,options))
                   error; % skip to catch block
                end
                A.pause=value;
            catch me
                error(['pause should be one of: ' dpxCellOptionsToStr(options) '.']);
            end
        end
    end
end
