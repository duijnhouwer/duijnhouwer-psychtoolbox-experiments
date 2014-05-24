function u=jdPTBmergeStructs(s,str)
    % U=jdPTBmergeStructs(S,[STR])
    % Merge the structures in cell-array of structures S,
    % Either all structures need to have with unique fieldnames, or make them
    % unique in one of three ways:
    %   1 provide unique labels in cell-array of strings STR. If the last
    %     character of a labels is a blank (' '), the first letter of the
    %     fieldname will be capitalized.
    %   2 STR 'auto' [default] numbered labels are generated if any fields in S are
    %     in conflict
    %   3 STR 'force' generates numbered labels
    %
    % Jacob, 2014-05-24
    %
    % EXAMPLE:
    %   monkey=struct('furry',true,'animal',true);
    %   banana=struct('fruit',true,'color','yellow','curvature',2.72)
    %   jdPTBmergeStructs({monkey banana})
    %   jdPTBmergeStructs({monkey banana},{'monkey ','food '})
    
    if nargin==1 || ischar(str) && strcmpi(str,'auto');
        str='auto';
        useLabels=checkFieldnameConflict(s);
        if useLabels
            labels=generateNumberedLabels(numel(s));
        end
    elseif ischar(str) && strmcpi(str,'force')
        useLabels=true;
        labels=generateNumberedLabels(numel(s));
    elseif iscell(str)
        useLabels=true;
        labels=str;
        str='providedlist';
        if numel(labels)~=numel(s) || numel(labels)~=numel(unique(labels)) || any(~cellfun(@ischar,labels))
            error('When naming structs, EACH structs needs a UNIQUE label of type CHAR (CASE-INSENSITIVE');
        end
    else
        error('Incorrect value for argument STR');
    end
    u=struct;
    for i=1:numel(s)
        fns=fieldnames(s{i});
        for f=1:numel(fns)
            if useLabels
                if labels{i}(end)~=' '
                    newfieldStr=[labels{i} fns{f}];
                else
                    newfieldStr=[labels{i}(1:end-1) upper(fns{f}(1)) fns{f}(2:end) ];
                end 
            else
                newfieldStr=fns{f};
            end
            u.(newfieldStr)=s{i}.(fns{f});
        end
    end
end


function [b,nUniqueFields,nFields]=checkFieldnameConflict(s)
    % Case insensitive check, so .FieldA and .fieldA would be in conflict.
    % Purpose of case-insensitivity is so that we can safely change the
    % case of the first letter of the field to upper. 
    fns={};
    nFields=0;
    for i=1:numel(s)
        newFns=fieldnames(s{i});
        nFields=nFields+numel(newFns);
        fns=[fns(:); newFns(:)]; %#ok<AGROW>
    end
    nUniqueFields=numel(unique(upper(fns)));
    b=nUniqueFields~=nFields;
end

function labels=generateNumberedLabels(n)
    labels=cell(n,1);
    maxNrDecimals=floor(log10(n))+1;
    for i=1:n
        formatStr=['%.' num2str(maxNrDecimals) 'd'];
        labels{i}=['struct' num2str(i,formatStr) '_'];
    end
end



