function anatomy = getAnatomy(skipNtrials)
    global pixelTc;
    
    if ~exist('skipNtrials','var'); skipNtrials = 5; end
    
    anatomy = zeros(size(pixelTc{1},1),size(pixelTc{1},2),length(1:skipNtrials:length(pixelTc)));
    for ii=1:skipNtrials:length(pixelTc)
        anatomy(:,:,ii) = mean(pixelTc{ii},3);
    end
    anatomy = mean(anatomy,3);
    anatomy = imadjust(anatomy);
end

