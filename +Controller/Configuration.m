function configuration = Configuration(model, view)
%% CONFIGURATION Controller


    %% callbacks Microscope panel
    set(view.configuration.select, 'Callback', {@selectROI_Microscope, model});
    set(view.configuration.resX, 'Callback', {@setROI_Microscope, model});
    set(view.configuration.resY, 'Callback', {@setROI_Microscope, model});
    set(view.configuration.resZ, 'Callback', {@setROI_Microscope, model});
    set(view.configuration.startX, 'Callback', {@setROI_Microscope, model});
    set(view.configuration.startY, 'Callback', {@setROI_Microscope, model});
    set(view.configuration.startZ, 'Callback', {@setROI_Microscope, model});
    set(view.configuration.widthX, 'Callback', {@setROI_Microscope, model});
    set(view.configuration.widthY, 'Callback', {@setROI_Microscope, model});
    set(view.configuration.widthZ, 'Callback', {@setROI_Microscope, model});
    
    %% callbacks Camera panel
    set(view.configuration.connect, 'Callback', {@connect, model});
    set(view.configuration.disconnect, 'Callback', {@disconnect, model});
    set(view.configuration.play, 'Callback', {@play, model, view});
    set(view.configuration.update, 'Callback', {@update, model});
    set(view.configuration.zoomIn, 'Callback', {@zoom, 'in', view});
    set(view.configuration.zoomOut, 'Callback', {@zoom, 'out', view});
    set(view.configuration.zoomHandle, 'ActionPostCallback', {@updateLimits, model, view});
    set(view.configuration.startX_camera, 'Callback', {@setCameraParameters, model});
    set(view.configuration.startY_camera, 'Callback', {@setCameraParameters, model});
    set(view.configuration.widthX_camera, 'Callback', {@setCameraParameters, model});
    set(view.configuration.widthY_camera, 'Callback', {@setCameraParameters, model});
    set(view.configuration.exp, 'Callback', {@setCameraParameters, model});
    set(view.configuration.nr, 'Callback', {@setCameraParameters, model});
    
    configuration = struct( ...
        'disconnect', @disconnect ...
    );
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
    model.settings.preview = ~model.settings.preview;
    andor = model.andor;
    
    if model.settings.preview
        andor.ExposureTime = 0.1;
        andor.CycleMode = 'Continuous';
        andor.TriggerMode = 'Software';
        andor.SimplePreAmpGainControl = '16-bit (low noise & high well capacity)';
        andor.PixelEncoding = 'Mono16';

        andor.startAcquisition();
        run(model, view);
    else 
        andor.stopAcquisition();
    end
end

function run(model, view)
    while(model.settings.preview)
        buf = model.andor.getBuffer();
        img = model.andor.ConvertBuffer(buf);
        set(view.configuration.imageCamera,'CData',img);
        pause(0.01);
    end
end

function update(~, ~, model)
end

function connect(~, ~, model)
    model.andor = Utils.AndorControl.AndorControl();
end

function disconnect(~, ~, model)
    % Close the connection to the Andor camera
    andor = model.andor;
    if isa(andor,'Device.Control')
        delete(andor);
    end
    model.andor = [];
end

function zoom(src, ~, str, view)
switch get(src, 'UserData')
    case 0
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