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
        elseif strcmp(plotDetail.param2mode,'value')
            secCondIdx = 3 - primCondIdx;
            tempConds = domval(:,primCondIdx) == primCondVal(v) & domval(:,secCondIdx) == plotDetail.param2val;
            dispImage(:,:,v) = mean(pixelTuning(:,:,tempConds),3);
        elseif strcmp(plotDetail.param2mode,'value_slide')
            secCondIdx = 3 - primCondIdx;
            tempConds = getNnearestNeighbours(domval,primCondIdx,secCondIdx,primCondVal(v),plotDetail.param2val,plotDetail.param2collapse);
%             tempConds = domval(:,primCondIdx) == primCondVal(v) & domval(:,secCondIdx) == plotDetail.param2val;
            dispImage(:,:,v) = mean(pixelTuning(:,:,tempConds),3);
        end    
    end
end

function finalConds = getNnearestNeighbours(domval,primCondIdx,secCondIdx,primCondVal,param2val,param2collapse)
    totalConds = length(unique(domval(:,secCondIdx)));
    tempConds = padarray([ones(1,param2collapse) zeros(1,totalConds-param2collapse)],[0 ceil(param2collapse/2)]);
    tempConds = circshift(circshift(tempConds,[0 param2val]),[0 -ceil(param2collapse/2)]);
    tempConds = tempConds(ceil(param2collapse/2)+1 : end - ceil(param2collapse/2));
    if sum(tempConds) < param2collapse 
        if tempConds(1)
            tempConds = [ones(1,param2collapse) zeros(1,totalConds-param2collapse)];
        else
            tempConds = [zeros(1,totalConds-param2collapse) ones(1,param2collapse)];
        end
    end
    
    tempConds = find(tempConds);
    finalConds = zeros(size(domval,1),1);
    for ii=1:length(tempConds)
        finalConds = finalConds + (domval(:,primCondIdx) == primCondVal & domval(:,secCondIdx) == tempConds(ii));
    end
    finalConds = find(finalConds);
end