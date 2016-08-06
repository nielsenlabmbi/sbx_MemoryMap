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
    
    % have the details in handles for easy access
    % note: pixelTc is still global
    handles.analyzer = Analyzer;
    handles.exptDetail = exptDetail;
    handles.imagingDetail = imagingDetail;
    
    % get all details of stimul;i and blanks
    handles.trialDetail = getTrialDetail(Analyzer);
    
    % get time windows depending upon how many frames were collected
    handles.timeWindows = getTimeWindows(handles.imagingDetail);
    
    % get tuning for all pixels
    [handles.pixelTuning,handles.trialResp] = getPixelTuning...
        (handles.trialDetail,handles.timeWindows,handles.imagingDetail.imageSize);
    
    % gui changes
    set(handles.pulldown_param1,'String',handles.trialDetail.domains);
    set(handles.pulldown_param1,'Value',1);
    set(handles.textbox_moduloValue,'String','180','Enable','off');
    if strcmp(handles.trialDetail.domains{1},'ori')
        set(handles.checkbox_circular,'Value',1);
        handles.plotDetail.param1_circular = true;
    end
    
    handles.plotDetail.filterPx = 1;
    
    handles.plotDetail.param1name = handles.trialDetail.domains{1};
    handles.plotDetail.param1_modulo = false;
    handles.plotDetail.param1_moduloVal = 180;
    
    handles.mask.sizeMult = 5;
    handles.mask.size = get(handles.slider_maskSize,'value') * handles.mask.sizeMult;
    
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
    
    % get mean image
%     dispImage = getImage(handles.pixelTuning,handles.trialDetail,handles.plotDetail);
    
    set(handles.axis_image,'xtick',[],'ytick',[]);
    box(handles.axis_image,'on');
    
    % Update handles structure
    guidata(hObject, handles);

% =========================================================================
% ========================== TOOLBAR CALLBACKS ============================
% =========================================================================

% --- Outputs from this function are returned to the command line.
function varargout = avgPixGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function uipushtool_open_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function uipushtool_save_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function uitoggletool_zoomIn_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool_zoomIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function uitoggletool_zoomOut_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool_zoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function uitoggletool_pixCursor_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool_pixCursor (see GCBO)
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
    guidata(hObject, handles);
    
function checkbox_modulo_Callback(hObject, ~, handles)
    handles.plotDetail.param1_modulo = get(hObject,'Value');
    if get(hObject,'Value')
        set(handles.textbox_moduloValue,'enable','on');
    else
        set(handles.textbox_moduloValue,'enable','off');
    end
        
    guidata(hObject, handles);

function textbox_moduloValue_Callback(hObject, ~, handles)
    handles.plotDetail.param1_moduloVal = str2double(get(hObject,'String'));
    guidata(hObject, handles);

function radiobutton_mean_Callback(hObject, ~, handles)
    if get(hObject,'Value')
        handles.plotDetail.param2mode = 'mean';
        set(handles.pulldown_param2Value,'enable','off');
    end
    guidata(hObject, handles);
    
function radiobutton_all_Callback(hObject, ~, handles)
    if get(hObject,'Value')
        handles.plotDetail.param2mode = 'all';
        set(handles.pulldown_param2Value,'enable','off');
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
    guidata(hObject, handles);

function pulldown_param2Value_Callback(hObject, ~, handles)
    contents = cellstr(get(hObject,'String'));
    handles.plotDetail.param2val = str2double(contents{get(hObject,'Value')});
    guidata(hObject, handles);
    
% =========================================================================
% ===================== ANALYZER MANIPULATION DONE ========================
% =========================================================================

% =========================================================================
% ======================== IMAGE AXIS BUTTONS =============================
% =========================================================================
    
function tbutton_maskmode_Callback(hObject, ~, handles)
    handles.maskmode = ~handles.maskmode;
    if handles.maskmode
        set(handles.slider_maskSize,'enable','on');
        handles.clickToMagnify = 0;
        handles.pixelmode = 0;
%         showMask;
    else
        set(handles.slider_maskSize,'enable','off');
%         hideMask;
    end
    guidata(hObject, handles);

function tbutton_clickToMagnify_Callback(hObject, ~, handles)
    handles.clickToMagnify = ~handles.clickToMagnify;
    if handles.clickToMagnify
        set(handles.slider_maskSize,'enable','off');
        handles.maskmode = 0;
        handles.pixelmode = 0;
    end
    guidata(hObject, handles);

function tbutton_pixelSelect_Callback(hObject, ~, handles)
    handles.pixelmode = ~handles.pixelmode;
    if handles.pixelmode
        set(handles.slider_maskSize,'enable','off');
        handles.maskmode = 0;
        handles.clickToMagnify = 0;
    end
    guidata(hObject, handles);
    
function slider_maskSize_Callback(hObject, ~, handles)
    normMaskSize = get(hObject,'value');
    handles.mask.size = normMaskSize * handles.mask.sizeMult;
    guidata(hObject, handles);

