function timeWindows = getTimeWindows(imagingDetail,respFrames)
% because we don't know for how many frames teh stim was on, the format of
% time windows is a bit idiosyncratic
% baselineFrames = number of frames in 0 -> stim on
% postFrames = number of frames after stim off
% respFrames = number of frames after stim goes on -> number of frames
%               after stim goes off
% respRange = time window of respFrames

    if ~exist('respFrames','var'); respFrames = [1 8]; end

    timeWindows.baselineFrames = imagingDetail.maxBaselineFrames;
    timeWindows.baselineRange = ...
        [-imagingDetail.tPerFrame * imagingDetail.maxBaselineFrames*1000 0];
    
    timeWindows.postFrames = imagingDetail.maxPostFrames;
    timeWindows.postRange = ...
        [0 imagingDetail.tPerFrame * imagingDetail.maxPostFrames*1000];
    
    timeWindows.respFrames = respFrames;
    timeWindows.respRange = 1000*imagingDetail.tPerFrame*timeWindows.respFrames;
end