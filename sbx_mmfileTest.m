function sbx_mmfileTest()
    udpserver_open;
end

function startAcqMemMap()
    global imagingDetail pixelTc exptAborted

    mmfilepath = 'C:\Users\nielsenlab\Documents\MATLAB\Scanbox_Yeti-master\mmap';
    mmfilename = 'scanbox.mmap';
    % specifying the path is unnecessary
    mmfile = memmapfile([mmfilepath '\' mmfilename],'Writable',true, ...
        'Format', { 'int16' [1 16] 'header' } , 'Repeat', 1);
    firstFrameEverFlag = 1;

    pixelTc = {};
    trialCount = 0;
    trialFrameCount = 0;
    
    imagingDetail.lines = 512; % ideally one should get these from sbx
    imagingDetail.pixels = 796;
    imagingDetail.resfreq = 7930;
    imagingDetail.imageSize = [imagingDetail.lines imagingDetail.pixels];
    imagingDetail.tPerFrame = imagingDetail.lines/imagingDetail.resfreq;
    
    baselineFrameCount = 0;
    imagingDetail.maxBaselineFrames = 10;
    baselineFrames = nan(imagingDetail.imageSize(1),imagingDetail.imageSize(2),imagingDetail.maxBaselineFrames);

    postFrameCount = 0;
    imagingDetail.maxPostFrames = 10;

    imagingDetail.projectedStimFrames = 20;
    maxTotalFramesPerTrial = imagingDetail.maxBaselineFrames + imagingDetail.projectedStimFrames + imagingDetail.maxPostFrames;
    
    ttlState_n = false;
    exptRunning = true;
    exptAborted = false;

    % Process all incoming frames until Scanbox stops
    while(exptRunning)
        % disp('DEBUG: Inside whiletrue');
        while(mmfile.Data.header(1)<0) % wait for a new frame...
            if(mmfile.Data.header(1) == -2) % exit if Scanbox stopped
                disp('Experiment stopping...');
                exptRunning = false;
                break;
            end
        end

        % disp(['DEBUG: Frame ' num2str(mmfile.Data.header(1))]);

        if(firstFrameEverFlag)
            % disp(['DEBUG: Wild first frame appears.']);
            mmfile.Format = {'int16' [1 16] 'header' ; ...
            'uint16' double([mmfile.Data.header(2) mmfile.Data.header(3)]) 'chA'};
            firstFrameEverFlag = 0;
        end

        % update ttl state and history
        % disp(['DEBUG: TTL state = ' num2str(mmfile.Data.header(4))]);
        ttlState_nMinus1 = ttlState_n;
        ttlState_n = mmfile.Data.header(4) == 2;

        % handle all four ttl state conditions: 0->0, 0->1, 1->0, 1->1
        if ~ttlState_n && ~ttlState_nMinus1
            % disp('0 -> 0');
            if baselineFrameCount < imagingDetail.maxBaselineFrames
                % disp('DEBUG: Adding baseline frame.');
                baselineFrameCount = baselineFrameCount + 1;
                baselineFrames(:,:,baselineFrameCount) = mmfile.Data.chA;
            else
                % disp('DEBUG: Replacing baseline frame.');
                baselineFrameCount = imagingDetail.maxBaselineFrames;
                baselineFrames(:,:,1:(imagingDetail.maxBaselineFrames-1)) = baselineFrames(:,:,2:imagingDetail.maxBaselineFrames);
                baselineFrames(:,:,imagingDetail.maxBaselineFrames) = mmfile.Data.chA;
            end
            if postFrameCount <= imagingDetail.maxPostFrames && trialCount > 0
                % disp('DEBUG: Adding post frame.');
                postFrameCount = postFrameCount + 1;
                trialFrameCount = trialFrameCount + 1;
                pixelTc{trialCount}(:,:,trialFrameCount) = double(mmfile.Data.chA); %#ok<*AGROW>
            end

            % disp(['DEBUG: Baseline frames collected = ' num2str(baselineFrameCount)]);
        elseif ttlState_n && ~ttlState_nMinus1
            trialCount = trialCount + 1;
            disp(['0 -> 1 (trial ' num2str(trialCount) ' started)']);
            trialFrameCount = baselineFrameCount + 1;
            pixelTc{trialCount} = zeros(mmfile.Data.header(2),mmfile.Data.header(3),maxTotalFramesPerTrial);
            pixelTc{trialCount}(:,:,1:baselineFrameCount) = baselineFrames;
            baselineFrames = zeros(mmfile.Data.header(2),mmfile.Data.header(3),imagingDetail.maxBaselineFrames);
            pixelTc{trialCount}(:,:,trialFrameCount) = double(mmfile.Data.chA);
            % disp(['DEBUG: Frames collected for this trial (including baseline frames) = ' num2str(trialFrameCount)]);
        elseif ~ttlState_n && ttlState_nMinus1
            disp(['1 -> 0 (trial ' num2str(trialCount) ' ended)']);
            % disp('DEBUG: Adding post frame.');
            baselineFrameCount = 0;
            postFrameCount = 1;
            trialFrameCount = trialFrameCount + 1;
            pixelTc{trialCount}(:,:,trialFrameCount) = double(mmfile.Data.chA); %#ok<*AGROW>
        else
            % disp('1 -> 1 (ongoing trial)');
            trialFrameCount = trialFrameCount + 1;
            pixelTc{trialCount}(:,:,trialFrameCount) = double(mmfile.Data.chA);
            % disp(['DEBUG: Frames collected for this trial (including baseline frames) = ' num2str(trialFrameCount)]);
        end

        mmfile.Data.header(1) = -1;
    end

    if exptAborted
        disp('Experiment interrupted by user. Clearing memory and closing memory mapping server.'); %#ok<UNRCH>
        pixelTc = {};
    else
        disp('Experiment ended. Saving file and closing memory mapping server.');
        mmapAPIGeneralCall;
    end

    clear('mmfile');
    udpserver_close;
end

function udpserver_open
    global udp_server;

    if(~isempty(udp_server))
        udpserver_close;
    end
    udp_server=udp('localhost', 'LocalPort', 8000,'BytesAvailableFcn',@udpserver_cb);

    fopen(udp_server);
end

function udpserver_close

    global udp_server;

    try
        fclose(udp_server);
        delete(udp_server);
    catch
        udp_server = [];
    end
end

function udpserver_cb(a,~)
    global exptDetail exptAborted
    s = fgetl(a);

    switch(s(1))
        case 'A'
            exptDetail.animal = s(2:end);
        case 'E'
            exptDetail.expt = s(2:end);
        case 'U'
            exptDetail.unit = s(2:end);
        case 'G'
            save('currentExpt.mat','exptDetail');
            disp(['Experiment starting. ' exptDetail.animal '_' exptDetail.unit '_' exptDetail.expt]);
            startAcqMemMap;
        case 'S'
            exptAborted = true;
    end
end
