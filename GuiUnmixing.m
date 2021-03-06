function varargout = GuiUnmixing(varargin)
% GUIUNMIXING MATLAB code for GuiUnmixing.fig
%      GUIUNMIXING, by itself, creates a new GUIUNMIXING or raises the existing
%      singleton*.
%
%      H = GUIUNMIXING returns the handle to a new GUIUNMIXING or the handle to
%      the existing singleton*.
%
%      GUIUNMIXING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIUNMIXING.M with the given input arguments.
%
%      GUIUNMIXING('Property','Value',...) creates a new GUIUNMIXING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GuiUnmixing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GuiUnmixing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GuiUnmixing

% Last Modified by GUIDE v2.5 21-May-2019 10:24:28

% Author: Thanh Bui (thanh.bui@erametgroup.com)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuiUnmixing_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiUnmixing_OutputFcn, ...
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


% --- Executes just before GuiUnmixing is made visible.
function GuiUnmixing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GuiUnmixing (see VARARGIN)

% Choose default command line output for GuiUnmixing
handles.output = hObject;

% Add paths
if (~isdeployed)
    addpath('D:\Matlab\GUI_SOLSA\Unmixing')
    addpath('D:\Matlab\GUI_SOLSA\Utilities')
end

% Logo display
if(isdeployed)
    img = imread('solsa_logo1.jpg');
    load ExtractedLib.mat
else
    img = imread('images/solsa_logo1.jpg');
    % Load library
    load D:\Matlab\GUI_SOLSA\Data\ExtractedLib.mat
    % load D:\Matlab\Unmixing\GenerateSpecLib\ExtractedLib.mat
end
axes(handles.axes2); imshow(img)

% Set data path
handles.reflectancePath = ' ';
handles.currentPath = 'C:\';

% Get mineral dict 
[mineralDict, mineralList] = decompose_mineral_names(min_names);
handles.mineralDict = mineralDict;
handles.mineralList = mineralList;
handles.A = A;
handles.wavelength = wavelength;


set(handles.mineralListLb, 'String', mineralDict.keys)

% Axis off for axes1

set(handles.axes1, 'XColor','none','YColor','none');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GuiUnmixing wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GuiUnmixing_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% 0) Loading spectral library
% --- Executes on button press in specLib_Pb.
function specLib_Pb_Callback(hObject, eventdata, handles)
% hObject    handle to specLib_Pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, path, oCancel] = uigetfile('.mat', 'Select a file', handles.currentPath);
if ~oCancel
    disp('User selects Cancel')
    return
end
handles.currentPath = fullfile(path, filename);
load (fullfile(path, filename));
% Get mineral dict 
[mineralDict, mineralList] = decompose_mineral_names(min_names);
handles.mineralDict = mineralDict;
handles.mineralList = mineralList;

handles.A = A;
handles.wavelength = wavelength;
set(handles.mineralListLb, 'Value', length(mineralDict.keys)) % Set the Value parameter of the listbox
set(handles.mineralListLb, 'String', mineralDict.keys)

figure, imagesc(A), xlabel('# endmembers'), ylabel('# bands')
% Update handle structures
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function specLib_Pb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to specLib_Pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% 1) ============ Data selection ==========================================

% --- Executes on button press in reflectancePb.
function reflectancePb_Callback(hObject, eventdata, handles)
% hObject    handle to reflectancePb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, path, oCancel] = uigetfile('.raw', 'Select a file', handles.currentPath);
if ~oCancel  % User clicks Cancel
    return
end
handles.currentPath = path;
set(handles.reflectanceEdit, 'String', fullfile(path, filename))
dataFile = fullfile(path, filename);
handles.reflectancePath = dataFile;
[data, info, rgb_img] = access_spectra_data(dataFile);
dataWavelength = info.Wavelength;
wavelength = handles.wavelength;

assignin('base', 'data', data)
assignin('base', 'info', info)
assignin('base', 'wavelength', wavelength)

% Handle the case where facing different spectral resolution
if length(wavelength) ~= length(dataWavelength)
    index = zeros(length(wavelength),1);
    for i = 1: length(wavelength)
        band = wavelength(i);
        [~, index(i)] = min(abs(dataWavelength-band)); 
    end
    data = data(:,:,index);
end

handles.data = data;
handles.info = info;
handles.rgb_img = rgb_img;
handles.rgb_img_adj = rgb_img;
handles.fileName = filename;

% Band selection
if mean(info.Wavelength > 1100)
    handles.r_wl = 2000; 
    handles.g_wl = 2200; 
    handles.b_wl = 2350;
else
    handles.r_wl = 700; 
    handles.g_wl = 600; 
    handles.b_wl = 500;
