function configuration = Configuration(model, view)
%% CONFIGURATION Controller

    %% general settings panel
    set(view.configuration.save, 'Callback', {@saveSettings, model});
    set(view.configuration.load, 'Callback', {@loadSettings, model});

    %% callbacks Microscope panel
    set(view.configuration.stages, 'Callback', {@selectStage, model});
    set(view.configuration.select, 'Callback', {@selectROI_Microscope, model});
    set(view.configuration.connectStage, 'Callback', {@connectStage, model});
    for jj = 1:length(view.configuration.presetButtons)
        set(view.configuration.presetButtons(jj), 'Callback', {@setPreset, model});
    end
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
    set(view.configuration.cooling, 'Callback', {@cooling, model});
    set(view.configuration.play, 'Callback', {@play, model, view});
    set(view.configuration.update, 'Callback', {@update, model, view});
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
    set(view.configuration.externalFigure, 'Callback', {@openFigure, model});
    
    set(view.configuration.increaseFloor, 'Callback', {@increaseClim, model});
    set(view.configuration.decreaseFloor, 'Callback', {@decreaseClim, model});
    set(view.configuration.increaseCap, 'Callback', {@increaseClim, model});
    set(view.configuration.decreaseCap, 'Callback', {@decreaseClim, model});
    
    configuration = struct( ...
        'disconnect', @disconnectCamera, ...
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
    zeiss.screen = BA_Utils.ScreenCapture.screencapture(0, [0 0 2560 1600]);
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

function openFigure(~, ~, model)
    if ~isa(model.externalView.figure,'handle') || ~isvalid(model.externalView.figure)
        model.externalView.figure = figure();
        model.externalView.axesCamera = axes('Parent', model.externalView.figure); 
        model.externalView.image = imagesc(model.externalView.axesCamera, NaN);
        axis(model.externalView.axesCamera, [model.settings.andor.startX ...
            model.settings.andor.startX + model.settings.andor.widthX ...
            model.settings.andor.startY ...
            model.settings.andor.startY + model.settings.andor.widthY]);
        if model.settings.andor.autoscale
            caxis(model.externalView.axesCamera,'auto');
        else
            caxis(model.externalView.axesCamera,[model.settings.andor.floor model.settings.andor.cap]);
        end
        xlabel(model.externalView.axesCamera, '$x$ [pix]', 'interpreter', 'latex');
        ylabel(model.externalView.axesCamera, '$y$ [pix]', 'interpreter', 'latex');
    end
end

function play(~, ~, model, view)
    if isa(model.andor,'BA_Utils.AndorControl.AndorControl') && isvalid(model.andor)
        if ~model.acquisition.acquisition
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
            disp('Acquisition in progress.');
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
        if isa(model.externalView.figure,'handle') && isvalid(model.externalView.figure)
            set(model.externalView.image,'CData',img);
        end 
        drawnow;
    end
end

function update(~, ~, model, view)
    if isa(model.andor,'BA_Utils.AndorControl.AndorControl') && isvalid(model.andor)
        andor = model.andor;
        if ~model.settings.preview
            if ~model.settings.update && ~model.acquisition.acquisition
                model.settings.update = 1;
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
                buf = model.andor.getBuffer();
                img = model.andor.ConvertBuffer(buf);
                set(view.configuration.imageCamera,'CData',img);
                if model.settings.andor.autoscale
                   model.settings.andor.floor = double(min(img(:)));
                   model.settings.andor.cap = double(max(img(:)));
                end
                if isa(model.externalView.figure,'handle') && isvalid(model.externalView.figure)
                    set(model.externalView.image,'CData',img);
                end 
                drawnow;
                andor.stopAcquisition();
                model.settings.update = 0;
            end
        else
            model.settings.preview = 0;
            andor.stopAcquisition();
        end
    else
        disp('Please connect to the camera first.');
    end
end

function connect(~, ~, model)
    if isa(model.andor,'BA_Utils.AndorControl.AndorControl') && isvalid(model.andor)
        disconnectCamera(model);
    else
        model.andor = BA_Utils.AndorControl.AndorControl();
        % update cooling model (necessary since MATLAB does not listen to
        % direct changes to model.andor)
        tmp = struct();
        tmp.SensorCooling = model.andor.SensorCooling;
        tmp.SensorTemperatureStatus = model.andor.SensorTemperatureStatus;
        tmp.SensorTemperature = model.andor.SensorTemperature;
        model.cooling = tmp;
        if model.cooling.SensorCooling && strcmp(get(model.coolingTimer,'Running'),'off') == 1
            start(model.coolingTimer);
        else
            stop(model.coolingTimer);
        end
    end
end

function disconnectCamera(model)
    model.settings.preview = 0;
    model.acquisition.acquisition = 0;
    % Close the connection to the Andor camera
    andor = model.andor;
    if isa(andor,'BA_Utils.AndorControl.AndorControl')
        % turn off sensor cooling before shutdown
        andor.SensorCooling = 0;
        stop(model.coolingTimer);
        tmp = struct();
        tmp.SensorCooling = model.andor.SensorCooling;
        tmp.SensorTemperatureStatus = model.andor.SensorTemperatureStatus;
        tmp.SensorTemperature = model.andor.SensorTemperature;
        model.cooling = tmp;
        delete(andor);
    end
    model.andor = [];
end

function cooling(~, ~, model)
    andor = model.andor;
    if isa(andor,'BA_Utils.AndorControl.AndorControl')
        model.andor.SensorCooling = double(~model.andor.SensorCooling);
        % update cooling model (necessary since MATLAB does not listen to
        % direct changes to model.andor)
        tmp = struct();
        tmp.SensorCooling = model.andor.SensorCooling;
        tmp.SensorTemperatureStatus = model.andor.SensorTemperatureStatus;
        tmp.SensorTemperature = model.andor.SensorTemperature;
        model.cooling = tmp;
        if model.cooling.SensorCooling && strcmp(get(model.coolingTimer,'Running'),'off') == 1
            start(model.coolingTimer);
        else
            stop(model.coolingTimer);
        end
    end
end

function connectStage(~, ~, model)
    if isa(model.zeiss,'BA_Utils.ScanControl.ScanControl') && isvalid(model.zeiss)
        disconnectStage(model);
    else
        zeiss = model.zeiss;
        if ~exist('zeiss','var') || ~isa(zeiss,'ScanControl') || ~isvalid(zeiss)
            model.zeiss = BA_Utils.ScanControl.ScanControl('LSM510', model.settings.zeiss.stage);
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
end

function disconnectStage(model)
    % Close the connection to the stage
    zeiss = model.zeiss;
    if isa(zeiss,'BA_Utils.ScanControl.ScanControl')
        delete(zeiss);
    end
    model.zeiss = [];
end

function setPreset(src, ~, model)
    %% Set the default positions of the microscope elements
    preset = model.settings.zeiss.presets.(get(src, 'Tag'));
    model.settings.zeiss.reflector = preset.reflector;    % position of the reflector
    model.settings.zeiss.objective = preset.objective;    % position of the objective
    model.settings.zeiss.tubelens = preset.tubelens;      % position of the tubelens
    model.settings.zeiss.baseport = preset.baseport;      % position of the baseport
    model.settings.zeiss.sideport = preset.sideport;      % position of the sideport
    model.settings.zeiss.mirror = preset.mirror;          % position of the mirror
    model.zeiss.device.can.stand.reflector = preset.reflector;    % position of the reflector
    model.zeiss.device.can.stand.objective = preset.objective;    % position of the objective
    model.zeiss.device.can.stand.tubelens = preset.tubelens;      % position of the tubelens
    model.zeiss.device.can.stand.baseport = preset.baseport;      % position of the baseport
    model.zeiss.device.can.stand.sideport = preset.sideport;      % position of the sideport
    model.zeiss.device.can.stand.mirror = preset.mirror;          % position of the mirror

end

function setElement(src, ~, element, model)
    model.settings.zeiss.(element) = str2double(get(src, 'String'));
    model.zeiss.device.can.stand.(element) = model.settings.zeiss.(element);
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