function configuration = Configuration(model, view)
%% CONFIGURATION Controller

    %% general settings panel
    set(view.configuration.save, 'Callback', {@saveSettings, model});
    set(view.configuration.load, 'Callback', {@loadSettings, model});

    %% callbacks Microscope panel
    set(view.configuration.stages, 'Callback', {@selectStage, model});
    set(view.configuration.select, 'Callback', {@selectROI_Microscope, model});
    set(view.configuration.connectStage, 'Callback', {@connectStage, model});
    set(view.configuration.disconnectStage, 'Callback', {@disconnectStage, model});
    set(view.configuration.defaultElementsStage, 'Callback', {@setDefaultElements, model});
    set(view.configuration.resX, 'Callback', {@setROI_Microscope, model});
    set(view.configuration.resY, 'Callback', {@setROI_Microscope, model});
    set(view.configuration.resZ, 'Callback', {@setROI_Microscope, model});
    set(view.configuration.startX, 'Callback', {@setROI_Microscope, model});
    set(view.configuration.startY, 'Callback', {@setROI_Microscope, model});
    set(view.configuration.startZ, 'Callback', {@setROI_Microscope, model});
    set(view.configuration.widthX, 'Callback', {@setROI_Microscope, model});
    set(view.configuration.widthY, 'Callback', {@setROI_Microscope, model});
    set(view.configuration.widthZ, 'Callback', {@setROI_Microscope, model});
    
    elements = {'reflector', 'objective', 'tubelens', 'baseport', 'sideport', 'mirror'};
    
    for ii = 1:length(elements)
        
        for jj = 1:length(view.configuration.elements.(elements{ii}))
            set(view.configuration.elements.(elements{ii})(jj), 'Callback', {@setElement, elements{ii}, model});
        end
    end
    
    %% callbacks Camera panel
    set(view.configuration.connect, 'Callback', {@connect, model});
    set(view.configuration.disconnect, 'Callback', {@disconnect, model});
    set(view.configuration.play, 'Callback', {@play, model, view});
    set(view.configuration.update, 'Callback', {@update, model});
    set(view.configuration.zoomIn, 'Callback', {@zoom, 'in', view});
    set(view.configuration.zoomOut, 'Callback', {@zoom, 'out', view});
    set(view.configuration.panButton, 'Callback', {@pan, view});
    set(view.configuration.zoomHandle, 'ActionPostCallback', {@updateLimits, model, view});
    set(view.configuration.panHandle, 'ActionPostCallback', {@updateLimits, model, view});
    set(view.configuration.startX_camera, 'Callback', {@setCameraParameters, model});
    set(view.configuration.startY_camera, 'Callback', {@setCameraParameters, model});
    set(view.configuration.widthX_camera, 'Callback', {@setCameraParameters, model});
    set(view.configuration.widthY_camera, 'Callback', {@setCameraParameters, model});
    set(view.configuration.exp, 'Callback', {@setCameraParameters, model});
    set(view.configuration.nr, 'Callback', {@setCameraParameters, model});
    set(view.configuration.autoscale, 'Callback', {@toggleAutoscale, model, view});
    set(view.configuration.cap, 'Callback', {@setCameraParameters, model});
    set(view.configuration.floor, 'Callback', {@setCameraParameters, model});
    
    set(view.configuration.increaseFloor, 'Callback', {@increaseClim, model});
    set(view.configuration.decreaseFloor, 'Callback', {@decreaseClim, model});
    set(view.configuration.increaseCap, 'Callback', {@increaseClim, model});
    set(view.configuration.decreaseCap, 'Callback', {@decreaseClim, model});
    
    configuration = struct( ...
        'disconnect', @disconnect, ...
        'disconnectStage', @disconnectStage ...
    );
end

function saveSettings(~, ~, model)
    [fileName,pathName] = uiputfile('.mat', 'Select folder to save settings.', 'settings.mat');
    settings = model.settings; %#ok<NASGU>
    if isnumeric(fileName) && isnumeric(pathName)
        return;
    end
    save([pathName fileName], 'settings');
end

function loadSettings(~, ~, model)
    [fileName,pathName,~] = uigetfile('.mat','Select file to load settings.','settings.mat');
    if isnumeric(fileName) && isnumeric(pathName)
        return;
    end
    settings = load([pathName fileName], 'settings');
    model.settings = settings.settings;
end

