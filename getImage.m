function [dispImage,primCondVal] = getImage(pixelTuning,trialDetail,plotDetail)
    primCond = plotDetail.param1name;
    primCondIdx = find(~cellfun(@isempty,(strfind(trialDetail.domains,primCond))));
    primCondVal = unique(trialDetail.domval(:,primCondIdx));
    
    domval = trialDetail.domval;
    if plotDetail.param1_modulo
        primCondVal = unique(mod(primCondVal,plotDetail.param1_moduloVal));
        domval(:,primCondIdx) = mod(domval(:,primCondIdx),plotDetail.param1_moduloVal);
    end
    
    dispImage = zeros(size(pixelTuning,1),size(pixelTuning,2),length(primCondVal));

    for v=1:length(primCondVal)
        if ~trialDetail.isMultipleDomain
            dispImage(:,:,v) = mean(pixelTuning(:,:,domval(:,primCondIdx) == primCondVal(v)),3);
        elseif strcmp(plotDetail.param2mode,'mean')
            dispImage(:,:,v) = mean(pixelTuning(:,:,domval(:,primCondIdx) == primCondVal(v)),3);
        elseif strcmp(plotDetail.param2mode,'all')
            dispImage(:,:,v) = max(pixelTuning(:,:,domval(:,primCondIdx) == primCondVal(v)),[],3);
        else
            secCondIdx = 3 - primCondIdx;
            tempConds = domval(:,primCondIdx) == primCondVal(v) & domval(:,secCondIdx) == plotDetail.param2val;
            dispImage(:,:,v) = mean(pixelTuning(:,:,tempConds),3);
        end    
    end
end

