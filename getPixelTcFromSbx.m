
function getPixelTcFromSbx
    global pixelTc imagingDetail exptDetail

    sbxPath = ['C:\2pdata\' exptDetail.animal '\' exptDetail.animal '_' exptDetail.unit '_' exptDetail.expt ];
    analyzerPath = ['Z:\2P\Analyzer\' exptDetail.animal '\' exptDetail.animal '_u' exptDetail.unit '_' exptDetail.expt '.analyzer'];

    imagingDetail.lines = 512; % ideally one should get these from sbx
    imagingDetail.pixels = 796;
    imagingDetail.resfreq = 7930;
    imagingDetail.imageSize = [imagingDetail.lines imagingDetail.pixels];
    imagingDetail.tPerFrame = imagingDetail.lines/imagingDetail.resfreq;
    imagingDetail.maxBaselineFrames = 15;
    imagingDetail.maxPostFrames = 5;
    imagingDetail.projectedStimFrames = 20;

    load(analyzerPath,'-mat');
    load([sbxPath '.mat']);

    trialDetail = getTrialDetail(Analyzer);

    pixelTc = cell(1,trialDetail.nTrial);
    
    stimOnOffIdx = find(info.event_id == 2);
    stimOnIdx = stimOnOffIdx(1:2:end);
    stimOffIdx = stimOnOffIdx(2:2:end);
    
    if length(stimOnIdx) == length(trialDetail.trials)
        for t=1:length(stimOnIdx)
            disp(['Trial ' num2str(t)]);
            stimOnFrame = info.frame(stimOnIdx(t));
            stimOffFrame = info.frame(stimOffIdx(t));
            baselineFrameStart = stimOnFrame-imagingDetail.maxBaselineFrames;
            
            epochs = [1 imagingDetail.maxBaselineFrames...
                imagingDetail.maxBaselineFrames+(stimOffFrame-stimOnFrame)...
                imagingDetail.maxBaselineFrames+(stimOffFrame-stimOnFrame)+imagingDetail.maxPostFrames];
            
            framesRead = sbxread(sbxPath,baselineFrameStart,imagingDetail.maxBaselineFrames);
            pixelTc{t}(:,:,epochs(1):epochs(2)) = double(squeeze(framesRead(1,:,:,:)));
            framesRead = sbxread(sbxPath,stimOnFrame,stimOffFrame-stimOnFrame);
            pixelTc{t}(:,:,epochs(2)+1:epochs(3)) = double(squeeze(framesRead(1,:,:,:)));
            framesRead = sbxread(sbxPath,stimOffFrame,imagingDetail.maxPostFrames);
            pixelTc{t}(:,:,epochs(3)+1:epochs(4)) = double(squeeze(framesRead(1,:,:,:)));
                
        end
    else
        disp('Something went wrong. TTL pulses don''t match up with nTrials.')
    end
end