function mmapAPIGeneralCall
    % any preprocessing to be done on inputs should be done here.
    % ===================
    
    % load analyzer file
    global Analyzer exptDetail %#ok<NUSED>
    load(['Z:\2P\Analyzer\' exptDetail.animal '\' exptDetail.animal '_u' exptDetail.unit '_' exptDetail.expt '.analyzer']);
    % ===================
    
    % save data?
    % save(['C:\2pdata\' exptDetail.animal '\' exptDetail.animal '_' exptDetail.unit '_' exptDetail.expt '_pixTc.mat'],'pixelTc','-v7.3')
    % ===================
    
    % launch the desired gui
    avgPixGui;
    % ===================
end