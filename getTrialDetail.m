function trialDetail = getTrialDetail(Analyzer)
    trialDetail.trials = getcondtrial(Analyzer);
    [trialDetail.domains,trialDetail.domval,trialDetail.blankid] = getdomainvalue(Analyzer);
    trialDetail.nTrial = getnotrials(Analyzer);
    trialDetail.nRepeat = getnorepeats(1,Analyzer);
    
    if ~isempty(trialDetail.blankid)
        trialDetail.nRepeatBlank=getnorepeats(trialDetail.blankid,Analyzer);
    else
        trialDetail.nRepeatBlank = NaN;
    end
    trialDetail.isMultipleDomain = length(trialDetail.domains) > 1;
end