end
set(handles.rSlider, 'Value', (handles.r_wl-min(info.Wavelength))/(max(info.Wavelength)-min(info.Wavelength)));
set(handles.rEdit, 'String', handles.r_wl);
set(handles.gSlider, 'Value', (handles.g_wl-min(info.Wavelength))/(max(info.Wavelength)-min(info.Wavelength)));
set(handles.gEdit, 'String', handles.g_wl);
set(handles.bSlider, 'Value', (handles.b_wl-min(info.Wavelength))/(max(info.Wavelength)-min(info.Wavelength)));
set(handles.bEdit, 'String', handles.b_wl);

% img slider
set(handles.imgSlider, 'Value', 0.5);


axes(handles.axes1)
cla(handles.axes1, 'reset')
imshow(rgb_img); axis on;

% Update handles
guidata(hObject, handles);

function reflectanceEdit_Callback(hObject, eventdata, handles)
% hObject    handle to reflectanceEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of reflectanceEdit as text
%        str2double(get(hObject,'String')) returns contents of reflectanceEdit as a double


% --- Executes during object creation, after setting all properties.
function reflectanceEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reflectanceEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% 2) ================== Crop data =========================================

function xMinEdit_Callback(hObject, eventdata, handles)
% hObject    handle to xMinEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xMinEdit as text
%        str2double(get(hObject,'String')) returns contents of xMinEdit as a double


% --- Executes during object creation, after setting all properties.
function xMinEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xMinEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xMaxEdit_Callback(hObject, eventdata, handles)
% hObject    handle to xMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xMaxEdit as text
%        str2double(get(hObject,'String')) returns contents of xMaxEdit as a double


% --- Executes during object creation, after setting all properties.
function xMaxEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yMinEdit_Callback(hObject, eventdata, handles)
% hObject    handle to yMinEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yMinEdit as text
%        str2double(get(hObject,'String')) returns contents of yMinEdit as a double


% --- Executes during object creation, after setting all properties.
function yMinEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yMinEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yMaxEdit_Callback(hObject, eventdata, handles)
% hObject    handle to yMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yMaxEdit as text
%        str2double(get(hObject,'String')) returns contents of yMaxEdit as a double


% --- Executes during object creation, after setting all properties.
function yMaxEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cropDisplayPb.
function cropDisplayPb_Callback(hObject, eventdata, handles)
% hObject    handle to cropDisplayPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    rgb_img = handles.rgb_img_adj;
catch
    msgbox(sprintf('Load data first'), 'Error', 'error');
    return
end
nImg = size(rgb_img);

xMin = str2double(get(handles.xMinEdit,'String'));
if isnan(xMin), xMin = 1; end
xMax = str2double(get(handles.xMaxEdit,'String'));
if isnan(xMax), xMax = nImg(2); end 

yMin = str2double(get(handles.yMinEdit,'String'));
if isnan(yMin), yMin = 1; end
yMax = str2double(get(handles.yMaxEdit,'String'));
if isnan(yMax), yMax = nImg(1); end

xRate = str2double(get(handles.xRateEdit, 'String'));
if isnan(xRate), xRate = 1; end
yRate = str2double(get(handles.yRateEdit, 'String'));
if isnan(yRate), yRate = 1; end

% Resolution
x_res = 169.5/1000;         % mm
y_res = 120.0/1000;         % mm
x_org = (1:size(rgb_img,2))*x_res;
y_org = (1:size(rgb_img,1))*y_res;
x = x_org(xMin:xRate:xMax);
y = y_org(yMin:yRate:yMax);

handles.cropSub = [yMin, yMax, xMin, xMax];
handles.downRate = [yRate, xRate];
res.y = y;
res.x = x;
handles.resolution = res;


rgb_imgCrop = rgb_img(yMin:yRate:yMax, xMin:xRate:xMax, :);
handles.rgb_imgCrop = rgb_imgCrop;

figure
%imshow(rgb_img_crop)
imagesc(x, y, rgb_imgCrop), xlabel('mm'), ylabel('mm')

% Update handles
guidata(hObject, handles)


% 3) ============== Superpixel computation ============================================

% --- Executes on button press in displayPb.
function displayPb_Callback(hObject, eventdata, handles)
% hObject    handle to displayPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the crop subscripts and resampling rates.
try 
    cropSub = handles.cropSub;
    downRate = handles.downRate;

    rgb_img = handles.rgb_img_adj(cropSub(1):downRate(1):cropSub(2), cropSub(3):downRate(2): cropSub(4), :);
    refl = handles.data(cropSub(1):downRate(1):cropSub(2), cropSub(3):downRate(2): cropSub(4), :);
