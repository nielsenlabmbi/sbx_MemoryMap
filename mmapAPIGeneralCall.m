function mmapAPIGeneralCall
    % wait to get data: sbx is slow
    pause(5);

    % loading fake data
    global pixelTc imagingDetail exptDetail
    if isempty(pixelTc)
        getPixelTcFromSbx
    end
    % ==================
    
    % any preprocessing to be done on inputs should be done here.
    % need to check for empty frames.
    global isDffCalculated
    if sum(squeeze(pixelTc{1}(1,1,:) == 0))
        disp('Removing empty frames. This may take a minute...');
        for t=1:length(pixelTc)
            % hack to fisnd empty frames
            ind = squeeze(pixelTc{t}(1,1,:) == 0);
            pixelTc{t} = pixelTc{t}(:,:,~ind);
        end
    end
    isDffCalculated = false;
    
    % ===================
    
    % load analyzer file
    global Analyzer %#ok<NUSED>
    load(['Z:\2P\Analyzer\' exptDetail.animal '\' exptDetail.animal '_u' exptDetail.unit '_' exptDetail.expt '.analyzer'],'-mat');
    % ===================
    
    % save data?
    % save(['C:\2pdata\' exptDetail.animal '\' exptDetail.animal '_' exptDetail.unit '_' exptDetail.expt '_pixTc.mat'],'pixelTc','-v7.3')
    % ===================
    
    % launch the desired gui
    avgPixGui;
    % ===================
end