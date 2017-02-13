function handles = Configuration(parent, model)
%% CONFIGURATION View

    % build the GUI
    handles = initGUI(parent, model);
    initView(handles, model);    % populate with initial values

    % observe on model changes and update view accordingly
    % (tie listener to model object lifecycle)
    addlistener(model, 'settings', 'PostSet', ...
        @(o,e) onSettingsChange(handles, e.AffectedObject));
    addlistener(model, 'andor', 'PostSet', ...
        @(o,e) onConnectionChange(handles, e.AffectedObject));
    addlistener(model, 'cooling', 'PostSet', ...
        @(o,e) onCoolingChange(handles, e.AffectedObject));
    addlistener(model, 'zeiss', 'PostSet', ...
        @(o,e) onConnectionChange(handles, e.AffectedObject));
end

function handles = initGUI(parent, model)
    %% Save and load settings panel
    general = uipanel('Parent', parent, 'Title', 'General', 'FontSize', 11,...
        'Position', [.02 .02 .96 .09]);

    save = uicontrol('Parent', general, 'Style','pushbutton', 'Units', 'normalized',...
        'String','Save settings','Position',[0.634,0.15,0.17,0.85],...
        'FontSize', 11, 'HorizontalAlignment', 'left');

    load = uicontrol('Parent', general, 'Style','pushbutton', 'Units', 'normalized',...
        'String','Load settings','Position',[0.816,0.15,0.17,0.85],...
        'FontSize', 11, 'HorizontalAlignment', 'left');

    %% Microscope panel
    microscope = uipanel('Parent', parent, 'Title', 'Microscope – Scanning', 'FontSize', 11,...
        'Position', [.02 .11 .47 .87]);

    stages = uicontrol('Parent', microscope, 'Style','popup', 'Units', 'normalized','Position',[0.03,0.935,0.32,0.055],...
        'String',model.settings.zeiss.stages,'FontSize', 11, 'HorizontalAlignment', 'left');

    connectStage = uicontrol('Parent', microscope, 'Style','pushbutton', 'Units', 'normalized',...
        'String','Disconnected','Position',[0.72,0.94,0.25,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left', 'BackgroundColor', 'red');

%     disconnectStage = uicontrol('Parent', microscope, 'Style','pushbutton', 'Units', 'normalized',...
%         'String','Disconnect','Position',[0.56,0.94,0.2,0.055],...
%         'FontSize', 11, 'HorizontalAlignment', 'left', 'BackgroundColor', 'red');

    select = uicontrol('Parent', microscope, 'Style','pushbutton', 'Units', 'normalized',...
        'String','Select ROI','Position',[0.72,0.94,0.25,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left');

    %% x-direction
    x = uipanel('Parent', microscope, 'Title', 'x-direction', 'FontSize', 11,...
        'Position', [.03 .71 .3 .225]);

    startXlabel = uicontrol('Parent', x, 'Style', 'text', 'Units', 'normalized',...
        'Position', [0.05,0.65,0.96,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');

    startX = uicontrol('Parent', x, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.69,0.30,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'startX');

    widthXlabel = uicontrol('Parent', x, 'Style', 'text', 'Units', 'normalized',...
        'Position', [0.05,0.35,0.96,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');

    widthX = uicontrol('Parent', x, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.39,0.30,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'widthX');

    uicontrol('Parent', x, 'Style', 'text', 'String', 'Resolution', 'Units', 'normalized',...
        'Position', [0.05,0.05,0.6,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');

    resX = uicontrol('Parent', x, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.09,0.30,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'resX');

    %% y-direction
    y = uipanel('Parent', microscope, 'Title', 'y-direction', 'FontSize', 11,...
        'Position', [.35 .71 .3 .225]);

    startYlabel = uicontrol('Parent', y, 'Style', 'text', 'Units', 'normalized',...
        'Position', [0.05,0.65,0.96,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');

    startY = uicontrol('Parent', y, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.69,0.30,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'startY');

    widthYlabel = uicontrol('Parent', y, 'Style', 'text', 'Units', 'normalized',...
        'Position', [0.05,0.35,0.96,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');

    widthY = uicontrol('Parent', y, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.39,0.30,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'widthY');

    uicontrol('Parent', y, 'Style', 'text', 'String', 'Resolution', 'Units', 'normalized',...
        'Position', [0.05,0.05,0.6,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');

    resY = uicontrol('Parent', y, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.09,0.30,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'resY');

    %% z-direction
    z = uipanel('Parent', microscope, 'Title', 'z-direction', 'FontSize', 11,...
        'Position', [.67 .71 .3 .225]);

    startZlabel = uicontrol('Parent', z, 'Style', 'text', 'Units', 'normalized',...
        'Position', [0.05,0.65,0.96,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');

    startZ = uicontrol('Parent', z, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.69,0.30,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'startZ');

    widthZlabel = uicontrol('Parent', z, 'Style', 'text', 'Units', 'normalized',...
        'Position', [0.05,0.35,0.96,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');

    widthZ = uicontrol('Parent', z, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.39,0.30,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'widthZ');

    uicontrol('Parent', z, 'Style', 'text', 'String', 'Resolution', 'Units', 'normalized',...
        'Position', [0.05,0.05,0.6,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');

    resZ = uicontrol('Parent', z, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.09,0.30,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'resZ');

    set(findall(z, '-property', 'enable'), 'enable', 'off');

    uicontrol('Parent', microscope, 'Style', 'text', 'String', 'Presets', 'Units', 'normalized',...
    'Position', [0.05,0.63,0.2,0.055], 'FontSize', 11, 'HorizontalAlignment', 'left', 'Tag', 'ElementsLabel', 'Enable', 'off');
    pre = fieldnames(model.settings.zeiss.presets);
    presetButtons = NaN(1,length(pre));
    for jj = 1:length(pre)
        presetButtons(jj) = uicontrol('Parent', microscope, 'Style','pushbutton', 'Units', 'normalized',...
            'String',model.settings.zeiss.presets.(pre{jj}).name,'Position',[0.27+(jj-1)*0.21,0.64,0.2,0.055], 'Tag', pre{jj}, ...
            'FontSize', 11, 'HorizontalAlignment', 'left', 'enable', 'off');
    end

    elems = {'reflector', 'objective', 'tubelens', 'baseport', 'sideport', 'mirror'};
    elementshandles = struct();
    for ii = 1:length(elems)
        uicontrol('Parent', microscope, 'Style', 'text', 'Units', 'normalized','String',elems{ii},...
            'Position', [0.05,0.54-(ii-1)*0.07,0.3,0.055], 'FontSize', 11, 'HorizontalAlignment', 'left', 'Tag', 'ElementsLabel', 'Enable', 'off');
        opt = model.settings.zeiss.([elems{ii} 's']);
        hndls = NaN(1,length(opt));
        for jj = 1:length(opt)
            hndls(jj) = uicontrol('Parent', microscope, 'Style','pushbutton', 'Units', 'normalized',...
                'String',opt{jj},'Position',[0.27+(jj-1)*0.08,0.55-(ii-1)*0.07,0.07,0.055],...
                'FontSize', 11, 'HorizontalAlignment', 'left', 'Tag', 'ElementsPosition', 'Enable', 'off');
        end
        elementshandles.(elems{ii}) =  hndls;
    end

    %% screenshot
    screen = axes('Parent', microscope, 'Position', [0.12 .085 .85 .6]);
    hold on;
    set(screen, 'box', 'on');
    xlabel(screen, '$x$ [pix]', 'interpreter', 'latex');
    ylabel(screen, '$y$ [pix]', 'interpreter', 'latex');

    %% Camera panel
    camera = uipanel('Parent', parent, 'Title', 'Camera', 'FontSize', 11,...
        'Position', [.51 .11 .47 .87]);

    connectCamera = uicontrol('Parent', camera, 'Style','pushbutton', 'Units', 'normalized',...
        'String','Disconnected','Position',[0.02,0.94,0.25,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left', 'BackgroundColor', 'red');

    cooling = uicontrol('Parent', camera, 'Style','pushbutton', 'Units', 'normalized',...
        'String','Cooler Off','Position',[0.28,0.94,0.24,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left', 'BackgroundColor', 'red');

    update = uicontrol('Parent', camera, 'Style','pushbutton', 'Units', 'normalized',...
        'String', model.sharedFunctions.iconString([model.pp '/images/update.png']), 'Position',[0.74,0.94,0.11,0.055], ...
        'FontSize', 11, 'HorizontalAlignment', 'left', 'enable', 'off');

    play = uicontrol('Parent', camera, 'Style','pushbutton', 'Units', 'normalized',...
        'String', model.sharedFunctions.iconString([model.pp '/images/play.png']), 'Position',[0.86,0.94,0.11,0.055], ...
        'FontSize', 11, 'HorizontalAlignment', 'left', 'enable', 'off');

    %% x-direction
    x_camera = uipanel('Parent', camera, 'Title', 'x-direction', 'FontSize', 11,...
        'Position', [.35 .775 .3 .160]);

    uicontrol('Parent', x_camera, 'Style', 'text', 'String', 'Start', 'Units', 'normalized',...
        'Position', [0.05,0.48,0.56,0.37], 'FontSize', 11, 'HorizontalAlignment', 'left');

    startX_camera = uicontrol('Parent', x_camera, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.53,0.30,0.37], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'startX');

    uicontrol('Parent', x_camera, 'Style', 'text', 'String', 'Width', 'Units', 'normalized',...
        'Position', [0.05,0.02,0.56,0.37], 'FontSize', 11, 'HorizontalAlignment', 'left');

    widthX_camera = uicontrol('Parent', x_camera, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.08,0.30,0.37], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'widthX');

    %% y-direction
    y_camera = uipanel('Parent', camera, 'Title', 'y-direction', 'FontSize', 11,...
        'Position', [.67 .775 .3 .160]);

    uicontrol('Parent', y_camera, 'Style', 'text', 'String', 'Start', 'Units', 'normalized',...
        'Position', [0.05,0.48,0.56,0.37], 'FontSize', 11, 'HorizontalAlignment', 'left');

    startY_camera = uicontrol('Parent', y_camera, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.53,0.30,0.37], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'startY');

    uicontrol('Parent', y_camera, 'Style', 'text', 'String', 'Width', 'Units', 'normalized',...
        'Position', [0.05,0.02,0.56,0.37], 'FontSize', 11, 'HorizontalAlignment', 'left');

    widthY_camera = uicontrol('Parent', y_camera, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.08,0.30,0.37], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'widthY');

    parameters_camera = uipanel('Parent', camera, 'Title', 'Parameters', 'FontSize', 11,...
        'Position', [.03 .775 .3 .160]);

    uicontrol('Parent', parameters_camera, 'Style', 'text', 'String', 'Exposure', 'Units', 'normalized',...
        'Position', [0.05,0.48,0.56,0.37], 'FontSize', 11, 'HorizontalAlignment', 'left');

    exp = uicontrol('Parent', parameters_camera, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.53,0.30,0.37], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'exp');

    uicontrol('Parent', parameters_camera, 'Style', 'text', 'String', 'Images', 'Units', 'normalized',...
        'Position', [0.05,0.02,0.56,0.37], 'FontSize', 11, 'HorizontalAlignment', 'left');

    nr = uicontrol('Parent', parameters_camera, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.08,0.30,0.37], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'nr');

    zoomIn = uicontrol('Parent', camera, 'Style','pushbutton', 'Units', 'normalized',...
        'String', model.sharedFunctions.iconString([model.pp '/images/zoomin.png']), 'Position',[0.03,0.71,0.075,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left');
    set(zoomIn, 'UserData', 0);

    zoomOut = uicontrol('Parent', camera, 'Style','pushbutton', 'Units', 'normalized',...
        'String', model.sharedFunctions.iconString([model.pp '/images/zoomout.png']), 'Position',[0.11,0.71,0.075,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left');
    set(zoomOut, 'UserData', 0);

    panButton = uicontrol('Parent', camera, 'Style','pushbutton', 'Units', 'normalized',...
        'String', model.sharedFunctions.iconString([model.pp '/images/pan.png']), 'Position',[0.19,0.71,0.075,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left');
    set(panButton, 'UserData', 0);

    uicontrol('Parent', camera, 'Style', 'text', 'String', 'Auto', 'Units', 'normalized',...
        'Position', [0.30,0.70,0.15,0.055], 'FontSize', 10, 'HorizontalAlignment', 'left');

    autoscale = uicontrol('Parent', camera, 'Style', 'checkbox', 'Units', 'normalized',...
        'Position', [0.37,0.72,0.034,0.034], 'FontSize', 11, 'HorizontalAlignment', 'left');

    uicontrol('Parent', camera, 'Style', 'text', 'String', 'Floor', 'Units', 'normalized',...
        'Position', [0.425,0.70,0.2,0.055], 'FontSize', 10, 'HorizontalAlignment', 'left');

    floor = uicontrol('Parent', camera, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.505,0.71,0.09,0.055], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'floor');

    increaseFloor = uicontrol('Parent', camera, 'Style','pushbutton', 'Units', 'normalized',...
        'String', model.sharedFunctions.iconString([model.pp '/images/up.png']), 'Position',[0.60,0.7375,0.065,0.0275],...
        'FontSize', 11, 'HorizontalAlignment', 'left', 'Tag', 'floor');

    decreaseFloor = uicontrol('Parent', camera, 'Style','pushbutton', 'Units', 'normalized',...
        'String', model.sharedFunctions.iconString([model.pp '/images/down.png']), 'Position',[0.60,0.71,0.065,0.0275],...
        'FontSize', 11, 'HorizontalAlignment', 'left', 'Tag', 'floor');

    uicontrol('Parent', camera, 'Style', 'text', 'String', 'Cap', 'Units', 'normalized',...
        'Position', [0.675,0.70,0.2,0.055], 'FontSize', 10, 'HorizontalAlignment', 'left');

    cap = uicontrol('Parent', camera, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.74,0.71,0.09,0.055], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'cap');

    increaseCap = uicontrol('Parent', camera, 'Style','pushbutton', 'Units', 'normalized',...
        'String', model.sharedFunctions.iconString([model.pp '/images/up.png']), 'Position',[0.8350,0.7375,0.065,0.0275],...
        'FontSize', 11, 'HorizontalAlignment', 'left', 'Tag', 'cap');

    decreaseCap = uicontrol('Parent', camera, 'Style','pushbutton', 'Units', 'normalized',...
        'String', model.sharedFunctions.iconString([model.pp '/images/down.png']), 'Position',[0.8350,0.71,0.065,0.0275],...
        'FontSize', 11, 'HorizontalAlignment', 'left', 'Tag', 'cap');

    externalFigure = uicontrol('Parent', camera, 'Style','pushbutton', 'Units', 'normalized',...
        'String', model.sharedFunctions.iconString([model.pp '/images/fullscreen.png']), 'Position',[0.905,0.71,0.065,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left');

    axesCamera = axes('Parent', camera, 'Position', [0.12 .085 .85 .6]);
    imageCamera = imagesc(axesCamera, flipud(model.settings.andor.image));
    set(axesCamera, 'box', 'on');
    xlabel(axesCamera, '$x$ [pix]', 'interpreter', 'latex');
    ylabel(axesCamera, '$y$ [pix]', 'interpreter', 'latex');
    zoom(gcf,'reset')
    zoomHandle = zoom;
    panHandle = pan;
    axis(axesCamera, [model.settings.andor.startX ...
        model.settings.andor.startX + model.settings.andor.widthX ...
        model.settings.andor.startY ...
        model.settings.andor.startY + model.settings.andor.widthY]);
    caxis([model.settings.andor.floor model.settings.andor.cap]);
    colorbar;

    %% Return handles
    handles = struct(...
        'parent', parent, ...
        'save', save, ...
        'load', load, ...
        'microscope', microscope, ...
        'connectStage',  connectStage, ...
        'select',   select, ...
        'camera',   camera, ...
        'connect',  connectCamera, ...
        'cooling', cooling, ...
        'resX', resX, ...
        'resY', resY, ...
        'resZ', resZ, ...
        'startX', startX, ...
        'startY', startY, ...
        'startZ', startZ, ...
        'startXlabel', startXlabel, ...
        'startYlabel', startYlabel, ...
        'startZlabel', startZlabel, ...
        'widthX', widthX, ...
        'widthY', widthY, ...
        'widthZ', widthZ, ...
        'widthXlabel', widthXlabel, ...
        'widthYlabel', widthYlabel, ...
        'widthZlabel', widthZlabel, ...
        'z', z, ...
        'presetButtons', presetButtons, ...
        'elements', elementshandles, ...
        'screen', screen, ...
        'startX_camera', startX_camera, ...
        'startY_camera', startY_camera, ...
        'widthX_camera', widthX_camera, ...
        'widthY_camera', widthY_camera, ...
        'play', play, ...
        'update', update, ...
        'exp', exp, ...
        'nr', nr, ...
        'autoscale', autoscale, ...
        'cap', cap, ...
        'increaseCap', increaseCap, ...
        'decreaseCap', decreaseCap, ...
        'increaseFloor', increaseFloor, ...
        'decreaseFloor', decreaseFloor, ...
        'floor', floor, ...
        'externalFigure', externalFigure, ...
        'axesCamera', axesCamera, ...
        'imageCamera', imageCamera, ...
        'zoomIn', zoomIn, ...
        'zoomOut', zoomOut, ...
        'zoomHandle', zoomHandle, ...
        'panButton', panButton, ...
        'panHandle', panHandle, ...
        'stages', stages ...
	);
end

function initView(handles, model)
%% Initialize the view
    onSettingsChange(handles, model);
end

function onConnectionChange(handles, model)
    if isa(model.andor,'BA_Utils.AndorControl.AndorControl') && isvalid(model.andor)
        set(handles.connect, 'BackgroundColor', 'green', 'String', 'Connected');
        set(handles.update, 'enable', 'on');
        set(handles.play, 'enable', 'on');
    else
        set(handles.connect, 'BackgroundColor', 'red', 'String', 'Disconnected');
        set(handles.update, 'enable', 'off');
        set(handles.play, 'enable', 'off');
%         set(handles.cooling, 'String', model.andor.SensorTemperatureStatus);
    end
    if isa(model.zeiss,'BA_Utils.ScanControl.ScanControl') && isvalid(model.zeiss)
        set(handles.connectStage, 'BackgroundColor', 'green', 'String', 'Connected');
        for jj = 1:length(handles.presetButtons)
            set(handles.presetButtons(jj), 'Enable', 'on');
        end
        set(findall(handles.parent, '-property', 'enable', 'Tag', 'ElementsLabel'), 'enable', 'on');
        set(findall(handles.parent, '-property', 'enable', 'Tag', 'ElementsPosition'), 'enable', 'on');
    else
        set(handles.connectStage, 'BackgroundColor', 'red', 'String', 'Disconnected');
        for jj = 1:length(handles.presetButtons)
            set(handles.presetButtons(jj), 'Enable', 'off');
            set(handles.presetButtons(jj), 'BackgroundColor', [0.94 0.94 0.94]);
        end
        set(findall(handles.parent, '-property', 'enable', 'Tag', 'ElementsLabel'), 'enable', 'off');
        set(findall(handles.parent, '-property', 'enable', 'Tag', 'ElementsPosition'), 'enable', 'off');
        set(findall(handles.parent, '-property', 'BackgroundColor', 'Tag', 'ElementsPosition'), 'BackgroundColor', [0.94 0.94 0.94]);
    end
end

function onCoolingChange(handles, model)
    set(handles.cooling, 'String', model.cooling.SensorTemperatureStatus);
    switch model.cooling.SensorTemperatureStatus
        case 'Cooler Off'
            set(handles.cooling, 'BackgroundColor', 'red');
        case 'Fault'
            set(handles.cooling, 'BackgroundColor', 'red');
        case 'Cooling'
            set(handles.cooling, 'BackgroundColor', [0.9290 0.6940 0.1250]);
        case 'Drift'
            set(handles.cooling, 'BackgroundColor', [0.9290 0.6940 0.1250]);
        case 'Not Stabilised'
            set(handles.cooling, 'BackgroundColor', [0 0.4470 0.7410]);
        case 'Stabilised'
            set(handles.cooling, 'BackgroundColor', 'green');
    end
end

function onSettingsChange(handles, model)
    %% Microscope settings

    switch model.settings.zeiss.stage
        case 'Scanning Mirrors'
            set(handles.stages,'Value',1);
            set(handles.connectStage, 'Visible', 'off');
            for jj = 1:length(handles.presetButtons)
                set(handles.presetButtons(jj), 'Visible', 'off');
            end
            set(findall(handles.z, '-property', 'enable'), 'enable', 'off');
            set(findall(handles.parent, '-property', 'Visible', 'Tag', 'ElementsLabel'), 'Visible', 'off');
            set(findall(handles.parent, '-property', 'Visible', 'Tag', 'ElementsPosition'), 'Visible', 'off');
            set(handles.startXlabel, 'String', 'Start [px]');
            set(handles.startYlabel, 'String', 'Start [px]');
            set(handles.startZlabel, 'String', 'Start [px]');
            set(handles.widthXlabel, 'String', 'Width [px]');
            set(handles.widthYlabel, 'String', 'Width [px]');
            set(handles.widthZlabel, 'String', 'Width [px]');
            set(handles.select, 'Visible', 'on');
            set(handles.screen, 'Visible', 'on');
        case 'Translation Stage'
            set(handles.stages,'Value',2);
            set(handles.select, 'Visible', 'off');
            set(handles.screen, 'Visible', 'off');
            set(findall(handles.parent, '-property', 'Visible', 'Tag', 'ElementsLabel'), 'Visible', 'on');
            set(findall(handles.parent, '-property', 'Visible', 'Tag', 'ElementsPosition'), 'Visible', 'on');
            set(handles.startXlabel, 'String', 'Start [µm]');
            set(handles.startYlabel, 'String', 'Start [µm]');
            set(handles.startZlabel, 'String', 'Start [µm]');
            set(handles.widthXlabel, 'String', 'Width [µm]');
            set(handles.widthYlabel, 'String', 'Width [µm]');
            set(handles.widthZlabel, 'String', 'Width [µm]');
            set(handles.connectStage, 'Visible', 'on');
            set(findall(handles.z, '-property', 'enable'), 'enable', 'on');
            set(findall(handles.parent, '-property', 'BackgroundColor', 'Tag', 'ElementsPosition'), 'BackgroundColor', [0.94 0.94 0.94]);
            if isa(model.zeiss,'BA_Utils.ScanControl.ScanControl') && isvalid(model.zeiss)
                elements = {'reflector', 'objective', 'tubelens', 'baseport', 'sideport', 'mirror'};
                for jj = 1:length(handles.presetButtons)
                    set(handles.presetButtons(jj), 'Visible', 'on');
                    pre = get(handles.presetButtons(jj), 'Tag');
                    for ii = 1:length(elements)
                        if model.settings.zeiss.(elements{ii}) ~= model.settings.zeiss.presets.(pre).(elements{ii})
                            set(handles.presetButtons(jj), 'BackgroundColor', [0.94 0.94 0.94]);
                            break;
                        else
                            set(handles.presetButtons(jj), 'BackgroundColor', [66, 134, 244]/255);
                        end
                    end
                end
                elems = {'reflector', 'objective', 'tubelens', 'baseport', 'sideport', 'mirror'};
                for ii = 1:length(elems)
                    val = model.settings.zeiss.(elems{ii});
                    hndl = handles.elements.(elems{ii})(val);
                    set(hndl, 'BackgroundColor', [66, 134, 244]/255);
                end
            end
    end

    set(handles.resX, 'String', model.settings.zeiss.resX);
    set(handles.resY, 'String', model.settings.zeiss.resY);
    set(handles.resZ, 'String', model.settings.zeiss.resZ);
    set(handles.startX, 'String', model.settings.zeiss.startX);
    set(handles.startY, 'String', model.settings.zeiss.startY);
    set(handles.startZ, 'String', model.settings.zeiss.startZ);
    set(handles.widthX, 'String', model.settings.zeiss.widthX);
    set(handles.widthY, 'String', model.settings.zeiss.widthY);
    set(handles.widthZ, 'String', model.settings.zeiss.widthZ);

    if ~isnan(model.settings.zeiss.screen)
        detailX = model.settings.zeiss.startX:(model.settings.zeiss.startX + model.settings.zeiss.widthX);
        detailY = model.settings.zeiss.startY:(model.settings.zeiss.startY + model.settings.zeiss.widthY);
        imagesc(handles.screen, flipud(model.settings.zeiss.screen(detailY,detailX, :)));
        axis(handles.screen, [0 model.settings.zeiss.widthX 0 model.settings.zeiss.widthY]);
    end

    %% Camera settings
    set(handles.startX_camera, 'String', model.settings.andor.startX);
    set(handles.startY_camera, 'String', model.settings.andor.startY);
    set(handles.widthX_camera, 'String', model.settings.andor.widthX);
    set(handles.widthY_camera, 'String', model.settings.andor.widthY);
    set(handles.exp, 'String', model.settings.andor.exp);
    set(handles.nr, 'String', model.settings.andor.nr);
    set(handles.autoscale, 'Value', model.settings.andor.autoscale);
    set(handles.cap, 'String', model.settings.andor.cap);
    set(handles.floor, 'String', model.settings.andor.floor);
    if ~isnan(model.settings.andor.image)
        imagesc(handles.axesCamera, flipud(model.settings.andor.image));
    end
    if model.settings.andor.autoscale
        caxis(handles.axesCamera,'auto');
    else
        caxis(handles.axesCamera,[model.settings.andor.floor model.settings.andor.cap]);
    end
    axis(handles.axesCamera, [model.settings.andor.startX ...
        model.settings.andor.startX + model.settings.andor.widthX ...
        model.settings.andor.startY ...
        model.settings.andor.startY + model.settings.andor.widthY]);
    
    if isa(model.externalView.figure,'handle') && isvalid(model.externalView.figure)
        axis(model.externalView.axesCamera, [model.settings.andor.startX ...
            model.settings.andor.startX + model.settings.andor.widthX ...
            model.settings.andor.startY ...
            model.settings.andor.startY + model.settings.andor.widthY]);
        if model.settings.andor.autoscale
            caxis(model.externalView.axesCamera,'auto');
        else
            caxis(model.externalView.axesCamera,[model.settings.andor.floor model.settings.andor.cap]);
        end
    end
    

    if model.settings.preview
        set(handles.play, 'String', model.sharedFunctions.iconString([model.pp '/images/pause.png']));
    else
        set(handles.play, 'String', model.sharedFunctions.iconString([model.pp '/images/play.png']));
    end
end