catch
    msgbox('Load data first', 'Error', 'error')
    return
end

if (get(handles.rgbImgRb, 'Value')) % RGB image
    disp('Computing SLIC superpixels ... using RGB image')
    nSuperpixels = str2double(get(handles.nSuperpixelEdit, 'String'));
    if isnan(nSuperpixels)  % Default number of superpixels
        nSuperpixels = 100;
        set(handles.nSuperpixelEdit, 'String', nSuperpixels);
    end
        
    tic, [L,N] = superpixels(rgb_img, nSuperpixels, 'Compactness', 8); toc
    fprintf('Number of superpixels: %d \n', N)
    idx = label2idx(L);
    BW = boundarymask(L);
    figure, imshow(imoverlay(rgb_img,BW,'cyan')), title('SLIC using RGB image')
    
elseif get(handles.hyperImgRb, 'Value') % Using hyperspectral data
    disp('Computing SLIC superpixels ... using hyperspectral image');
    regionSize = str2double(get(handles.regionSizeEdit, 'String'));
    if isnan(regionSize)
        regionSize = 15; 
        set(handles.regionSizeEdit, 'String', regionSize);
    end
   
    regularizer = str2double(get(handles.regularizerEdit, 'String'));
    if isnan(regularizer)
        regularizer = 0.05; 
        set(handles.regularizerEdit, 'String', regularizer);
    end
    
    % Apply slic for hyperspectral data
    [nRows,nCols,nSpectra] = size(refl);
    scfact = mean(reshape(sqrt(sum(refl.^2,3)),nRows*nCols,1));
    img = refl./scfact;
    % compute superpixels    
    tic; spSegs = vl_slic(single(img),regionSize,regularizer); toc % regionSize and regularizer
    numSuperpixels = double(max(spSegs(:)))+1;
    fprintf('Number of superpixels: %d\n', numSuperpixels)
    BW = boundarymask(spSegs);
    figure, imshow(imoverlay(rgb_img,BW,'cyan')), title('SLIC using hyperspectral data')
    idx = label2idx(spSegs);   
end
handles.idx = idx;

% Update handles
guidata(hObject, handles)
    
function nSuperpixelEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nSuperpixelEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nSuperpixelEdit as text
%        str2double(get(hObject,'String')) returns contents of nSuperpixelEdit as a double


% --- Executes during object creation, after setting all properties.
function nSuperpixelEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nSuperpixelEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function regionSizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to regionSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of regionSizeEdit as text
%        str2double(get(hObject,'String')) returns contents of regionSizeEdit as a double


% --- Executes during object creation, after setting all properties.
function regionSizeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to regionSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function regularizerEdit_Callback(hObject, eventdata, handles)
% hObject    handle to regularizerEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of regularizerEdit as text
%        str2double(get(hObject,'String')) returns contents of regularizerEdit as a double


% --- Executes during object creation, after setting all properties.
function regularizerEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to regularizerEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rgbImgRb.
function rgbImgRb_Callback(hObject, eventdata, handles)
% hObject    handle to rgbImgRb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rgbImgRb
if get(hObject,'Value')
    set(handles.nSuperpixelEdit, 'Enable', 'on')
    set(handles.regionSizeEdit, 'Enable', 'off')
    set(handles.regularizerEdit, 'Enable', 'off')    
end
    
% --- Executes on button press in hyperImgRb.
function hyperImgRb_Callback(hObject, eventdata, handles)
% hObject    handle to hyperImgRb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hyperImgRb
if get(hObject, 'Value')
    set(handles.regionSizeEdit, 'Enable', 'on')
    set(handles.regularizerEdit, 'Enable', 'on')
    set(handles.nSuperpixelEdit, 'Enable', 'off')
end

function xRateEdit_Callback(hObject, eventdata, handles)
% hObject    handle to xRateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xRateEdit as text
%        str2double(get(hObject,'String')) returns contents of xRateEdit as a double


% --- Executes during object creation, after setting all properties.
function xRateEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xRateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function yRateEdit_Callback(hObject, eventdata, handles)
% hObject    handle to yRateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yRateEdit as text
%        str2double(get(hObject,'String')) returns contents of yRateEdit as a double


% --- Executes during object creation, after setting all properties.
function yRateEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yRateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% 3) ============== Select data source ====================================

% --- Executes on selection change in dataSourcePm.
function dataSourcePm_Callback(hObject, eventdata, handles)
% hObject    handle to dataSourcePm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dataSourcePm contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dataSourcePm


% --- Executes during object creation, after setting all properties.
function dataSourcePm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataSourcePm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% 4) ========= Unmixing computation =======================================

