function plotTuning_mask(maskPixelList,trialResp,plotDetail,trialDetail,imagingDetail,timeWindows,axis_tc,axis_tuning)
    [X,Y] = ind2sub(imagingDetail.imageSize,maskPixelList);
    currPixelResp = squeeze(mean(mean((trialResp(X,Y,:)),1),2));
    currPixelTc = getMaskTc(maskPixelList,imagingDetail.imageSize);
    
    primCond = plotDetail.param1name;
    primCondIdx = find(~cellfun(@isempty,(strfind(trialDetail.domains,primCond))));
    primCondVal = unique(trialDetail.domval(:,primCondIdx));
    
    domval = trialDetail.domval;
    if plotDetail.param1_modulo
        primCondVal = unique(mod(primCondVal,plotDetail.param1_moduloVal));
        domval(:,primCondIdx) = mod(domval(:,primCondIdx),plotDetail.param1_moduloVal);
    end
    
    pickTrials = {};
    for v=1:length(primCondVal)
        pickTrials{v} = [];
        if ~trialDetail.isMultipleDomain
            domValIdx = find(domval(:,primCondIdx) == primCondVal(v));
            for dvi=1:length(domValIdx)
                pickTrials{v} = [pickTrials{v};find(trialDetail.trials == domValIdx(dvi))];
            end
        elseif strcmp(plotDetail.param2mode,'mean')
            domValIdx = find(domval(:,primCondIdx) == primCondVal(v));
            for dvi=1:length(domValIdx)
                pickTrials{v} = [pickTrials{v};find(trialDetail.trials == domValIdx(dvi))];
            end
        elseif strcmp(plotDetail.param2mode,'all')
            domValIdx = find(domval(:,primCondIdx) == primCondVal(v));
            for dvi=1:length(domValIdx)
                pickTrials{v} = [pickTrials{v};find(trialDetail.trials == domValIdx(dvi))];
            end
        else
            secCondIdx = 3 - primCondIdx;
            domValIdx = find(domval(:,primCondIdx) == primCondVal(v) & domval(:,secCondIdx) == plotDetail.param2val);
            for dvi=1:length(domValIdx)
                pickTrials{v} = [pickTrials{v};find(trialDetail.trials == domValIdx(dvi))]; % (:,primCondIdx)
            end
        end    
    end    
    
    for v=1:length(primCondVal)
        m(v) = mean(currPixelResp(pickTrials{v}));
        s(v) = std(currPixelResp(pickTrials{v}))/sqrt(length(pickTrials{v}));
    end
    
    [~,ind_bestCond] = max(m); % best condition
    [~,ind_wrstCond] = min(m); % worst condition
    
    cla(axis_tuning);
    hold(axis_tuning,'on');
    if plotDetail.param1_circular
        primCondVal = [primCondVal;2*primCondVal(end)-primCondVal(end-1)];
        m(end+1) = m(1);
        s(end+1) = s(1);
    end
    errorbar(axis_tuning,primCondVal,m,s,'ko-','linewidth',2);
    h = plot(axis_tuning,primCondVal,m,'ko-','linewidth',2);
    
    set(h,'MarkerFaceColor',[0.94 0.94 0.94]);
    set(axis_tuning,'xlim',[min(primCondVal) max(primCondVal)],...
                    'xtick',primCondVal,...
                    'linewidth',2,...
                    'tickdir','out',...
                    'color',[0.94 0.94 0.94]);
	
	box(axis_tuning,'off');
    xlabel(axis_tuning,primCond,'interpreter','none');
    
    cla(axis_tc);
    hold(axis_tc,'on');
    
    bestTc = currPixelTc(pickTrials{ind_bestCond});
    nFrameBest = zeros(1,length(bestTc)); 
    for ii=1:length(bestTc)
        nFrameBest(ii) = length(bestTc{ii});
        t = linspace(0,(imagingDetail.tPerFrame*nFrameBest(ii)),nFrameBest(ii))*1000 + timeWindows.baselineRange(1);
        plot(axis_tc,t,bestTc{ii},'c','linewidth',1);
    end
    
    wrstTc = currPixelTc(pickTrials{ind_wrstCond});
    nFrameWrst = zeros(1,length(wrstTc)); 
    for ii=1:length(wrstTc)
        nFrameWrst(ii) = length(wrstTc{ii});
        t = linspace(0,(imagingDetail.tPerFrame*nFrameWrst(ii)),nFrameWrst(ii))*1000 + timeWindows.baselineRange(1);
        plot(axis_tc,t,wrstTc{ii},'m','linewidth',1);
    end
    maxFrames = max([nFrameBest nFrameWrst]);
    stimOffTime = imagingDetail.tPerFrame*maxFrames*1000 + timeWindows.baselineRange(1) - timeWindows.postRange(2);
    stimOnTime = 0;
    respOnTime = stimOnTime + timeWindows.respRange(1);
    respOffTime = stimOffTime + timeWindows.respRange(2);
    plotYlims = get(axis_tc,'ylim');
    
    if plotYlims(1) > min([cellfun(@min,bestTc) cellfun(@min,wrstTc)])
        plotYlims(1) = min([cellfun(@min,bestTc) cellfun(@min,wrstTc)]);
    end
    
    if plotYlims(2) < max([cellfun(@max,bestTc) cellfun(@max,wrstTc)])
        plotYlims(2) = max([cellfun(@max,bestTc) cellfun(@max,wrstTc)]);
    end
    
    line([stimOnTime stimOnTime],plotYlims,'linewidth',2,'parent',axis_tc)
    line([stimOffTime stimOffTime],plotYlims,'linewidth',2,'parent',axis_tc)
    fill([respOnTime respOnTime respOffTime respOffTime],[plotYlims(1) plotYlims(2) plotYlims(2) plotYlims(1)],[0.7 0.7 0.7],'parent',axis_tc,'facealpha',0.3,'linestyle','none');
    
    set(axis_tc,'xlim',[timeWindows.baselineRange(1) (imagingDetail.tPerFrame*maxFrames)*1000+timeWindows.baselineRange(1)],...
                'tickdir','out',...
                'linewidth',2,...
                'ylim',plotYlims,...
                'color',[0.94 0.94 0.94]);
    
    % scale bar for 10 frames
    plotXlims = get(axis_tc,'xlim');
    line([plotXlims(2)-(sum(plotXlims)/7)-imagingDetail.tPerFrame*10*1000 plotXlims(2)-(sum(plotXlims)/7)],[plotYlims(2)-(sum(plotYlims)/7) plotYlims(2)-(sum(plotYlims)/7)],'linewidth',5,'parent',axis_tc);
    
    xlabel(axis_tc,'Time (ms)','interpreter','none');
    ylabel(axis_tc,'\DeltaF/F_o','interpreter','tex');
    
	hold(axis_tc,'off')
end

function tc1 = getMaskTc(maskPixelList,imageSize)
    global pixelTc;
    
	[X,Y] = ind2sub(imageSize,maskPixelList);
    for p=1:length(X)
        tc(:,p) = cellfun(@(x)squeeze(x(X(p),Y(p),:)),pixelTc,'uniformoutput',false);
    end
    
    for c=1:size(tc,1)
        tc1{c} = mean(cell2mat(tc(c,:)),2);
    end
end