function selectStage(src, ~, model)
    val = get(src,'Value');
    stages = get(src,'String');
    model.settings.zeiss.stage = stages{val};
end

function selectROI_Microscope(~, ~, model)
    zeiss = model.settings.zeiss;
    zeiss.screen = Utils.ScreenCapture.screencapture(0, [0 0 2560 1600]);
    sel = figure;
    warning('off','images:initSize:adjustingMag');
    imshow(zeiss.screen);
    warning('on','images:initSize:adjustingMag');
    [rect] = getrect(sel);
    zeiss.startX = round(rect(1));
    zeiss.startY = round(rect(2));
    zeiss.widthX = round(rect(3));
    zeiss.widthY = round(rect(4));
    close(sel);
    model.settings.zeiss = zeiss;
end

function setROI_Microscope(UIControl, ~, model)
    field = get(UIControl, 'Tag');
    model.settings.zeiss.(field) = str2double(get(UIControl, 'String'));
end

function setCameraParameters(UIControl, ~, model)
    field = get(UIControl, 'Tag');
    model.settings.andor.(field) = str2double(get(UIControl, 'String'));
end

function play(~, ~, model, view)
    if isa(model.andor,'Utils.AndorControl.AndorControl') && isvalid(model.andor)
        model.settings.preview = ~model.settings.preview;
        andor = model.andor;

        if model.settings.preview
            andor.ExposureTime = model.settings.andor.exp;
            andor.CycleMode = 'Continuous';
            andor.TriggerMode = 'Software';
            andor.SimplePreAmpGainControl = '16-bit (low noise & high well capacity)';
            andor.PixelEncoding = 'Mono16';
            
            % set AOI to full frame
            andor.AOI.binning = '1x1';
            andor.AOI.width = model.settings.andor.widthXdefault;
            andor.AOI.left = 1;
            andor.AOI.height = model.settings.andor.widthYdefault;
            andor.AOI.top = 1;

            andor.startAcquisition();
            run(model, view);
        else
            andor.stopAcquisition();
        end
    else
        disp('Please connect to the camera first.');
    end
end

function run(model, view)
    while(model.settings.preview)
        buf = model.andor.getBuffer();
        img = model.andor.ConvertBuffer(buf);
        set(view.configuration.imageCamera,'CData',img);
        if model.settings.andor.autoscale
           model.settings.andor.floor = double(min(img(:)));
           model.settings.andor.cap = double(max(img(:)));
        end
        drawnow;
    end
end

function update(~, ~, model)
    if isa(model.andor,'Utils.AndorControl.AndorControl') && isvalid(model.andor)

    else
        disp('Please connect to the camera first.');
    end
end

function connect(~, ~, model)
    model.andor = Utils.AndorControl.AndorControl();
end

function disconnect(~, ~, model)
    model.settings.preview = 0;
    model.settings.acquisition = 0;
    % Close the connection to the Andor camera
    andor = model.andor;
    if isa(andor,'Device.Control')
        delete(andor);
    end
    model.andor = [];
end

function connectStage(~, ~, model)
    zeiss = model.zeiss;
    if ~exist('zeiss','var') || ~isa(zeiss,'ScanControl') || ~isvalid(zeiss)
        model.zeiss = Utils.ScanControl.ScanControl('LSM510', model.settings.zeiss.stage);
    end
    %% Get the current positions of the microscope elements
    % Although the reflector is at position 1 it always returns 0 at the
    % first connection after microscope start. This is an invalid value.
    ref = model.zeiss.device.can.stand.reflector;
    if ~ref
        ref = 1;
    end
    model.settings.zeiss.reflector = ref;    % position of the reflector
    
    model.settings.zeiss.objective = model.zeiss.device.can.stand.objective;    % position of the objective
    model.settings.zeiss.tubelens = model.zeiss.device.can.stand.tubelens;      % position of the tubelens
    model.settings.zeiss.baseport = model.zeiss.device.can.stand.baseport;      % position of the baseport
    model.settings.zeiss.sideport = model.zeiss.device.can.stand.sideport;      % position of the sideport
    model.settings.zeiss.mirror = model.zeiss.device.can.stand.mirror;          % position of the mirror
end