% --- Executes on button press in executePb.
function executePb_Callback(hObject, eventdata, handles)
% hObject    handle to executePb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% Unmixing the data to idenfity the minerals
% Compute the continuum removal of the library

% Load library
A = handles.A;
wavelength = handles.wavelength;
assignin('base', 'wavelength', wavelength)
% Get a data source type
dataSource = get(handles.dataSourcePm, 'Value');

NB = 10;
min_number = 0.001;
A(A<=0) = min_number;

if(dataSource == 1)
    lib_swir = A;
    fprintf('... using reflectance data \n');
elseif(dataSource==2)           % Log10 data
    fprintf('... using log10 of reflectance \n')
    lib_swir = log10(A + 1.0) + eps;
elseif(dataSource==3)           % Continuum removal
    fprintf('... using continuum removal data\n');
    A(A>1) = 1;
    AC = zeros(size(A));        % A is the library
    for i = 1: size(AC,2)
        [AC(:,i), refl_hull, ~] = ContinuumRemovalSeg(wavelength, A(:,i), NB); 
    end
    lib_swir = AC;
end
% ---------------------------------------
fprintf('==============Unmixing the data ==========================\n')
% Get the crop subscripts and resampling rates.
try
    cropSub = handles.cropSub;
    downRate = handles.downRate;
    idx = handles.idx;
    refl = handles.data(cropSub(1):downRate(1):cropSub(2), cropSub(3):downRate(2): cropSub(4), :);
    rgb_imgCrop = handles.rgb_imgCrop;
catch
    msgbox('Please run the previous two steps first', 'Error', 'error')
    return
end
% Get appropriate parameters
Nc = size(refl,2);      % Number of samples (columns)
Nm = size(lib_swir,2);  % Number of spectra in the library
Np = size(refl,1);      % Number of pixels (rows)
Nb = size(refl,3);      % Number of bands

X_hat_2d = zeros(Nm, Nc*Np);
refl_2d = reshape(refl,[Nc*Np,Nb]);
assignin('base', 'refl_2d', refl_2d)

f = waitbar(0,'1','Name','Unmixing progress...',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');

setappdata(f,'canceling',0);

tic
for i = 1: length(idx) %size(refl,1)
    % Check for clicked Cancel button
    if getappdata(f,'canceling')
        break
    end
     % Update waitbar and message
    waitbar(i/length(idx),f,sprintf('%d%% complete',int16(100*i/length(idx))))
    
    % Construct the appropriate data source
    Y = refl_2d(idx{i},:)';
    Y(isnan(Y)) = 0;
    Y(Y<=0) = min_number;
    if (dataSource == 1)        % Reflectance     
        spectra = Y;
    elseif(dataSource==2)       % Log10 data
        Y(Y<=0) = min_number;
        spectra = log10(Y + 1.0) + eps;
    elseif (dataSource==3)      % Continuum removal data
        YC = zeros(size(Y));
        for ii = 1: size(Y,2)
            [YC(:,ii), ~, ~] = ContinuumRemovalSeg(wavelength, Y(:,ii), NB);       
        end 
        spectra = YC;

    end
    % Running unmixing methods
    if (get(handles.fclsRb, 'Value'))           % FCLS method
        if (i == 1)
            fprintf('FCLS unmixing, is running ..., please wait ...\n')
        end
        [temp] = sunsal(lib_swir,spectra,'ADDONE','yes', 'POSITIVITY', 'yes');
    elseif(get(handles.sunsalRb, 'Value'))      % SUnSAL method
        if (i == 1)
            fprintf('SUnSAL unmixing, is running ..., please wait ...\n')
        end
        [temp] = sunsal(lib_swir,spectra,'POSITIVITY','yes','VERBOSE','no','ADDONE','no', ...
                        'lambda', 40e-4,'AL_ITERS',2000, 'TOL', 1e-8);                     
    elseif(get(handles.clsunsalRb, 'Value'))    % CLSUnSAL method
        if (i==1)
            fprintf('CLSUnSAL unmixing, is running ..., please wait ...\n')
        end
        [temp] = clsunsal(lib_swir,spectra,'POSITIVITY','yes','VERBOSE','no','ADDONE','yes', ...
                        'lambda', 40e-4,'AL_ITERS',2000, 'TOL', 1e-8);
    end
    X_hat_2d(:,idx{i}) = temp;  
end
toc
delete(f)
fprintf('Unmixing, finished! \n')
    
% Reshape the unmixing result matrix
X_hat = reshape(X_hat_2d', [Np, Nc, Nm]);
X_hat = (X_hat - min(X_hat(:)))/(max(X_hat(:))-min(X_hat(:)));
handles.X_hat = X_hat;
handles.rgb_imgCrop = rgb_imgCrop;

% Compute the rmse between the reconstruction and reflectance
res = lib_swir*X_hat_2d;
res_rs = reshape(res',[Np, Nc, Nb] );
rmse = sqrt(mean((res_rs - refl).^2, 3));
%figure, imagesc(rmse)
handles.rmse = rmse;


assignin('base', 'X_hat', X_hat)
assignin('base', 'lib_swir', lib_swir)
assignin('base', 'refl', refl)
assignin('base', 'X_hat_2d', X_hat_2d)

% Call callback function to display data
mineralListLb_Callback(handles.mineralListLb, eventdata, handles)

% Update handles
guidata(hObject, handles)


% Save unmixing result
% --- Executes on button press in saveUmPb.
function saveUmPb_Callback(hObject, eventdata, handles)
% hObject    handle to saveUmPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName, pathName, notCancel] = uiputfile('*.mat', 'Specify a file to save unmixing results', 'D:\Matlab\GUI_SOLSA\Results');
if ~notCancel
    msgbox('Specify a correct file path!', 'Error', 'error');
    return
end
try
    fileNamePath = fullfile(pathName, fileName);
    X_hat = handles.X_hat;
    rgb_imgCrop = handles.rgb_imgCrop;
    res = handles.resolution;
    rmse = handles.rmse;
    mineralList = handles.mineralList;
    mineralDict = handles.mineralDict;
    save(fileNamePath, 'X_hat', 'rgb_imgCrop', 'res', 'rmse', 'mineralList', 'mineralDict')
    msgbox('Unmixing results have been save successfully!')
catch
    msgbox('Problem during loading data')
    return
end


% 5) ==================== Displaying unmixing results ===================

% --- Executes on button press in loadUmPb.
function loadUmPb_Callback(hObject, eventdata, handles)
% hObject    handle to loadUmPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName, pathName, oCancel] = uigetfile('*.mat', 'Select a file containing unmixing results', 'D:\Matlab\GUI_SOLSA\Results');
if ~oCancel
    return
