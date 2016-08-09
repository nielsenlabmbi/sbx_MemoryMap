function plotTuning(mouseLoc,trialResp,plotDetail,trialDetail,imagingDetail,timeWindows,axis_tc,axis_tuning)
    global pixelTc
    
    currPixelResp = squeeze(trialResp(mouseLoc(1),mouseLoc(2),:));
    currPixelTc = cellfun(@(x)squeeze(x(mouseLoc(1),mouseLoc(2),:)),pixelTc,'uniformoutput',false);
    
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
                pickTrials{v} = [pickTrials{v};find(trialDetail.trials(:,primCondIdx) == domValIdx(dvi))];
            end
        elseif strcmp(plotDetail.param2mode,'mean')
            domValIdx = find(domval(:,primCondIdx) == primCondVal(v));
            for dvi=1:length(domValIdx)
                pickTrials{v} = [pickTrials{v};find(trialDetail.trials(:,primCondIdx) == domValIdx(dvi))];
            end
        elseif strcmp(plotDetail.param2mode,'all')
            domValIdx = find(domval(:,primCondIdx) == primCondVal(v));
            for dvi=1:length(domValIdx)
                pickTrials{v} = [pickTrials{v};find(trialDetail.trials(:,primCondIdx) == domValIdx(dvi))];
            end
        else
            secCondIdx = 3 - primCondIdx;
            domValIdx = find(domval(:,primCondIdx) == primCondVal(v) & domval(:,secCondIdx) == plotDetail.param2val);
            for dvi=1:length(domValIdx)
                pickTrials{v} = [pickTrials{v};find(trialDetail.trials(:,primCondIdx) == domValIdx(dvi))];
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
    plot(axis_tuning,primCondVal,m,'ko-','linewidth',2);
    
    
    set(axis_tuning,'xlim',[min(primCondVal) max(primCondVal)],...
                    'xtick',primCondVal,...
                    'linewidth',2,...
                    'tickdir','out');
	
	box(axis_tuning,'off');
    xlabel(axis_tuning,primCond);
    
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
    set(axis_tc,'xlim',[timeWindows.baselineRange(1) imagingDetail.tPerFrame*maxFrames-timeWindows.baselineRange(1)],...
                'tickdir','out',...
                'linewidth',2);
    xlabel(axis_tc,'Time (ms)');
    ylabel(axis_tc,'df/f');
    
	hold(axis_tc,'off')
end

