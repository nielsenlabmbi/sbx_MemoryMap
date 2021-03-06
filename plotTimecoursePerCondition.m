function plotTimecoursePerCondition(currentPixel,selectedCondition,plotDetail,trialDetail,imagingDetail,timeWindows,axis_tc)
    % currPixelTc = getPixTc(currentPixel,plotDetail.filterPx+1);
    currPixelTc = getPixTc(currentPixel,3);
    
    primCond = plotDetail.param1name;
    primCondIdx = find(~cellfun(@isempty,(strfind(trialDetail.domains,primCond))));
    
    domval = trialDetail.domval;
    selectedDomval = domval(selectedCondition);
    if plotDetail.param1_modulo
        domval(:,primCondIdx) = mod(domval(:,primCondIdx),plotDetail.param1_moduloVal);
        [~,~,uniqueDomVals] = unique(domval);
        selectedDomval = trialDetail.domval(uniqueDomVals == selectedCondition,primCondIdx);
    end
    
    pickTrials = {};
    for v=1:length(selectedDomval)
        pickTrials{v} = [];
        if ~trialDetail.isMultipleDomain
            domValIdx = find(trialDetail.domval(:,primCondIdx) == selectedDomval(v));
            for dvi=1:length(domValIdx)
                pickTrials{v} = [pickTrials{v};find(trialDetail.trials == domValIdx(dvi))];
            end
        elseif strcmp(plotDetail.param2mode,'mean')
            domValIdx = find(trialDetail.domval(:,primCondIdx) == selectedDomval(v));
            for dvi=1:length(domValIdx)
                pickTrials{v} = [pickTrials{v};find(trialDetail.trials == domValIdx(dvi))];
            end
        elseif strcmp(plotDetail.param2mode,'all')
            domValIdx = find(trialDetail.domval(:,primCondIdx) == selectedDomval(v));
            for dvi=1:length(domValIdx)
                pickTrials{v} = [pickTrials{v};find(trialDetail.trials == domValIdx(dvi))];
            end
        elseif strcmp(plotDetail.param2mode,'value')
            secCondIdx = 3 - primCondIdx;
            domValIdx = find(trialDetail.domval(:,primCondIdx) == selectedDomval(v) & domval(:,secCondIdx) == plotDetail.param2val);
            for dvi=1:length(domValIdx)
                pickTrials{v} = [pickTrials{v};find(trialDetail.trials == domValIdx(dvi))]; % (:,primCondIdx)
            end
        else
            secCondIdx = 3 - primCondIdx;
            domValIdx = getNnearestNeighbours(domval,primCondIdx,secCondIdx,selectedDomval(v),plotDetail.param2val,plotDetail.param2collapse);
            for dvi=1:length(domValIdx)
                pickTrials{v} = [pickTrials{v};find(trialDetail.trials == domValIdx(dvi))]; % (:,primCondIdx)
            end
        end    
    end    
    
    cla(axis_tc);
    hold(axis_tc,'on');
    
    tc = currPixelTc(cell2mat(pickTrials'));
    for ii=1:length(tc)
        t = linspace(0,(imagingDetail.tPerFrame*length(tc{ii})),length(tc{ii}))*1000 + timeWindows.baselineRange(1);
        plot(axis_tc,t,tc{ii},'k','linewidth',1);
    end
    
    plotYlims = get(axis_tc,'ylim');
    
    if plotYlims(1) > min(cellfun(@min,tc))
        plotYlims(1) = min(cellfun(@min,tc));
    end
    
    if plotYlims(2) < max(cellfun(@max,tc))
        plotYlims(2) = max(cellfun(@max,tc));
    end
    
%     set(axis_tc,'ylim',plotYlims);
	hold(axis_tc,'off')
end

function tc1 = getPixTc(mouseLoc,neighbours)
    global pixelTc;
    [X,Y] = meshgrid(mouseLoc(1)-neighbours:mouseLoc(1)+neighbours,...
            mouseLoc(2)-neighbours:mouseLoc(2)+neighbours);
	X = X(:); Y = Y(:);
    for p=1:length(X)
        tc(:,p) = cellfun(@(x)squeeze(x(X(p),Y(p),:)),pixelTc,'uniformoutput',false);
    end
    for c=1:size(tc,1)
        tc1{c} = mean(cell2mat(tc(c,:)),2);
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