end
if exist('mineralDict', 'var')
    clear mineralDict
end
if exist('mineralList', 'var')
    clear mineralList
end
load(fullfile(pathName, fileName))
if exist('mineralDict', 'var')
    handles.mineralDict = mineralDict;
end
if exist('mineralList', 'var')
    handles.mineralList = mineralList;
end

set(handles.unmixingFileST, 'String', fileName)
try
    handles.X_hat = X_hat;
    handles.rgb_imgCrop = rgb_imgCrop;
    handles.resolution = res;
catch
    msgbox('Loaded data are not in the correct format', 'Error', 'error')
    return
end
if exist('rmse', 'var')
    handles.rmse = rmse;
else
    handles.rmse = zeros(size(X_hat,1), size(X_hat,2));
end

% Update handles
guidata(hObject, handles)

% Call callback function to display data
set(handles.mineralListLb, 'Value', length(handles.mineralDict.keys)) % Set the Value parameter of the listbox
set(handles.mineralListLb, 'String', handles.mineralDict.keys)
mineralListLb_Callback(handles.mineralListLb, eventdata, handles)





% --- Executes on selection change in mineralListLb.
function mineralListLb_Callback(hObject, eventdata, handles)
% hObject    handle to mineralListLb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns mineralListLb contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mineralListLb
% The Min and Max properties control the selection mode: If Max-Min>1, then multiple selection is allowed. If Max-Min<=1, then only single selection is allowed.

try
    X_hat = handles.X_hat;
    assignin('base', 'X_hat', X_hat)
    rgb_imgCrop = handles.rgb_imgCrop;
    res = handles.resolution;
catch
    disp('Please load unmixing results first!')
    return
end
listStr = cellstr(get(hObject,'String'));
listVal = get(hObject, 'Value');

% Check if handles.rmse exists
if ~isfield(handles, 'rmse')
    handles.rmse = zeros(size(X_hat,1), size(X_hat,2));
end
    
% Prepare the data for displaying on listbox 
mineralList = handles.mineralList;
assignin('base', 'mineralList', mineralList); % Display a variable in the workspace for debugging
mineralDict = handles.mineralDict;
assignin('base', 'mineralDict', mineralDict);
keySet = mineralDict.keys;      % Mineral name
valueSet = mineralDict.values;  % 
values = valueSet(listVal);
keys = keySet(listVal);

assignin('base', 'values', values)

% Display the first selected mineral on the detail listbox
try
    mineralInd = mineralDict(listStr{listVal(1)});
    set(handles.mineralDetailLb, 'String', mineralList(mineralInd), 'Value', 1);
    handles.mineralInd = mineralInd; % Save variable
