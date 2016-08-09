function [pixelTuning,trialResp] = getPixelTuning(trialDetail,timeWindows,frameSize)
    global pixelTc isDffCalculated
    
    trialResp = zeros(frameSize(1),frameSize(2),trialDetail.nTrial);
    pixelTuning = zeros(frameSize(1),frameSize(2),size(trialDetail.domval,1)+1);
    
    disp('Getting pixel tuning. This may take a while...');
    tic;
    for t=1:trialDetail.nTrial
        disp(['Trial ' num2str(t)]);
        if ~isDffCalculated
            % calculate mean of baseline frames
            f0 = mean(pixelTc{t}(:,:,1:timeWindows.baselineFrames),3);
            f0 = repmat(f0,[1,1,size(pixelTc{t},3)]);

            % convert pixelTc to df/f
            pixelTc{t} = (pixelTc{t} - f0)./f0;
        end
        
        trialResp(:,:,t) = mean(pixelTc{t}(:,:,timeWindows.baselineFrames + timeWindows.respFrames(1) : ...
            size(pixelTc{t},3) - timeWindows.postFrames + timeWindows.respFrames(2)),3);
    end
    toc
    
    isDffCalculated = true;
    
    for d=1:size(trialDetail.domval,1)+1
        pixelTuning(:,:,d) = mean(squeeze(trialResp(:,:,trialDetail.trials == d)),3);
    end
end