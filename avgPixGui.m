function varargout = avgPixGui(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @avgPixGui_OpeningFcn, ...
                       'gui_OutputFcn',  @avgPixGui_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end

function avgPixGui_OpeningFcn(hObject, ~, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to avgPixGui (see VARARGIN)

    global Analyzer exptDetail imagingDetail;

    % Choose default command line output for avgPixGui
    handles.output = hObject;
    
    % preset some important flags
    handles.clickToMagnify = true;
    handles.maskmode = false;
    handles.pixelmode = false;
    handles.plotDetail.showAnatomy = true;
    
    % have the details in handles for easy access
    % note: pixelTc is still global
    handles.analyzer = Analyzer;
    handles.exptDetail = exptDetail;
    handles.imagingDetail = imagingDetail;
    
    % get all details of stimuli and blanks
    if ~isempty(handles.analyzer)
        handles.trialDetail = getTrialDetail(handles.analyzer);
        handles.dataLoaded = true;
    else
        handles.trialDetail = [];
        handles.trialDetail.isMultipleDomain = 0;
        handles.trialDetail.domains{1} = '';
        handles.dataLoaded = false;
    end
    
    % gui changes -> button icons
    % anatomy axis buttons
    pixIcon = imread('avgPixIcon_pix.png'); handles.pixIcon = imresize(pixIcon, [40 40]);
    ctmIcon = imread('avgPixIcon_ctm.png'); handles.ctmIcon = imresize(ctmIcon, [40 40]);
    mmIcon  = imread('avgPixIcon_mm.png');  handles.mmIcon  = imresize(mmIcon, [40 40]);
    
    pixIcon_on = imread('avgPixIcon_pix_on.png'); handles.pixIcon_on = imresize(pixIcon_on, [40 40]);
    ctmIcon_on = imread('avgPixIcon_ctm_on.png'); handles.ctmIcon_on = imresize(ctmIcon_on, [40 40]);
    mmIcon_on  = imread('avgPixIcon_mm_on.png');  handles.mmIcon_on  = imresize(mmIcon_on, [40 40]);
    
    set(handles.tbutton_pixelSelect,'CData',handles.pixIcon);
    set(handles.tbutton_clickToMagnify,'CData',handles.ctmIcon_on);
    set(handles.tbutton_maskmode,'CData',handles.mmIcon);
    
    twIcon  = imread('avgPixIcon_tw.png');  handles.twIcon  = imresize(twIcon, [40 40]);
    set(handles.button_adjustTimeWindows,'CData',handles.twIcon);
    
    % gui changes -> button icons
    % functional axis buttons
    
    
    % gui changes -> masks
    handles.mask.roiCount = 0;
    handles.mask.maskLayerHandle = [];
    if ~isempty(handles.imagingDetail)
        handles.mask.maskImage = zeros(handles.imagingDetail.imageSize);
    else
        handles.mask.maskImage = zeros(512,796); % hack;
    end
    
    handles.clickToMagnifyData = [4,0.08];
    handles.buttonDownOnAxis = false;
    
    handles.plotDetail.filterPx = 10;
    set(handles.slider_filterPx,'value',handles.plotDetail.filterPx);
    
    % gui changes -> analyzer manipulation
    set(handles.pulldown_param1,'String',handles.trialDetail.domains);
    set(handles.pulldown_param1,'Value',1);
    set(handles.textbox_moduloValue,'String','180','Enable','off');
    if strcmp(handles.trialDetail.domains{1},'ori')
        set(handles.checkbox_circular,'Value',1);
        handles.plotDetail.param1_circular = true;
    else
        set(handles.checkbox_circular,'Value',0);
        handles.plotDetail.param1_circular = false;
    end  
    
    handles.plotDetail.param1name = handles.trialDetail.domains{1};
    handles.plotDetail.param1_modulo = false;
    handles.plotDetail.param1_moduloVal = 180;
    
    if handles.trialDetail.isMultipleDomain
        set(handles.pulldown_param2,'String',handles.trialDetail.domains);
        set(handles.pulldown_param2,'Value',2);
        set(handles.pulldown_param2Value,'String',unique(handles.trialDetail.domval(:,2)),'value',1);
        
        set(handles.radiobutton_mean,'Value',1);
        set(handles.radiobutton_all,'Value',0);
        set(handles.radiobutton_value,'Value',0);
        
        handles.plotDetail.param2name = handles.trialDetail.domains{2};
        handles.plotDetail.param2val = handles.trialDetail.domval(1,2);
        handles.plotDetail.param2mode = 'mean';
        
        set(handles.pulldown_param2Value,'enable','off');
    else
        set(handles.pulldown_param2,'enable','off');
        set(handles.pulldown_param2Value,'enable','off');
        set(handles.radiobutton_mean,'enable','off');
        set(handles.radiobutton_all,'enable','off');
        set(handles.radiobutton_value,'enable','off');
        
        handles.plotDetail.param2name = [];
        handles.plotDetail.param2val = [];
        handles.plotDetail.param2mode = [];
    end
    
    % get time windows depending upon how many frames were collected
    if ~isempty(handles.imagingDetail)
        handles.timeWindows = getTimeWindows(handles.imagingDetail);
    else
        handles.timeWindows = [];
        handles.imagingDetail.imageSize = [512 796]; 
        % hack so gui doesn't throw error when loaded without any data
    end
    
    % get tuning for all pixels
    if ~isempty(handles.timeWindows)
        [handles.pixelTuning,handles.trialResp] = getPixelTuning...
            (handles.trialDetail,handles.timeWindows,...
            handles.plotDetail.filterPx,handles.imagingDetail.imageSize);
    else
        handles.pixelTuning = []; handles.trialResp = [];
    end
    
    % get mean image
    if ~isempty(handles.pixelTuning)
        [handles.plotDetail.dispImage,handles.plotDetail.param1val] = getImage(handles.pixelTuning,handles.trialDetail,handles.plotDetail);
        plotImage(handles.plotDetail.dispImage,handles.plotDetail,handles.axis_image);
        handles.plotDetail.anatomy = getAnatomy;
        
        cla(handles.axis_anatomy);
        if handles.plotDetail.showAnatomy        
            imagesc(handles.plotDetail.anatomy,'parent',handles.axis_anatomy);
            colormap(handles.axis_anatomy,'gray')
            hold(handles.axis_anatomy,'on')
        end
    else
        handles.plotDetail.param1val = [];
        handles.plotDetail.anatomy = [];
    end
    
    set(handles.axis_image,'xtick',[],'ytick',[]);
    box(handles.axis_image,'on');
    
    set(handles.axis_anatomy,'xtick',[],'ytick',[]);
    box(handles.axis_anatomy,'on')
    
    if ~handles.dataLoaded
        msgbox('No global data was found. Use the ''Open file...'' button to load data.','No data found','warn');
    end
    
    % Update handles structure
    guidata(hObject, handles);

function varargout = avgPixGui_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;    
    
% =========================================================================
% ========================== TOOLBAR CALLBACKS ============================
% =========================================================================

function uipushtool_open_ClickedCallback(hObject, ~, handles)
    global exptDetail
    load('currentExpt.mat')
    
    % in case of sbx load
    prompt = {'Animal:','Unit:','Experiment:'};
    dlg_title = 'Input';
    num_lines = 1;
    defaultans = {exptDetail.animal,exptDetail.unit,exptDetail.expt};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    if isempty(answer); return; end
    
    exptDetail.animal = answer{1};
    exptDetail.unit = answer{2};
    exptDetail.expt = answer{3};
    
    fileLoc = which('currentExpt.mat');
    save(fileLoc,'exptDetail');
    
    handles = loadDataAndRefreshGui(handles);   
    guidata(hObject, handles);
    
function uipushtool_save_ClickedCallback(~, ~, handles)
    global pixelTc;
    if ~handles.dataLoaded
        msgbox('No data loaded.','Nothing to save','error');
    else
        savePathC = ['C:\2pdata\' handles.exptDetail.animal '\' ...
            handles.exptDetail.animal '_' handles.exptDetail.unit '_' ...
            handles.exptDetail.expt '_pixelData.mat'];
        savePathZ = ['Z:\2P\Ferret 2P\Ferret 2P data\' handles.exptDetail.animal '\' ...
            handles.exptDetail.animal '_' handles.exptDetail.unit '_' ...
            handles.exptDetail.expt '_pixelData.mat'];
        
        choice = questdlg(['Do you want to save pixel timecourse data?'...
            '(Warning: This will take minutes.'...
            'Click ''No'' to only save pixel tuning data.)'], ...
            'Save data', ...
            'Yes','No','No');
        if strcmp(choice,'Yes')
            saveData.pixelTc = pixelTc;
        end
        saveData.pixelTuning = handles.pixelTuning;
        saveData.trialResp = handles.trialResp;
        saveData.analyzer = handles.analyzer;
        saveData.trialDetail = handles.trialDetail;
        saveData.plotDetail = handles.plotDetail;
        saveData.exptDetail = handles.exptDetail;
        saveData.imagingDetail = handles.imagingDetail;
        saveData.mask = handles.mask;
        saveData.timeWindows = handles.timeWindows;
        saveData.clickToMagnifyData = handles.clickToMagnifyData; %#ok<STRNU>
        
        if ~exist(['C:\2pdata\' handles.exptDetail.animal],'dir'); mkdir(['C:\2pdata\' handles.exptDetail.animal]); end
        if ~exist(['Z:\2P\Ferret 2P\Ferret 2P data\' handles.exptDetail.animal],'dir'); mkdir(['Z:\2P\Ferret 2P\Ferret 2P data\' handles.exptDetail.animal]); end
        h = msgbox('Saving data...','Save Data','none');
        save(savePathC,'saveData','-v7.3');
        save(savePathZ,'saveData','-v7.3');
        delete(h);
        msgbox('Data saved.','Save Data','none');
    end

function uitoggletool_zoomIn_ClickedCallback(hObject, ~, handles)
% hObject    handle to uitoggletool_zoomIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function uitoggletool_zoomOut_ClickedCallback(hObject, ~, handles)
% hObject    handle to uitoggletool_zoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% =========================================================================
% ======================= TOOLBAR CALLBACKS DONE ==========================
% =========================================================================

% =========================================================================
% ======================== ANALYZER MANIPULATION ==========================
% =========================================================================

function pulldown_param1_Callback(hObject, ~, handles)
    contents = cellstr(get(hObject,'String'));
    handles.plotDetail.param1name = contents{get(hObject,'Value')};
    guidata(hObject, handles);
    
function pulldown_param2_Callback(hObject, ~, handles)
    contents = cellstr(get(hObject,'String'));
    handles.plotDetail.param2name = contents{get(hObject,'Value')};
    handles.plotDetail.param2val = handles.trialDetail.domval(1,get(hObject,'Value'));
    set(handles.pulldown_param2Value,'String',unique(handles.trialDetail.domval(:,get(hObject,'Value'))),'value',1);
    guidata(hObject, handles);
    
function checkbox_circular_Callback(hObject, ~, handles)
    handles.plotDetail.param1_circular = get(hObject,'Value');
    
    % get mean image
    if ~isempty(handles.pixelTuning)
        [handles.plotDetail.dispImage,handles.plotDetail.param1val] = getImage(handles.pixelTuning,handles.trialDetail,handles.plotDetail);
        plotImage(handles.plotDetail.dispImage,handles.plotDetail,handles.axis_image);
    end
    guidata(hObject, handles);
    
function checkbox_modulo_Callback(hObject, ~, handles)
    handles.plotDetail.param1_modulo = get(hObject,'Value');
    if get(hObject,'Value')
        set(handles.textbox_moduloValue,'enable','on');
    else
        set(handles.textbox_moduloValue,'enable','off');
    end
    
    % get mean image
    if ~isempty(handles.pixelTuning)
        [handles.plotDetail.dispImage,handles.plotDetail.param1val] = getImage(handles.pixelTuning,handles.trialDetail,handles.plotDetail);
        plotImage(handles.plotDetail.dispImage,handles.plotDetail,handles.axis_image);
    end
    guidata(hObject, handles);

function textbox_moduloValue_Callback(hObject, ~, handles)
    handles.plotDetail.param1_moduloVal = str2double(get(hObject,'String'));
    
    % get mean image
    if ~isempty(handles.pixelTuning)
        [handles.plotDetail.dispImage,handles.plotDetail.param1val] = getImage(handles.pixelTuning,handles.trialDetail,handles.plotDetail);
        plotImage(handles.plotDetail.dispImage,handles.plotDetail,handles.axis_image);
    end
    guidata(hObject, handles);

function radiobutton_mean_Callback(hObject, ~, handles)
    if get(hObject,'Value')
        handles.plotDetail.param2mode = 'mean';
        set(handles.pulldown_param2Value,'enable','off');
    end
    
    % get mean image
    if ~isempty(handles.pixelTuning)
        [handles.plotDetail.dispImage,handles.plotDetail.param1val] = getImage(handles.pixelTuning,handles.trialDetail,handles.plotDetail);
        plotImage(handles.plotDetail.dispImage,handles.plotDetail,handles.axis_image);
    end
    guidata(hObject, handles);
    
function radiobutton_all_Callback(hObject, ~, handles)
    if get(hObject,'Value')
        handles.plotDetail.param2mode = 'all';
        set(handles.pulldown_param2Value,'enable','off');
    end
    
    % get mean image
    if ~isempty(handles.pixelTuning)
        [handles.plotDetail.dispImage,handles.plotDetail.param1val] = getImage(handles.pixelTuning,handles.trialDetail,handles.plotDetail);
        plotImage(handles.plotDetail.dispImage,handles.plotDetail,handles.axis_image);
    end
    guidata(hObject, handles);
    
function radiobutton_value_Callback(hObject, ~, handles)
    if get(hObject,'Value')
        handles.plotDetail.param2mode = 'value';
        handles.plotDetail.param2val = handles.trialDetail.domval(1,2);
        set(handles.pulldown_param2Value,'enable','on');
    else
        set(handles.pulldown_param2Value,'enable','off');
    end
    % get mean image
    if ~isempty(handles.pixelTuning)
        [handles.plotDetail.dispImage,handles.plotDetail.param1val] = getImage(handles.pixelTuning,handles.trialDetail,handles.plotDetail);
        plotImage(handles.plotDetail.dispImage,handles.plotDetail,handles.axis_image);
    end
    guidata(hObject, handles);

function pulldown_param2Value_Callback(hObject, ~, handles)
    contents = cellstr(get(hObject,'String'));
    handles.plotDetail.param2val = str2double(contents{get(hObject,'Value')});
    
    % get mean image
    if ~isempty(handles.pixelTuning)
        [handles.plotDetail.dispImage,handles.plotDetail.param1val] = getImage(handles.pixelTuning,handles.trialDetail,handles.plotDetail);
        plotImage(handles.plotDetail.dispImage,handles.plotDetail,handles.axis_image);
    end
    guidata(hObject, handles);
    
% =========================================================================
% ===================== ANALYZER MANIPULATION DONE ========================
% =========================================================================

% =========================================================================
% ======================== ANATOMY AXIS BUTTONS ===========================
% =========================================================================

function tbutton_maskmode_Callback(hObject, ~, handles)
    handles.maskmode = ~handles.maskmode;
    if handles.maskmode
        handles.clickToMagnify = 0;
        handles.pixelmode = 0;
%         showMask;
        set(handles.tbutton_pixelSelect,'CData',handles.pixIcon);
        set(handles.tbutton_clickToMagnify,'CData',handles.ctmIcon);
        set(handles.tbutton_maskmode,'CData',handles.mmIcon_on);
    else
        set(handles.slider_maskSize,'enable','off');
%         hideMask;
    end
    guidata(hObject, handles);

function tbutton_clickToMagnify_Callback(hObject, ~, handles)
    handles.clickToMagnify = ~handles.clickToMagnify;
    if handles.clickToMagnify
        handles.maskmode = 0;
        handles.pixelmode = 0;
        set(handles.tbutton_pixelSelect,'CData',handles.pixIcon);
        set(handles.tbutton_clickToMagnify,'CData',handles.ctmIcon_on);
        set(handles.tbutton_maskmode,'CData',handles.mmIcon);
    end
    guidata(hObject, handles);

function tbutton_pixelSelect_Callback(hObject, ~, handles)
    handles.pixelmode = ~handles.pixelmode;
    if handles.pixelmode
        handles.maskmode = 0;
        handles.clickToMagnify = 0;
        set(handles.tbutton_pixelSelect,'CData',handles.pixIcon_on);
        set(handles.tbutton_clickToMagnify,'CData',handles.ctmIcon);
        set(handles.tbutton_maskmode,'CData',handles.mmIcon);
    end
    guidata(hObject, handles);

function button_adjustTimeWindows_Callback(hObject, ~, handles)
    if handles.dataLoaded
        prompt = {'Baseline duration (in ms):','Post-stimulus duration (in ms):','Response start after stimulus onset (in ms):','Response stop after stimulus offset (in ms):'};
        dlg_title = 'Input';
        num_lines = 1;
        defaultans = {num2str(handles.imagingDetail.maxBaselineFrames*handles.imagingDetail.tPerFrame*1000),...
            num2str(handles.imagingDetail.maxPostFrames*handles.imagingDetail.tPerFrame*1000),...
            num2str(handles.timeWindows.respFrames(1)*handles.imagingDetail.tPerFrame*1000),...
            num2str(handles.timeWindows.respFrames(2)*handles.imagingDetail.tPerFrame*1000)};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        if isempty(answer); return; end

        maxBaselineFrames = round(str2double(answer{1})/(handles.imagingDetail.tPerFrame*1000));
        maxPostFrames = round(str2double(answer{2})/(handles.imagingDetail.tPerFrame*1000));
        respFrames = [round(str2double(answer{3})/(handles.imagingDetail.tPerFrame*1000))...
                      round(str2double(answer{4})/(handles.imagingDetail.tPerFrame*1000))];
        
      % nothing changed
        if maxBaselineFrames == handles.imagingDetail.maxBaselineFrames && ...
           maxPostFrames == handles.imagingDetail.maxPostFrames && ...
           isequal(respFrames,handles.timeWindows.respFrames)
            return;
        end
        
        if respFrames(2) > maxPostFrames
            msgbox('The number of response frames exceed the maximum requested frames. Please try again.','Frame count inconsistant','error');
            return;
        end
        
        if respFrames(2) > handles.imagingDetail.maxPostFrames || ...
            maxBaselineFrames ~= handles.imagingDetail.maxBaselineFrames || ...
            maxPostFrames ~= handles.imagingDetail.maxPostFrames
            handles = loadDataAndRefreshGui(handles,maxBaselineFrames,maxPostFrames,respFrames);
        else
            handles = updateTimeWindowsAndReplot(handles,respFrames);
        end
    else
        msgbox('Load data before adjusting time windows.','Data not loaded','error');
    end
    guidata(hObject, handles);

function slider_filterPx_Callback(hObject, ~, handles)
round(get(hObject,'Value'))
    handles.plotDetail.filterPx = round(get(hObject,'Value'));
    set(handles.slider_filterPx,'value',handles.plotDetail.filterPx);
    
    % get tuning for all pixels
    if ~isempty(handles.timeWindows)
        [handles.pixelTuning,handles.trialResp] = getPixelTuning...
            (handles.trialDetail,handles.timeWindows,...
            handles.plotDetail.filterPx,handles.imagingDetail.imageSize);
    else
        handles.pixelTuning = []; handles.trialResp = [];
    end
    
    % get mean image
    if ~isempty(handles.pixelTuning)
        [handles.plotDetail.dispImage,handles.plotDetail.param1val] = getImage(handles.pixelTuning,handles.trialDetail,handles.plotDetail);
        plotImage(handles.plotDetail.dispImage,handles.plotDetail,handles.axis_image);
        handles.plotDetail.anatomy = getAnatomy;
    else
        handles.plotDetail.param1val = [];
        handles.plotDetail.anatomy = [];
    end
    
    set(handles.axis_image,'xtick',[],'ytick',[]);
    box(handles.axis_image,'on');
    
    guidata(hObject, handles);
    
% =========================================================================
% ====================== ANATOMY AXIS BUTTONS DONE ========================
% =========================================================================    
    
% =========================================================================
% ======================== FUNCTIONAL AXIS BUTTONS ========================
% =========================================================================

function button_mask_add_Callback(hObject, ~, handles)

function button_mask_remove_Callback(hObject, ~, handles)

function button_mask_modify_Callback(hObject, ~, handles)

function button_maskGroup_move_Callback(hObject, ~, handles)

% =========================================================================
% ==================== FUNCTIONAL AXIS BUTTONS DONE =======================
% =========================================================================

% =========================================================================
% ================== CLICK TO MAGNIFY =====================================
% =========================================================================

% this function also does pixel tuning selection and mask creation etc.
% it also detects clicks on the tuning axis and displays tc for that condition
function figure1_WindowButtonDownFcn(hObject, ~, handles) 
    mouseLoc = get(handles.axis_image,'currentpoint');
    mouseLoc = fliplr(ceil(mouseLoc(1,1:2)));  
    if mouseLoc(1) < handles.imagingDetail.imageSize(1) && ...
       mouseLoc(2) < handles.imagingDetail.imageSize(2) && ...
       mouseLoc(1) > 0 && ...
       mouseLoc(2) > 0
        handles.buttonDownOnAxis = true;
        handles.selectedPixel = mouseLoc;
        % handle magnify
        if handles.clickToMagnify
            f1 = hObject;
            a1 = handles.axis_image;
            a2 = copyobj(a1,f1);

            set(f1,'UserData',[f1,a1,a2],'CurrentAxes',a2);
            set(a2,'Color',get(a1,'Color'),'xtick',[],'ytick',[],'Box','on');
            xlabel(''); ylabel(''); zlabel(''); title('');
            set(a1,'Color',get(a1,'Color')*0.95);
            figure1_WindowButtonMotionFcn(hObject,[],handles);
            
        % handle pixel tuning selection
        elseif handles.pixelmode && ~isempty(handles.trialResp)
            plotTuning(mouseLoc,handles.trialResp,handles.plotDetail,...
                handles.trialDetail,handles.imagingDetail,handles.timeWindows,...
                handles.axis_tc,handles.axis_tuning)
            if isfield(handles,'anatomyPointHandle') && ~isempty(handles.anatomyPointHandle) 
                delete(handles.anatomyPointHandle);
            end
            hPoint = plot(handles.axis_anatomy,mouseLoc(2),mouseLoc(1),'r.','markersize',20);
            handles.anatomyPointHandle = hPoint;
        
        % handle clicks for mask mode
        elseif handles.maskmode && ~isempty(handles.trialResp)
            r = handles.mask.roiSize;
            c = mouseLoc;
            handles.mask = addMask(handles.mask,r,c);
            showMasks(handles.mask);
        end
    end
    
    % tuning axis clicks
    mouseLoc = get(handles.axis_tuning,'currentpoint');
    if handles.dataLoaded
        if isfield(handles.plotDetail,'param1val') && ...
            mouseLoc(1,1) < max(handles.plotDetail.param1val) && ...
            mouseLoc(1,1) > min(handles.plotDetail.param1val) && ...
            mouseLoc(1,2) < max(get(handles.axis_tuning,'ylim')) && ...
            mouseLoc(1,2) > min(get(handles.axis_tuning,'ylim'))
            [~,selectedCondInd] = min(abs(handles.plotDetail.param1val - mouseLoc(1)));
            plotTimecoursePerCondition(handles.selectedPixel,selectedCondInd,handles.plotDetail,handles.trialDetail,handles.imagingDetail,handles.timeWindows,handles.axis_tc);
        end
    end
    guidata(hObject, handles);

function figure1_WindowButtonMotionFcn(hObject, ~, handles)
    mouseLoc = get(handles.axis_image,'currentpoint');
    mouseLoc = fliplr(ceil(mouseLoc(1,1:2)));  
    if mouseLoc(1) < handles.imagingDetail.imageSize(1) && ...
       mouseLoc(2) < handles.imagingDetail.imageSize(2) && ...
       mouseLoc(1) > 0 && ...
       mouseLoc(2) > 0
        if handles.buttonDownOnAxis; handles.selectedPixel = mouseLoc; end
        if handles.clickToMagnify
            H = get(hObject,'UserData');
            if ~isempty(H)
                f1 = H(1); a1 = H(2); a2 = H(3);
                a2_param = handles.clickToMagnifyData;
                f_pos = get(f1,'Position');
                a1_pos = get(a1,'Position');

                [f_cp, a1_cp] = pointer2d(f1,a1);

                set(a2,'Position',[(f_cp./f_pos(3:4)) 0 0] + a2_param(2)*a1_pos(3)*[-1 -1 2 2]);
                a2_pos = get(a2,'Position');

                set(a2,'XLim',a1_cp(1)+(1/a2_param(1))*(a2_pos(3)/a1_pos(3))*diff(get(a1,'XLim'))*[-0.5 0.5]);
                set(a2,'YLim',a1_cp(2)+(1/a2_param(1))*(a2_pos(4)/a1_pos(4))*diff(get(a1,'YLim'))*[-0.5 0.5]);
            end
        elseif handles.pixelmode && handles.buttonDownOnAxis && ~isempty(handles.trialResp)
            plotTuning(mouseLoc,handles.trialResp,handles.plotDetail,...
                handles.trialDetail,handles.imagingDetail,handles.timeWindows,...
                handles.axis_tc,handles.axis_tuning)
            if isfield(handles,'anatomyPointHandle') && ~isempty(handles.anatomyPointHandle) 
                delete(handles.anatomyPointHandle);
            end
            hPoint = plot(handles.axis_anatomy,mouseLoc(2),mouseLoc(1),'r.','markersize',20);
            handles.anatomyPointHandle = hPoint;
        end
    end
    guidata(hObject, handles);

function figure1_WindowButtonUpFcn(hObject, ~, handles) 
    mouseLoc = get(handles.axis_image,'currentpoint');
    mouseLoc = fliplr(ceil(mouseLoc(1,1:2)));  
    if mouseLoc(1) < handles.imagingDetail.imageSize(1) && ...
       mouseLoc(2) < handles.imagingDetail.imageSize(2) && ...
       mouseLoc(1) > 0 && ...
       mouseLoc(2) > 0
        handles.selectedPixel = mouseLoc;
        handles.buttonDownOnAxis = false;
        if handles.clickToMagnify
            H = get(hObject,'UserData');
            f1 = H(1); a1 = H(2); a2 = H(3);
            set(a1,'Color',get(a2,'Color'));
            set(f1,'UserData',[],'Pointer','arrow','CurrentAxes',a1);
            if ~strcmp(get(f1,'SelectionType'),'alt'),
              delete(a2);
            end
        end
        if isfield(handles,'anatomyPointHandle') && ~isempty(handles.anatomyPointHandle) 
            delete(handles.anatomyPointHandle);
        end
    end
    guidata(hObject, handles);

function figure1_KeyPressFcn(hObject, ~, handles)
    if handles.clickToMagnify
        H = get(hObject,'UserData');
        if ~isempty(H)
            f1 = H(1); a1 = H(2); a2 = H(3);
            if (strcmp(get(f1,'CurrentCharacter'),'+') || strcmp(get(f1,'CurrentCharacter'),'='))
                handles.clickToMagnifyData(1) = handles.clickToMagnifyData(1)*1.2;
            elseif (strcmp(get(f1,'CurrentCharacter'),'-') || strcmp(get(f1,'CurrentCharacter'),'_'))
                handles.clickToMagnifyData(1) = handles.clickToMagnifyData(1)/1.2;
            elseif (strcmp(get(f1,'CurrentCharacter'),'<') || strcmp(get(f1,'CurrentCharacter'),','))
                handles.clickToMagnifyData(2) = handles.clickToMagnifyData(2)/1.2;
            elseif (strcmp(get(f1,'CurrentCharacter'),'>') || strcmp(get(f1,'CurrentCharacter'),'.'))
                handles.clickToMagnifyData(2) = handles.clickToMagnifyData(2)*1.2;
            end;
            set(a2,'UserData',handles.clickToMagnifyData);
            figure1_WindowButtonMotionFcn(hObject,[],handles);
        end
    end
    guidata(hObject, handles);

function [fig_pointer_pos, axes_pointer_val] = pointer2d(fig_hndl,axes_hndl)
    set(fig_hndl,'Units','pixels');
    set(axes_hndl,'Units','normalized');

    pointer_pos = get(0,'PointerLocation');	%pixels {0,0} lower left
    fig_pos = get(fig_hndl,'Position');	%pixels {l,b,w,h}

    fig_pointer_pos = pointer_pos - fig_pos([1,2]);
    set(fig_hndl,'CurrentPoint',fig_pointer_pos);

    if isempty(axes_hndl)
        axes_pointer_val = [];
    elseif nargout == 2
        axes_pointer_line = get(axes_hndl,'CurrentPoint');
        axes_pointer_val = sum(axes_pointer_line)/2;
    end
    
% =========================================================================
% ================== CLICK TO MAGNIFY DONE ================================
% =========================================================================

% =========================================================================
% ========================== PIXEL CLICKED ================================
% =========================================================================
    
% =========================================================================
% ========================== PIXEL CLICKED DONE ===========================
% =========================================================================


% =========================================================================
% ============================== CREATEFNs ================================
% =========================================================================

function pulldown_param1_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function pulldown_param2_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function pulldown_param2Value_CreateFcn(hObject, ~, ~) %#ok<*DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function textbox_moduloValue_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function slider_maskSize_CreateFcn(hObject, ~, ~)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
    
function slider_filterPx_CreateFcn(hObject, ~, ~)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end

% =========================================================================
% ========================= CREATEFNs DONE ================================
% =========================================================================

% =========================================================================
% ========================== HELPER FUNCTIONS =============================
% =========================================================================

function handles = loadDataAndRefreshGui(handles,maxBaselineFrames,maxPostFrames,respFrames)
    global pixelTc imagingDetail exptDetail

    if ~exist('maxBaselineFrames','var');   maxBaselineFrames = 10; end
    if ~exist('maxPostFrames','var');       maxPostFrames = 20;     end
    if ~exist('respFrames','var');          respFrames = [1 8];     end

    if ~getPixelTcFromSbx(maxBaselineFrames,maxPostFrames)
        msgbox('File does not exist or trials don''t match.','Error','error');
        return;
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
    global Analyzer
    load(['Z:\2P\Analyzer\' exptDetail.animal '\' exptDetail.animal '_u' exptDetail.unit '_' exptDetail.expt '.analyzer'],'-mat');
    % ===================
    
    handles.analyzer = Analyzer;
    handles.exptDetail = exptDetail;
    handles.imagingDetail = imagingDetail;
    handles.trialDetail = getTrialDetail(handles.analyzer);
    handles.dataLoaded = true;
    handles.clickToMagnifyData = [4,0.08];
    set(handles.pulldown_param1,'String',handles.trialDetail.domains);
    set(handles.pulldown_param1,'Value',1);
    set(handles.textbox_moduloValue,'String','180','Enable','off');
    if strcmp(handles.trialDetail.domains{1},'ori')
        set(handles.checkbox_circular,'Value',1);
        handles.plotDetail.param1_circular = true;
    else
        set(handles.checkbox_circular,'Value',0);
        handles.plotDetail.param1_circular = false;
    end
    handles.plotDetail.param1name = handles.trialDetail.domains{1};
    handles.plotDetail.param1_modulo = false;
    handles.plotDetail.param1_moduloVal = 180;
    if handles.trialDetail.isMultipleDomain
        set(handles.pulldown_param2,'String',handles.trialDetail.domains);
        set(handles.pulldown_param2,'Value',2);
        set(handles.pulldown_param2Value,'String',unique(handles.trialDetail.domval(:,2)),'value',1);
        
        set(handles.radiobutton_mean,'Value',1);
        set(handles.radiobutton_all,'Value',0);
        set(handles.radiobutton_value,'Value',0);
        
        handles.plotDetail.param2name = handles.trialDetail.domains{2};
        handles.plotDetail.param2val = handles.trialDetail.domval(1,2);
        handles.plotDetail.param2mode = 'mean';
        
        set(handles.pulldown_param2Value,'enable','off');
        
        set(handles.pulldown_param2,'enable','on');
        set(handles.radiobutton_mean,'enable','on');
        set(handles.radiobutton_all,'enable','on');
        set(handles.radiobutton_value,'enable','on');
    else
        set(handles.pulldown_param2,'enable','off');
        set(handles.pulldown_param2Value,'enable','off');
        set(handles.radiobutton_mean,'enable','off');
        set(handles.radiobutton_all,'enable','off');
        set(handles.radiobutton_value,'enable','off');
        
        handles.plotDetail.param2name = [];
        handles.plotDetail.param2val = [];
        handles.plotDetail.param2mode = [];
    end
    handles = updateTimeWindowsAndReplot(handles,respFrames);

function handles = updateTimeWindowsAndReplot(handles,respFrames)
    handles.timeWindows = getTimeWindows(handles.imagingDetail,respFrames);
    [handles.pixelTuning,handles.trialResp] = getPixelTuning...
        (handles.trialDetail,handles.timeWindows,...
        handles.plotDetail.filterPx,handles.imagingDetail.imageSize);
    handles.plotDetail.anatomy = getAnatomy;
    [handles.plotDetail.dispImage,handles.plotDetail.param1val] = getImage(handles.pixelTuning,handles.trialDetail,handles.plotDetail);
    plotImage(handles.plotDetail.dispImage,handles.plotDetail,handles.axis_image);
    cla(handles.axis_anatomy);
    if handles.plotDetail.showAnatomy        
        imagesc(handles.plotDetail.anatomy,'parent',handles.axis_anatomy);
        colormap(handles.axis_anatomy,'gray')
        hold(handles.axis_anatomy,'on')
        set(handles.axis_anatomy,'xtick',[],'ytick',[]);
        box(handles.axis_anatomy,'on')
    end
    
function mask = addMask(mask,r,c)
    if ~isfield(mask,'roiList'); mask.roiList = []; end
    mask.roiCount = mask.roiCount + 1;
    mask.roiList(mask.roiCount).r = r;
    mask.roiList(mask.roiCount).c = c;

    x = 1:size(mask.maskImage,1);
    y = 1:size(mask.maskImage,2);
    [xx,yy] = meshgrid(x,y);

    cellMask = hypot(xx - c(1), yy - c(2)) <= r;
    mask.maskImage = mask.maskImage + mask.roiCount*cellMask;
    mask.roiList(mask.roiCount).pixels = find(cellMask);
    
function showMasks(mask)
    if isempty(mask.maskLayerHandle)
        
    end
    
    axes(handles.Image)
    h = imellipse(gca,[min(j) min(i) max(j)-min(j) max(i)-min(i)]);
    wait(h);
    % Create a mask from that image
    mask = createMask(h);
    % Now we're done with the ellipse, delete it
    delete(h);

% =========================================================================
% ======================= HELPER FUNCTIONS DONE ===========================
% =========================================================================


% --------------------------------------------------------------------
function contextMenu_mask_Callback(hObject, eventdata, handles)
% hObject    handle to contextMenu_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function contextMenu_mask_modify_Callback(hObject, eventdata, handles)
% hObject    handle to contextMenu_mask_modify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function contextMenu_mask_remove_Callback(hObject, eventdata, handles)
% hObject    handle to contextMenu_mask_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