catch
    disp('The specified key is not present in the container')
end


% Display unmixing results
f = figure(1);
clf(f)
nPlot = length(listVal) + 2;
subplot (1, nPlot, 1), imagesc(res.x, res.y, rgb_imgCrop), xlabel('mm'), ylabel('mm')
title('False color RGB image')
colorbar
for i = 1: length(listVal)
    libind = values{i};
    libind_chop = libind(libind <=size(X_hat,3));
    subplot(1, nPlot, i+1), imagesc(res.x, res.y, sum(X_hat(:,:,libind_chop),3)), 
    title(keys{i}, 'Interpreter', 'none')
    xlabel('mm')
    %h = colorbar; h.Limits = [0 1];
    colorbar; caxis([0 1])
end
subplot(1, nPlot, nPlot), imagesc(res.x, res.y, handles.rmse),
title('RMSE'),
colorbar;


% Update handles
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function mineralListLb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mineralListLb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%set(hObject, 'Items',{'First','Second','Third'})

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in mineralDetailLb.
function mineralDetailLb_Callback(hObject, eventdata, handles)
% hObject    handle to mineralDetailLb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns mineralDetailLb contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mineralDetailLb

% Load unmixing results
try
    X_hat = handles.X_hat;
    rgb_imgCrop = handles.rgb_imgCrop;
    res = handles.resolution;
catch
    disp('Please load unmixing results first!')
    return
end

listStr = cellstr(get(hObject, 'String'));
listVal = get(hObject, 'Value');
mineralInd = handles.mineralInd;

f = figure(2);
if(length(listVal) == 1)
    clf(f), imagesc(res.x, res.y, X_hat(:,:,mineralInd(listVal))), title(listStr{listVal}, 'Interpreter', 'none')
    h = colorbar; h.Limits = [0 1];
elseif(length(listVal) == 2)
    clf(f)
    subplot 121, imagesc(res.x, res.y, X_hat(:,:,mineralInd(listVal(1)))), title(listStr{listVal(1)}, 'Interpreter', 'none')
    h = colorbar; h.Limits = [0 1];
    subplot 122, imagesc(res.x, res.y, X_hat(:,:,mineralInd(listVal(2)))), title(listStr{listVal(2)}, 'Interpreter', 'none')
    h = colorbar; h.Limits = [0 1];
elseif(length(listVal) <= 4)
    clf(f)
    for i = 1:length(listVal)
        subplot(2,2,i), imagesc(res.x, res.y, X_hat(:,:,mineralInd(listVal(i)))), title(listStr{listVal(i)}, 'Interpreter', 'none')
        h = colorbar; h.Limits = [0 1];
    end
elseif(length(listVal)<=6)
    clf(f)
    for i = 1:length(listVal)
        subplot(2,3,i), imagesc(res.x, res.y, X_hat(:,:,mineralInd(listVal(i)))), title(listStr{listVal(i)}, 'Interpreter', 'none')
        h = colorbar; h.Limits = [0 1];
    end
else
    clf(f), imagesc(res.x, res.y, X_hat(:,:,mineralInd(listVal(1)))), title(listStr{listVal(1)}, 'Interpreter', 'none')
    h = colorbar; h.Limits = [0 1];
end


% --- Executes during object creation, after setting all properties.
function mineralDetailLb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mineralDetailLb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

set(hObject, 'String', ' ');

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in closePb.
function closePb_Callback(hObject, eventdata, handles)
% hObject    handle to closePb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get(handles.output, 'Tag') is the 'Tag' of the GUI
Figures = findobj('Type','Figure','-not','Tag',get(handles.output,'Tag'));
close(Figures)


% --- Executes on slider movement.
function imgSlider_Callback(hObject, eventdata, handles)
% hObject    handle to imgSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
curVal = get(hObject, 'Value');
if curVal <= 0.5
    curVal = curVal*2;
else
    curVal = curVal*4;
end

try
    rgb_img_adj = curVal*handles.rgb_img;
catch 
    msgbox(sprintf('Please load data!'), 'Error', 'error');
    return
end
axes(handles.axes1)
%cla(handles.axes1, 'reset')
imshow(rgb_img_adj); axis on;
handles.rgb_img_adj = rgb_img_adj;

% Update handles
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function imgSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imgSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function abundanceSlider_Callback(hObject, eventdata, handles)
% hObject    handle to abundanceSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
curVal = get(hObject, 'Value');
set(handles.abundanceEdit, 'String', curVal);

