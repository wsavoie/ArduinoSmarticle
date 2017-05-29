function varargout = smartSoundGUI(varargin)
% SMARTSOUNDGUI MATLAB code for smartSoundGUI.fig
%      SMARTSOUNDGUI, by itself, creates a new SMARTSOUNDGUI or raises the existing
%      singleton*.
%
%      H = SMARTSOUNDGUI returns the handle to a new SMARTSOUNDGUI or the handle to
%      the existing singleton*.
%
%      SMARTSOUNDGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SMARTSOUNDGUI.M with the given input arguments.
%
%      SMARTSOUNDGUI('Property','Value',...) creates a new SMARTSOUNDGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before smartSoundGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to smartSoundGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help smartSoundGUI

% Last Modified by GUIDE v2.5 29-May-2017 16:51:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @smartSoundGUI_OpeningFcn, ...
    'gui_OutputFcn',  @smartSoundGUI_OutputFcn, ...
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



% --- Executes just before smartSoundGUI is made visible.
function smartSoundGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to smartSoundGUI (see VARARGIN)

% Choose default command line output for smartSoundGUI
handles.output = hObject;
global sampRate tt player
sampRate = 8192;
tt=(0:sampRate*1000)/sampRate;
player = audioplayer(sin(tt*15*2*pi), sampRate);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes smartSoundGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
set(gcf, 'WindowKeyPressFcn', @figure1_WindowKeyPressFcn)

% --- Outputs from this function are returned to the command line.
function varargout = smartSoundGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sampRate tt player
freq=str2double(hObject.String);
% handles.freq=freq;
guidata(hObject,freq);
playfreq(freq);


% --- Executes on button press in pushbutton1.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sampRate tt player
freq=str2double(hObject.String);
pause(player);
player=audioplayer(sin(tt*freq*2*pi), sampRate);
play(player);
%pts(freq);

% --- Executes on button press in pushbutton1.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sampRate tt player
freq=str2double(hObject.String);
pause(player);
player=audioplayer(sin(tt*freq*2*pi), sampRate);
play(player);
%pts(freq);

% --- Executes on button press in pushbutton1.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sampRate tt player
freq=str2double(hObject.String);
pause(player);
player=audioplayer(sin(tt*freq*2*pi), sampRate);
play(player);
%pts(freq);

% --- Executes on button press in pushbutton1.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sampRate tt player
freq=str2double(hObject.String);
pause(player);
player=audioplayer(sin(tt*freq*2*pi), sampRate);
play(player);
% %pts(freq);

% --- Executes on button press in pushbutton1.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sampRate tt player
freq=str2double(hObject.String);
pause(player);
player=audioplayer(sin(tt*freq*2*pi), sampRate);
play(player);
%pts(freq);

% --- Executes on button press in pushbutton1.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sampRate tt player
freq=str2double(hObject.String);
pause(player);
player=audioplayer(sin(tt*freq*2*pi), sampRate);
play(player);
%pts(freq);

% --- Executes on button press in pushbutton1.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sampRate tt player
freq=str2double(hObject.String);
pause(player);
player=audioplayer(sin(tt*freq*2*pi), sampRate);
play(player);
%pts(freq);

% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sampRate tt player
pause(player);


% function KeyPress(hObject, eventdata, handles)
% % determine the key that was pressed
% global sampRate tt player
% key = get(gcf,'CurrentKey');
% f0=50;
% switch eventdata.Key
%     case 'f1'
%         pushbutton7_Callback(handles.pushbutton7, [], handles); 
%     case 'f2'
%         playfreq(str2num(pushbutton2.String));
%     case 'f3'
%         playfreq(str2num(pushbutton3.String));
%     case 'f4'
%         playfreq(str2num(pushbutton4.String));
%     case 'f5'
%         playfreq(str2num(pushbutton5.String));
%     case 'f6'
%         playfreq(str2num(pushbutton6.String));
%     case 'f7'
%         playfreq(str2num(pushbutton7.String));
%     case 'f8'
%         pushbutton8_Callback;
%     case 'escape'
%         pause(player);
% end

function playfreq(freq)
global sampRate tt player
pause(player);
player=audioplayer(sin(tt*freq*2*pi), sampRate);
play(player);
%pts(freq);


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% determine the key that was pressed
global sampRate tt player
key = get(gcf,'CurrentKey');
f0=50;
handles = guidata(hObject);
switch eventdata.Key
    case 'f1'
        playfreq(str2double(handles.pushbutton1.String));
    case 'f2'
        playfreq(str2double(handles.pushbutton2.String));
    case 'f3'
        playfreq(str2double(handles.pushbutton3.String));
    case 'f4'
        playfreq(str2double(handles.pushbutton4.String));
    case 'f5'
        playfreq(str2double(handles.pushbutton5.String));
    case 'f6'
        playfreq(str2double(handles.pushbutton6.String));
    case 'f7'
        playfreq(str2double(handles.pushbutton7.String));
    case 'f8'
        playfreq(str2double(handles.pushbutton8.String));;
    case 'escape'
        pause(player);
end


