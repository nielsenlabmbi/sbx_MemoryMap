function varargout = avgPixGui(varargin)
% AVGPIXGUI MATLAB code for avgPixGui.fig
%      AVGPIXGUI, by itself, creates a new AVGPIXGUI or raises the existing
%      singleton*.
%
%      H = AVGPIXGUI returns the handle to a new AVGPIXGUI or the handle to
%      the existing singleton*.
%
%      AVGPIXGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AVGPIXGUI.M with the given input arguments.
%
%      AVGPIXGUI('Property','Value',...) creates a new AVGPIXGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before avgPixGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to avgPixGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help avgPixGui

% Last Modified by GUIDE v2.5 05-Aug-2016 14:09:04

% Begin initialization code - DO NOT EDIT
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
% End initialization code - DO NOT EDIT


% --- Executes just before avgPixGui is made visible.
function avgPixGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to avgPixGui (see VARARGIN)

% Choose default command line output for avgPixGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes avgPixGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


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