try
    X_hat = handles.X_hat;
    rgb_imgCrop = handles.rgb_imgCrop;
    res = handles.resolution;
catch
    disp('Please load unmixing result first!')
    return
end

listStr = cellstr(get(handles.mineralDetailLb, 'String'));
listVal = get(handles.mineralDetailLb, 'Value');
mineralInd = handles.mineralInd;

f = figure(3);
if(length(listVal) == 1)
    clf(f), imagesc(res.x, res.y, X_hat(:,:,mineralInd(listVal)) > curVal), title(sprintf('%s, at %2.2f', listStr{listVal}, curVal), 'Interpreter', 'none')
    h = colorbar; h.Limits = [0 1];
elseif(length(listVal) == 2)
    clf(f)
    subplot 121, imagesc(res.x, res.y, X_hat(:,:,mineralInd(listVal(1))) > curVal), title(sprintf('%s, at %2.2f', listStr{listVal(1)}, curVal), 'Interpreter', 'none')
    h = colorbar; h.Limits = [0 1];
    subplot 122, imagesc(res.x, res.y, X_hat(:,:,mineralInd(listVal(2))) > curVal), title(sprintf('%s, at %2.2f', listStr{listVal(2)}, curVal), 'Interpreter', 'none')
    h = colorbar; h.Limits = [0 1];
elseif(length(listVal) <= 4)
    clf(f)
    for i = 1:length(listVal)
        subplot(2,2,i), imagesc(res.x, res.y, X_hat(:,:,mineralInd(listVal(i)))>curVal), title(sprintf('%s, at %2.2f', listStr{listVal(i)}, curVal), 'Interpreter', 'none')
        h = colorbar; h.Limits = [0 1];
    end
elseif(length(listVal)<=6)
    clf(f)
    for i = 1:length(listVal)
        subplot(2,3,i), imagesc(res.x, res.y, X_hat(:,:,mineralInd(listVal(i)))>curVal), title(sprintf('%s, at %2.2f', listStr{listVal(i)}, curVal), 'Interpreter', 'none')
        h = colorbar; h.Limits = [0 1];
    end
else
    clf(f), imagesc(res.x, res.y, X_hat(:,:,mineralInd(listVal(1))) > curVal), title(sprintf('%s, at %2.2f', listStr{listVal(1)}, curVal), 'Interpreter', 'none')
    h = colorbar; h.Limits = [0 1];
end


% --- Executes during object creation, after setting all properties.
function abundanceSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to abundanceSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function abundanceEdit_Callback(hObject, eventdata, handles)
% hObject    handle to abundanceEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of abundanceEdit as text
%        str2double(get(hObject,'String')) returns contents of abundanceEdit as a double

curVal = str2double(get(hObject, 'String'));
if(curVal >= 0 && curVal <= 1)
    set(handles.abundanceSlider, 'Value', curVal);
else
    msgbox('Value range [0,1]', 'Warning', 'warning')
    return
end
try
    X_hat = handles.X_hat;
    rgb_imgCrop = handles.rgb_imgCrop;
    res = handles.resolution;
catch
    disp('Please load unmixing results first!')
    return
end

listStr = cellstr(get(handles.mineralDetailLb, 'String'));
listVal = get(handles.mineralDetailLb, 'Value');
mineralInd = handles.mineralInd;

f = figure(3);
if(length(listVal) == 1)
    clf(f), imagesc(res.x, res.y, X_hat(:,:,mineralInd(listVal)) > curVal), title(sprintf('%s, at %2.2f', listStr{listVal}, curVal), 'Interpreter', 'none')
    h = colorbar; h.Limits = [0 1];
elseif(length(listVal) == 2)
    clf(f)
    subplot 121, imagesc(res.x, res.y, X_hat(:,:,mineralInd(listVal(1))) > curVal), title(sprintf('%s, at %2.2f', listStr{listVal(1)}, curVal), 'Interpreter', 'none')
    h = colorbar; h.Limits = [0 1];
    subplot 122, imagesc(res.x, res.y, X_hat(:,:,mineralInd(listVal(2))) > curVal), title(sprintf('%s, at %2.2f', listStr{listVal(2)}, curVal), 'Interpreter', 'none')
    h = colorbar; h.Limits = [0 1];
elseif(length(listVal) <= 4)
    clf(f)
    for i = 1:length(listVal)
        subplot(2,2,i), imagesc(res.x, res.y, X_hat(:,:,mineralInd(listVal(i)))>curVal), title(sprintf('%s, at %2.2f', listStr{listVal(i)}, curVal), 'Interpreter', 'none')
        h = colorbar; h.Limits = [0 1];
    end
