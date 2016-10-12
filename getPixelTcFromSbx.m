function success  = getPixelTcFromSbx(maxBaselineFrames,maxPostFrames)
    global pixelTc imagingDetail exptDetail

    if ~exist('maxBaselineFrames','var');   maxBaselineFrames = 10; end
    if ~exist('maxPostFrames','var');       maxPostFrames = 20;     end
    
    sbxPath = ['C:\2pdata\' exptDetail.animal '\' exptDetail.animal '_' exptDetail.unit '_' exptDetail.expt ];
    analyzerPath = ['Z:\2P\Analyzer\' exptDetail.animal '\' exptDetail.animal '_u' exptDetail.unit '_' exptDetail.expt '.analyzer'];
    
    if ~exist([sbxPath '.mat'],'file')
        success = false;
        return;
    end
    load(sbxPath); % load info file
    
    % load align file
    alignStruct = [];
    if exist([sbxPath '.align'],'file'); 
        alignStruct = load([sbxPath '.align'],'-mat');
    end
    
    sampleFrame = sbxread(sbxPath,0,1);
    imagingDetail.lines = info.config.lines; % ideally one should get these from sbx
    imagingDetail.pixels = size(sampleFrame,size(size(sampleFrame),2)); 
    imagingDetail.resfreq = info.resfreq;
    imagingDetail.imageSize = [imagingDetail.lines imagingDetail.pixels];
    imagingDetail.tPerFrame = imagingDetail.lines/imagingDetail.resfreq;
    imagingDetail.maxBaselineFrames = maxBaselineFrames;
    imagingDetail.maxPostFrames = maxPostFrames;
    imagingDetail.projectedStimFrames = 20;

    clearvars sampleFrame;
    
    load(analyzerPath,'-mat');
    load([sbxPath '.mat']);

    trialDetail = getTrialDetail(Analyzer);

    pixelTc = cell(1,trialDetail.nTrial);
    
    stimOnOffIdx = find(info.event_id == 2);
    stimOnIdx = stimOnOffIdx(1:2:end);
    stimOffIdx = stimOnOffIdx(2:2:end);
    
    success = true;
    if length(stimOnIdx) == length(trialDetail.trials)
        hWaitbar = waitbar(0,'1','Name','Extracting pixel data from sbx file. This may take a while...',...
                'CreateCancelBtn',...
                'setappdata(gcbf,''canceling'',1)');
        setappdata(hWaitbar,'canceling',0);
        for t=1:length(stimOnIdx)
            if getappdata(hWaitbar,'canceling'); success = false; break; end
            waitbar(t/length(stimOnIdx),hWaitbar,['Trial number ' num2str(t)]);
            stimOnFrame = info.frame(stimOnIdx(t));
            stimOffFrame = info.frame(stimOffIdx(t));
            baselineFrameStart = stimOnFrame-imagingDetail.maxBaselineFrames;
            
            epochs = [1 imagingDetail.maxBaselineFrames...
                imagingDetail.maxBaselineFrames+(stimOffFrame-stimOnFrame)...
                imagingDetail.maxBaselineFrames+(stimOffFrame-stimOnFrame)+imagingDetail.maxPostFrames];
            
            % baseline
            framesRead = sbxread(sbxPath,baselineFrameStart,imagingDetail.maxBaselineFrames);
            framesRead = double(squeeze(framesRead(1,:,:,:)));
            if ~isempty(alignStruct); framesRead = alignFrames(framesRead,alignStruct.T(baselineFrameStart:baselineFrameStart+imagingDetail.maxBaselineFrames-1,:)); end
            pixelTc{t}(:,:,epochs(1):epochs(2)) = framesRead;
            
            % stim
            framesRead = sbxread(sbxPath,stimOnFrame,stimOffFrame-stimOnFrame);
            framesRead = double(squeeze(framesRead(1,:,:,:)));
            if ~isempty(alignStruct); framesRead = alignFrames(framesRead,alignStruct.T(stimOnFrame:stimOffFrame-1,:)); end
            pixelTc{t}(:,:,epochs(2)+1:epochs(3)) = framesRead;
            
            % post
            framesRead = sbxread(sbxPath,stimOffFrame,imagingDetail.maxPostFrames);
            framesRead = double(squeeze(framesRead(1,:,:,:)));
            if ~isempty(alignStruct); framesRead = alignFrames(framesRead,alignStruct.T(stimOffFrame:stimOffFrame+imagingDetail.maxPostFrames-1,:)); end
            pixelTc{t}(:,:,epochs(3)+1:epochs(4)) = framesRead;     
        end
        delete(hWaitbar);
    else
        disp('Something went wrong. TTL pulses don''t match up with nTrials.')
        success = false;
    end
end

function alignedFrames = alignFrames(inputFrames,shift)
    alignedFrames = nan(size(inputFrames));
    for frameCount=1:size(inputFrames,3)
        alignedFrames(:,:,frameCount) = circshift(squeeze(inputFrames(:,:,frameCount)),shift(frameCount,:));
    end
end