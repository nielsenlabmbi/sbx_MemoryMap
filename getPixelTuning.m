function [pixelTuning,trialResp] = getPixelTuning(trialDetail,timeWindows,filterPx,frameSize)
    global pixelTc isDffCalculated
    
    trialResp = zeros(frameSize(1),frameSize(2),trialDetail.nTrial);
    pixelTuning = zeros(frameSize(1),frameSize(2),size(trialDetail.domval,1)+1);
    
    % kernel = ones(2*filterPx + 1) / ((2*filterPx + 1)^2); % boxcar kernel
    kernel = makeGaussianKernel([1 1],[filterPx filterPx],1); % gaussian kernel
    
    hWaitbar = waitbar(0,'1','Name','Getting pixel tuning..');
    for t=1:trialDetail.nTrial
        if ~isDffCalculated
            % calculate mean of baseline frames
            f0 = mean(pixelTc{t}(:,:,1:timeWindows.baselineFrames),3);
            f0 = repmat(f0,[1,1,size(pixelTc{t},3)]);

            % convert pixelTc to df/f
            pixelTc{t} = (pixelTc{t} - f0)./f0;
        end
        waitbar(t/trialDetail.nTrial,hWaitbar,['Trial number ' num2str(t)])
        
        trialResp(:,:,t) = mean(pixelTc{t}(:,:,timeWindows.baselineFrames + timeWindows.respFrames(1) + 1 : ...
            size(pixelTc{t},3) - timeWindows.postFrames + timeWindows.respFrames(2)),3);
        
        trialResp(:,:,t) = smoothImage(trialResp(:,:,t),kernel,filterPx);
    end
    delete(hWaitbar);
    
    isDffCalculated = true;
    for d=1:size(trialDetail.domval,1)+1
        pixelTuning(:,:,d) = mean(squeeze(trialResp(:,:,trialDetail.trials == d)),3);
    end
end

function smoothImgs = smoothImage(imgs,kernel,filterPx)
    smoothImgs = imgs;
    for ii=1:size(imgs,3)
        imgPadded = padarray(imgs(:,:,ii),[filterPx filterPx],'replicate');
        smoothImgs(:,:,ii) = filter2(kernel,imgPadded,'valid');
        % smoothImg = (smoothImg - min(smoothImg(:))) / (max(smoothImg(:)) - min(smoothImg(:)));
        % smoothImg = round(min(imgs(:)) + ((max(imgs(:))-1) * smoothImg));
    end
end

function gaussKernel = makeGaussianKernel(binWidths,sigma,nSigma)
    nDims = length(binWidths);
    
    kernelWidthInBins = round((nSigma.*sigma)./binWidths);

    inp = cell(1,nDims);
    for ii=1:nDims
        inp{ii} = binWidths(ii).*(-kernelWidthInBins(ii):1:kernelWidthInBins(ii));
    end

    outGrid = cell(1,nDims);
    [outGrid{:}] = ndgrid(inp{:});

    gaussKernel = ones(size(outGrid{1}));
    for ii=1:nDims
       gaussKernel =  gaussKernel.*exp(-1.*(outGrid{ii}.*outGrid{ii})./(2*sigma(ii)*sigma(ii)));
    end

    gaussKernel = gaussKernel./sum(gaussKernel(:));
end