elseif(length(listVal)<=6)
    clf(f)
    for i = 1:length(listVal)
        subplot(2,3,i), imagesc(res.x, res.y, X_hat(:,:,mineralInd(listVal(i)))>curVal), title(sprintf('%s, at %2.2f', listStr{listVal(i)}, curVal), 'Interpreter', 'none')
        h = colorbar; h.Limits = [0 1];
    end
else
    clf(f), imagesc(res.x, res.y, X_hat(:,:,mineralInd(listVal(1))) > curVal), title(sprintf('%s, at %2.2f', listStr{listVal(1)}, curVal), 'Interpreter', 'none')
    h = colorbar; h.Limits = [0 1];
end

% --- Executes during object creation, after setting all properties.
function abundanceEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to abundanceEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ====================================================
% 6) Change hyperspectral bands to obtain rgb image

% --- Executes on slider movement.
function rSlider_Callback(hObject, eventdata, handles)
% hObject    handle to rSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
try
    wavelength = handles.info.Wavelength;
catch
    return
end

r_wl = min(wavelength) + (max(wavelength) - min(wavelength))*get(hObject, 'Value');
set(handles.rEdit, 'String', r_wl);
handles.r_wl = r_wl;

% Update handles
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function rSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function rEdit_Callback(hObject, eventdata, handles)
% hObject    handle to rEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rEdit as text
%        str2double(get(hObject,'String')) returns contents of rEdit as a double

try
    wavelength = handles.info.Wavelength;
catch
    return
end
r_wl = str2double(get(hObject, 'String'));
if (r_wl >= min(wavelength)) && (r_wl <= max(wavelength))
    handles.r_wl = r_wl;
    r_wl_norm = (r_wl - min(wavelength))/(max(wavelength) - min(wavelength));
    set(handles.rSlider, 'Value', r_wl_norm);
else
    msgbox('Input value out of the wavelength range')
    return
end

% Update handles
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function rEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on slider movement.
function gSlider_Callback(hObject, eventdata, handles)
% hObject    handle to gSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

try
    wavelength = handles.info.Wavelength;
catch
    return
end

g_wl = min(wavelength) + (max(wavelength) - min(wavelength))*get(hObject, 'Value');
set(handles.gEdit, 'String', g_wl);
handles.g_wl = g_wl;

% Update handles
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function gSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function gEdit_Callback(hObject, eventdata, handles)
% hObject    handle to gEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gEdit as text
%        str2double(get(hObject,'String')) returns contents of gEdit as a double

try
    wavelength = handles.info.Wavelength;
catch
    return
end
g_wl = str2double(get(hObject, 'String'));
if (g_wl >= min(wavelength)) && (g_wl <= max(wavelength))
    handles.g_wl = g_wl;
    g_wl_norm = (g_wl - min(wavelength))/(max(wavelength) - min(wavelength));
    set(handles.gSlider, 'Value', g_wl_norm);
else
    msgbox('Input value out of the wavelength range')
    return
end

% Update handles
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function gEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function bSlider_Callback(hObject, eventdata, handles)
% hObject    handle to bSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

try
    wavelength = handles.info.Wavelength;
catch
    return
end

b_wl = min(wavelength) + (max(wavelength) - min(wavelength))*get(hObject, 'Value');
set(handles.bEdit, 'String', b_wl);
handles.b_wl = b_wl;

% Update handles
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function bSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function bEdit_Callback(hObject, eventdata, handles)
% hObject    handle to bEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bEdit as text
%        str2double(get(hObject,'String')) returns contents of bEdit as a double

try
    wavelength = handles.info.Wavelength;
catch
    return
end
b_wl = str2double(get(hObject, 'String'));
if (b_wl >= min(wavelength)) && (b_wl <= max(wavelength))
    handles.b_wl = b_wl;
    b_wl_norm = (b_wl - min(wavelength))/(max(wavelength) - min(wavelength));
    set(handles.bSlider, 'Value', b_wl_norm);
else
    msgbox('Input value out of the wavelength range')
    return
end

% Update handles
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function bEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in updateCbPb.
function updateCbPb_Callback(hObject, eventdata, handles)
% hObject    handle to updateCbPb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    data = handles.data;
    wavelength = handles.info.Wavelength;
    r_wl = handles.r_wl;
    g_wl = handles.g_wl;
    b_wl = handles.b_wl;
catch
    msgbox('Load data first!')
    return
end

rgb_img = hyperspectraldata2rgbimg(data, wavelength, r_wl, g_wl, b_wl);
handles.rgb_img = rgb_img;

axes(handles.axes1);
imshow(rgb_img); axis on

set(handles.imgSlider, 'Value', 0.5);

% Update handles
guidata(hObject, handles)