function setDefaultElements(~, ~, model)
    %% Set the default positions of the microscope elements
    model.settings.zeiss.reflector = model.settings.zeiss.default.reflector;    % position of the reflector
    model.settings.zeiss.objective = model.settings.zeiss.default.objective;    % position of the objective
    model.settings.zeiss.tubelens = model.settings.zeiss.default.tubelens;      % position of the tubelens
    model.settings.zeiss.baseport = model.settings.zeiss.default.baseport;      % position of the baseport
    model.settings.zeiss.sideport = model.settings.zeiss.default.sideport;      % position of the sideport
    model.settings.zeiss.mirror = model.settings.zeiss.default.mirror;          % position of the mirror
    model.zeiss.device.can.stand.reflector = model.settings.zeiss.default.reflector;    % position of the reflector
    model.zeiss.device.can.stand.objective = model.settings.zeiss.default.objective;    % position of the objective
    model.zeiss.device.can.stand.tubelens = model.settings.zeiss.default.tubelens;      % position of the tubelens
    model.zeiss.device.can.stand.baseport = model.settings.zeiss.default.baseport;      % position of the baseport
    model.zeiss.device.can.stand.sideport = model.settings.zeiss.default.sideport;      % position of the sideport
    model.zeiss.device.can.stand.mirror = model.settings.zeiss.default.mirror;          % position of the mirror

end

function setElement(src, ~, element, model)
    model.settings.zeiss.(element) = str2double(get(src, 'String'));
    model.zeiss.device.can.stand.(element) = model.settings.zeiss.(element);
end

function disconnectStage(~, ~, model)
    % Close the connection to the stage
    zeiss = model.zeiss;
    if isa(zeiss,'Utils.ScanControl.ScanControl')
        delete(zeiss);
    end
    model.zeiss = [];
end

function zoom(src, ~, str, view)
switch get(src, 'UserData')
    case 0
        set(view.configuration.panButton,'UserData',0);
        set(view.configuration.panHandle,'Enable','off');
        switch str
            case 'in'
                set(view.configuration.zoomHandle,'Enable','on','Direction','in');
                set(view.configuration.zoomIn,'UserData',1);
                set(view.configuration.zoomOut,'UserData',0);
            case 'out'
                set(view.configuration.zoomHandle,'Enable','on','Direction','out');
                set(view.configuration.zoomOut,'UserData',1);
                set(view.configuration.zoomIn,'UserData',0);
        end
    case 1
        set(view.configuration.zoomHandle,'Enable','off','Direction','in');
        set(view.configuration.zoomOut,'UserData',0);
        set(view.configuration.zoomIn,'UserData',0);
end
        
end

function pan(src, ~, view)
    set(view.configuration.zoomOut,'UserData',0);
    set(view.configuration.zoomIn,'UserData',0);
    switch get(src, 'UserData')
        case 0
            set(view.configuration.panButton,'UserData',1);
            set(view.configuration.panHandle,'Enable','on');
        case 1
            set(view.configuration.panButton,'UserData',0);
            set(view.configuration.panHandle,'Enable','off');
    end
end

function decreaseClim(UIControl, ~, model)
    model.settings.andor.autoscale = 0;
    field = get(UIControl, 'Tag');
    dif = abs(0.1*(model.settings.andor.cap - model.settings.andor.floor));
    model.settings.andor.(field) = model.settings.andor.(field) - dif;
end

function increaseClim(UIControl, ~, model)
    model.settings.andor.autoscale = 0;
    field = get(UIControl, 'Tag');
    dif = abs(0.1*(model.settings.andor.cap - model.settings.andor.floor));
    model.settings.andor.(field) = model.settings.andor.(field) + dif;
end

function updateLimits(~, ~, model, view)
    andor = model.settings.andor;
    
    startX = round(view.configuration.axesCamera.XLim(1));
    if startX < 1
        startX = 1;
    end
    andor.startX = startX;
    
    startY = round(view.configuration.axesCamera.YLim(1));
    if startY < 1
        startY = 1;
    end
    andor.startY = startY;
    
    widthX = round(view.configuration.axesCamera.XLim(2) - view.configuration.axesCamera.XLim(1));
    if widthX > size(model.settings.andor.image,2)
        widthX = size(model.settings.andor.image,2);
    end
    andor.widthX = widthX;
    
    widthY = round(view.configuration.axesCamera.YLim(2) - view.configuration.axesCamera.YLim(1));
    if widthY > size(model.settings.andor.image,1)
        widthY = size(model.settings.andor.image,1);
    end
    andor.widthY = widthY;
    
    model.settings.andor = andor;
end

function toggleAutoscale(~, ~, model, view)
    model.settings.andor.autoscale = get(view.configuration.autoscale, 'Value');
end