function button_adjustContrast_Callback(~, ~, handles)
    imcontrast(handles.axis_image);

function button_adjustTimeWindows_Callback(hObject, ~, handles)
    
% =========================================================================
% ====================== IMAGE AXIS BUTTONS DONE ==========================
% =========================================================================    
    
% =========================================================================
% ================== CLICK TO MAGNIFY =====================================
% =========================================================================

function figure1_WindowButtonDownFcn(hObject, ~, handles) 
    if handles.clickToMagnify
        f1 = hObject;
        a1 = handles.axis_image;
        a2 = copyobj(a1,f1);

        set(f1, ...
          'UserData',[f1,a1,a2], ...
          'CurrentAxes',a2);
        set(a2, ...
          'UserData',[4,0.05], ...  %magnification, frame size
          'Color',get(a1,'Color'), ...
          'xtick',[],...
          'ytick',[],...
          'Box','on');
        xlabel(''); ylabel(''); zlabel(''); title('');
        set(a1, ...
          'Color',get(a1,'Color')*0.95);
        set(f1, ...
          'CurrentAxes',a1);
        figure1_WindowButtonMotionFcn(hObject,[],handles);
    end

function figure1_WindowButtonMotionFcn(hObject, ~, handles)
    if handles.clickToMagnify
        H = get(hObject,'UserData');
        if ~isempty(H)
            f1 = H(1); a1 = H(2); a2 = H(3);
            a2_param = get(a2,'UserData');
            f_pos = get(f1,'Position');
            a1_pos = get(a1,'Position');

            [f_cp, a1_cp] = pointer2d(f1,a1);

            set(a2,'Position',[(f_cp./f_pos(3:4)) 0 0]+a2_param(2)*a1_pos(3)*[-1 -1 2 2]);
            a2_pos = get(a2,'Position');

            set(a2,'XLim',a1_cp(1)+(1/a2_param(1))*(a2_pos(3)/a1_pos(3))*diff(get(a1,'XLim'))*[-0.5 0.5]);
            set(a2,'YLim',a1_cp(2)+(1/a2_param(1))*(a2_pos(4)/a1_pos(4))*diff(get(a1,'YLim'))*[-0.5 0.5]);
        end
    end

function figure1_WindowButtonUpFcn(hObject, ~, handles) 
    if handles.clickToMagnify
        H = get(hObject,'UserData');
        f1 = H(1); a1 = H(2); a2 = H(3);
        set(a1, ...
          'Color',get(a2,'Color'));
        set(f1, ...
          'UserData',[], ...
          'Pointer','arrow', ...
          'CurrentAxes',a1);
        if ~strcmp(get(f1,'SelectionType'),'alt'),
          delete(a2);
        end
    end

function figure1_KeyPressFcn(hObject, ~, handles)
    if handles.clickToMagnify
        H = get(hObject,'UserData');
        if ~isempty(H)
            f1 = H(1); a1 = H(2); a2 = H(3);
            a2_param = get(a2,'UserData');
            if (strcmp(get(f1,'CurrentCharacter'),'+') || strcmp(get(f1,'CurrentCharacter'),'='))
             a2_param(1) = a2_param(1)*1.2;
            elseif (strcmp(get(f1,'CurrentCharacter'),'-') || strcmp(get(f1,'CurrentCharacter'),'_'))
             a2_param(1) = a2_param(1)/1.2;
            elseif (strcmp(get(f1,'CurrentCharacter'),'<') || strcmp(get(f1,'CurrentCharacter'),','))
             a2_param(2) = a2_param(2)/1.2;
            elseif (strcmp(get(f1,'CurrentCharacter'),'>') || strcmp(get(f1,'CurrentCharacter'),'.'))
             a2_param(2) = a2_param(2)*1.2;
            end;
            set(a2,'UserData',a2_param);
            figure1_WindowButtonMotionFcn(hObject,[],handles);
        end
    end

function [fig_pointer_pos, axes_pointer_val] = pointer2d(fig_hndl,axes_hndl)
    if (nargin == 0), fig_hndl = gcf; axes_hndl = gca; end;
    if (nargin == 1), axes_hndl = get(fig_hndl,'CurrentAxes'); end;

    set(fig_hndl,'Units','pixels');

    pointer_pos = get(0,'PointerLocation');	%pixels {0,0} lower left
    fig_pos = get(fig_hndl,'Position');	%pixels {l,b,w,h}

    fig_pointer_pos = pointer_pos - fig_pos([1,2]);
    set(fig_hndl,'CurrentPoint',fig_pointer_pos);

    if (isempty(axes_hndl)),
        axes_pointer_val = [];
    elseif (nargout == 2),
        axes_pointer_line = get(axes_hndl,'CurrentPoint');
        axes_pointer_val = sum(axes_pointer_line)/2;
    end
    
% =========================================================================
% ================== CLICK TO MAGNIFY DONE ================================
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

% =========================================================================
% ========================= CREATEFNs DONE ================================
% =========================================================================