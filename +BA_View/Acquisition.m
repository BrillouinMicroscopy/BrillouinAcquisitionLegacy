function handles = Acquisition(parent, model)
%% ACQUISITION View

    % build the GUI
    handles = initGUI(model, parent);
    initView(handles, model);    % populate with initial values

    % observe on model changes and update view accordingly
    % (tie listener to model object lifecycle)
    addlistener(model, 'filename', 'PostSet', ...
        @(o,e) onFilenameChange(handles, e.AffectedObject));
    addlistener(model, 'acquisition', 'PostSet', ...
        @(o,e) onSettingsChange(handles, e.AffectedObject));
end

function handles = initGUI(model, parent)

    start = uicontrol('Parent', parent, 'Style','pushbutton', 'Units', 'normalized',...
        'String','Start','Position',[0.02,0.92,0.1,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left');

    uicontrol('Parent', parent, 'Style', 'text', 'Units', 'normalized', 'String', 'filename:', ...
        'Position', [0.02,0.68,0.08,0.055], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    filename = uicontrol('Parent', parent, 'Style', 'edit', 'Units', 'normalized', ...
        'Position', [0.09,0.69,0.165,0.055], 'FontSize', 11, 'HorizontalAlignment', 'left', 'Tag', 'filenam');
    
    %% Live calibration GUI elements
    liveCalibration = uipanel('Parent', parent, 'Title', 'Live calibration', 'FontSize', 11,...
        'Position', [0.02,0.35,0.235,0.3]);
    
    % post calibration
    postCalibration = uicontrol('Parent', liveCalibration, 'Style', 'checkbox', 'Units', 'normalized', ...
        'Position', [0.05,0.15,0.08,0.08], 'FontSize', 11, 'HorizontalAlignment', 'left', 'Tag', 'postCalibration');
    
    uicontrol('Parent', liveCalibration, 'Style', 'text', 'Units', 'normalized', 'String', 'Post calibration', ...
        'Position', [0.2,0.13,0.78,0.12], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    % continous calibration
    continuousCalibration = uicontrol('Parent', liveCalibration, 'Style', 'checkbox', 'Units', 'normalized', ...
        'Position', [0.05,0.32,0.08,0.08], 'FontSize', 11, 'HorizontalAlignment', 'left', 'Tag', 'continuousCalibration');
    
    uicontrol('Parent', liveCalibration, 'Style', 'text', 'Units', 'normalized', 'String', 'Calibrate every', ...
        'Position', [0.2,0.30,0.78,0.12], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    continuousCalibrationTime = uicontrol('Parent', liveCalibration, 'Style', 'edit', 'Units', 'normalized', ...
        'String', model.acquisition.continuousCalibrationTime, ...
        'Position', [0.69,0.30,0.15,0.12], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'continuousCalibrationTime');
    
    uicontrol('Parent', liveCalibration, 'Style', 'text', 'Units', 'normalized', 'String', 'min', ...
        'Position', [0.85,0.30,0.13,0.12], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    % pre calibration
    preCalibration = uicontrol('Parent', liveCalibration, 'Style', 'checkbox', 'Units', 'normalized', ...
        'Position', [0.05,0.49,0.08,0.08], 'FontSize', 11, 'HorizontalAlignment', 'left', 'Tag', 'preCalibration');
    
    uicontrol('Parent', liveCalibration, 'Style', 'text', 'Units', 'normalized', 'String', 'Pre calibration', ...
        'Position', [0.2,0.47,0.78,0.12], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    % number of images
    uicontrol('Parent', liveCalibration, 'Style', 'text', 'Units', 'normalized', 'String', 'Number of images:', ...
        'Position', [0.05,0.64,0.7,0.12], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    nrCalibrationImages = uicontrol('Parent', liveCalibration, 'Style', 'edit', 'Units', 'normalized', 'String', model.acquisition.nrCalibrationImages, ...
        'Position', [0.81,0.64,0.15,0.12], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'nrCalibrationImages');
    
    % sample type
    uicontrol('Parent', liveCalibration, 'Style', 'text', 'Units', 'normalized', 'String', 'Sample:', ...
        'Position', [0.05,0.81,0.3,0.12], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    calibrationSample = uicontrol('Parent', liveCalibration, 'Style','popup', 'Units', 'normalized','Position',[0.4,0.83,0.56,0.12],...
        'String',model.calibration.samples(2:end),'FontSize', 11, 'HorizontalAlignment', 'left', 'Tag', 'calibrationSample');
    
    calibrationProgressBar = javax.swing.JProgressBar;
    javacomponent(calibrationProgressBar,[0,1,208,20],liveCalibration);
    calibrationProgressBar.setValue(0);
    calibrationProgressBar.setStringPainted(true);
    calibrationProgressBar.setString('Time to next calibration.');
    
    %% continous measurment GUI
    contmeasure = uipanel('Parent', parent, 'Title', 'Continuous Measurements', 'FontSize', 11,...
        'Position', [0.02,0.75,0.235,0.15]);
    % number of measurments
    uicontrol('Parent', contmeasure, 'Style', 'text', 'Units', 'normalized', 'String', 'Number of measurements:', ...
        'Position', [0.05,0.55,0.7,0.5], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    numberMeasurements = uicontrol('Parent', contmeasure, 'Style', 'edit', 'Units', 'normalized', 'String', model.acquisition.numberMeasurements, ...
        'Position', [0.81,0.55,0.15,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'numberMeasurements');
    % time
    uicontrol('Parent', contmeasure, 'Style', 'text', 'Units', 'normalized', 'String', 'Time [min]:', ...
        'Position', [0.05,0.2,0.7,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    timeBetweenMeasurements = uicontrol('Parent', contmeasure, 'Style', 'edit', 'Units', 'normalized', 'String', model.acquisition.timeBetweenMeasurements, ...
        'Position', [0.81,0.2,0.15,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'timeBetweenMeasurements');
    
    %%
    uicontrol('Parent', parent, 'Style', 'text', 'Units', 'normalized', 'String', 'x/�m', ...
    'Position', [0.04,0.18,0.04,0.035], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    posX = uicontrol('Parent', parent, 'Style', 'edit', 'Units', 'normalized', 'String', '0', ...
        'Position', [0.02,0.14,0.077,0.035], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'floor', 'enable', 'off');

    uicontrol('Parent', parent, 'Style', 'text', 'Units', 'normalized', 'String', 'y/�m', ...
    'Position', [0.115,0.18,0.09,0.035], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    posY = uicontrol('Parent', parent, 'Style', 'edit', 'Units', 'normalized', 'String', '0', ...
        'Position', [0.0975,0.14,0.077,0.035], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'floor', 'enable', 'off');

    uicontrol('Parent', parent, 'Style', 'text', 'Units', 'normalized', 'String', 'z/�m', ...
    'Position', [0.195,0.18,0.09,0.035], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    posZ = uicontrol('Parent', parent, 'Style', 'edit', 'Units', 'normalized', 'String', '0', ...
        'Position', [0.1755,0.14,0.077,0.035], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'floor', 'enable', 'off');
    
    uicontrol('Parent', parent, 'Style', 'text', 'Units', 'normalized', 'String', 'Image', ...
        'Position', [0.02,0.09,0.15,0.035], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    imgNr = uicontrol('Parent', parent, 'Style', 'edit', 'Units', 'normalized', 'String', '0', ...
        'Position', [0.0975,0.09,0.077,0.035], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'floor', 'enable', 'off');
    
    progressBar = javax.swing.JProgressBar;
    javacomponent(progressBar,[19,20,208,30],parent);
    progressBar.setValue(0);
    progressBar.setStringPainted(true);
    progressBar.setString('Acquisition stopped.');

    zoomIn = uicontrol('Parent', parent, 'Style','pushbutton', 'Units', 'normalized',...
        'String', model.sharedFunctions.iconString([model.pp '/images/zoomin.png']), 'Position',[0.33,0.92,0.0375,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left');
    set(zoomIn, 'UserData', 0);
    
    zoomOut = uicontrol('Parent', parent, 'Style','pushbutton', 'Units', 'normalized',...
        'String', model.sharedFunctions.iconString([model.pp '/images/zoomout.png']), 'Position',[0.375,0.92,0.0375,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left');
    set(zoomOut, 'UserData', 0);
    
    panButton = uicontrol('Parent', parent, 'Style','pushbutton', 'Units', 'normalized',...
        'String', model.sharedFunctions.iconString([model.pp '/images/pan.png']), 'Position',[0.42,0.92,0.0375,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left');
    set(panButton, 'UserData', 0);

    uicontrol('Parent', parent, 'Style', 'text', 'String', 'Autoscale', 'Units', 'normalized',...
        'Position', [0.48,0.928,0.1,0.035], 'FontSize', 10, 'HorizontalAlignment', 'left');

    autoscale = uicontrol('Parent', parent, 'Style', 'checkbox', 'Units', 'normalized',...
        'Position', [0.55,0.93,0.017,0.034], 'FontSize', 11, 'HorizontalAlignment', 'left');

    uicontrol('Parent', parent, 'Style', 'text', 'String', 'Floor', 'Units', 'normalized',...
        'Position', [0.60,0.91,0.1,0.055], 'FontSize', 11, 'HorizontalAlignment', 'left');

    floor = uicontrol('Parent', parent, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.92,0.075,0.055], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'floor');

    increaseFloor = uicontrol('Parent', parent, 'Style','pushbutton', 'Units', 'normalized',...
        'String', model.sharedFunctions.iconString([model.pp '/images/up.png']), 'Position',[0.74,0.9475,0.0325,0.0275],...
        'FontSize', 11, 'HorizontalAlignment', 'left', 'Tag', 'floor');

    decreaseFloor = uicontrol('Parent', parent, 'Style','pushbutton', 'Units', 'normalized',...
        'String', model.sharedFunctions.iconString([model.pp '/images/down.png']), 'Position',[0.74,0.92,0.0325,0.0275],...
        'FontSize', 11, 'HorizontalAlignment', 'left', 'Tag', 'floor');

    uicontrol('Parent', parent, 'Style', 'text', 'String', 'Cap', 'Units', 'normalized',...
        'Position', [0.79,0.91,0.1,0.055], 'FontSize', 11, 'HorizontalAlignment', 'left');

    cap = uicontrol('Parent', parent, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.83,0.92,0.075,0.055], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'cap');

    increaseCap = uicontrol('Parent', parent, 'Style','pushbutton', 'Units', 'normalized',...
        'String', model.sharedFunctions.iconString([model.pp '/images/up.png']), 'Position',[0.92,0.9475,0.0325,0.0275],...
        'FontSize', 11, 'HorizontalAlignment', 'left', 'Tag', 'cap');

    decreaseCap = uicontrol('Parent', parent, 'Style','pushbutton', 'Units', 'normalized',...
        'String', model.sharedFunctions.iconString([model.pp '/images/down.png']), 'Position',[0.92,0.92,0.0325,0.0275],...
        'FontSize', 11, 'HorizontalAlignment', 'left', 'Tag', 'cap');
    
    axesCamera = axes('Parent', parent, 'Position', [0.33 .085 .65 .82]);
    imageCamera = imagesc(axesCamera, flipud(model.settings.andor.image));
    set(axesCamera, 'box', 'on');
    xlabel(axesCamera, '$x$ [pix]', 'interpreter', 'latex');
    ylabel(axesCamera, '$y$ [pix]', 'interpreter', 'latex');
    zoom(gcf,'reset');
    zoomHandle = zoom;
    panHandle = pan;
    colorbar(axesCamera);
    
    %% Return handles
    handles = struct(...
        'start', start, ...
        'axesCamera', axesCamera, ...
        'imageCamera', imageCamera, ...
        'zoomHandle', zoomHandle, ...
        'filename', filename, ...
        'autoscale', autoscale, ...
        'cap', cap, ...
        'floor', floor, ...
        'increaseCap', increaseCap, ...
        'decreaseCap', decreaseCap, ...
        'increaseFloor', increaseFloor, ...
        'decreaseFloor', decreaseFloor, ...
        'zoomIn', zoomIn, ...
        'zoomOut', zoomOut, ...
        'panButton', panButton, ...
        'panHandle', panHandle, ...
        'progressBar', progressBar, ...
        'posX', posX, ...
        'posY', posY, ...
        'posZ', posZ, ...
        'imgNr', imgNr, ...
        'postCalibration', postCalibration, ...
        'continuousCalibration', continuousCalibration, ...
        'preCalibration', preCalibration, ...
        'nrCalibrationImages', nrCalibrationImages, ...
        'continuousCalibrationTime', continuousCalibrationTime, ...
        'calibrationSample', calibrationSample, ...
        'calibrationProgressBar', calibrationProgressBar, ...
        'numberMeasurements', numberMeasurements, ...
        'timeBetweenMeasurements', timeBetweenMeasurements ...
	);
end

function initView(handles, model)
%% Initialize the view
    onFilenameChange(handles, model)
    onSettingsChange(handles, model)
end

function onFilenameChange(handles, model)
    set(handles.filename, 'String', [model.filename '.h5']);
end

function onSettingsChange(handles, model)
    set(handles.autoscale, 'Value', model.acquisition.autoscale);
    set(handles.cap, 'String', model.acquisition.cap);
    set(handles.floor, 'String', model.acquisition.floor);
    if ~isnan(model.acquisition.image)
        imagesc(handles.axesCamera, flipud(model.acquisition.image));
    end
    if model.acquisition.autoscale
        caxis(handles.axesCamera,'auto');
    else
        caxis(handles.axesCamera,[model.acquisition.floor model.acquisition.cap]);
    end
    if model.acquisition.acquisition
        set(handles.start, 'String', 'Stop');
    else
        set(handles.start, 'String', 'Start');
    end
    %% set live calibration parameters
    set(handles.calibrationSample, 'Value', model.acquisition.calibrationSample);
    set(handles.preCalibration, 'Value', model.acquisition.preCalibration);
    set(handles.postCalibration, 'Value', model.acquisition.postCalibration);
    set(handles.continuousCalibration, 'Value', model.acquisition.continuousCalibration);
    set(handles.continuousCalibrationTime, 'Value', model.acquisition.continuousCalibrationTime);
end