function calibration = Calibration(model, view)
%% CALIBRATION Controller

    %% callbacks Calibration
    set(view.calibration.acquire, 'Callback', {@startAcquisition, model, view});
    set(view.calibration.clear, 'Callback', {@clear, model});
    
    set(view.calibration.imageSlider, 'StateChangedCallback', {@selectImage, model});
    
    set(view.calibration.nrImg, 'Callback', {@setNrImg, model});
    set(view.calibration.samples, 'Callback', {@selectSample, model});
    
    set(view.calibration.zoomIn, 'Callback', {@zoom, 'in', view});
    set(view.calibration.zoomOut, 'Callback', {@zoom, 'out', view});
    set(view.calibration.panButton, 'Callback', {@pan, view});
    
    set(view.calibration.autoscale, 'Callback', {@toggleAutoscale, model, view});
    set(view.calibration.cap, 'Callback', {@setClim, model});
    set(view.calibration.floor, 'Callback', {@setClim, model});
    
    set(view.calibration.increaseFloor, 'Callback', {@increaseClim, model});
    set(view.calibration.decreaseFloor, 'Callback', {@decreaseClim, model});
    set(view.calibration.increaseCap, 'Callback', {@increaseClim, model});
    set(view.calibration.decreaseCap, 'Callback', {@decreaseClim, model});
    
    calibration = struct( ...
    );
end

function startAcquisition(~, ~, model, view)
    if isa(model.andor,'BA_Utils.AndorControl.AndorControl') && isvalid(model.andor)
        model.calibration.acquisition = ~model.calibration.acquisition;
        if model.calibration.acquisition
            acquire(model, view);
            model.calibration.acquisition = 0;
        end
    else
        model.calibration.acquisition = 0;
        disp('Please connect to the camera first.');
    end
end

function acquire(model, view)
    zyla = model.andor;
    disp('Camera initialized.');

    %% set camera parameters
    zyla.ExposureTime = model.settings.andor.exp;
    zyla.CycleMode = 'Fixed';
    zyla.TriggerMode = 'Internal';
    zyla.SimplePreAmpGainControl = '16-bit (low noise & high well capacity)';
    zyla.PixelEncoding = 'Mono16';
    zyla.FrameCount = model.calibration.nrImg;

    %% set area of interest
    zyla.AOI.binning = '1x1';
    zyla.AOI.width = model.settings.andor.widthY;
    zyla.AOI.left = model.settings.andor.startY;
    zyla.AOI.height = model.settings.andor.widthX;
    zyla.AOI.top = model.settings.andor.startX;
    
    zyla.startAcquisition();
    images = NaN(model.settings.andor.widthY, model.settings.andor.widthX, model.calibration.nrImg);
    for mm = 1:model.calibration.nrImg
        if ~model.calibration.acquisition
            break
        end
        drawnow;
        buf = zyla.getBuffer();
        images(:,:,mm) = zyla.ConvertBuffer(buf);
        
        set(view.calibration.imgNr, 'String', sprintf('%1.0d', mm));
        view.calibration.progressBar.setValue(100*mm/model.calibration.nrImg);
        view.calibration.progressBar.setString(sprintf('%02.1f%% completed', 100*mm/model.calibration.nrImg));
        
    end
    zyla.stopAcquisition();

    model.calibration.images.(model.calibration.selected) = images;
    
    view.calibration.progressBar.setString('Acquisition finished.');
end

function clear(~, ~, model)
    model.calibration.images = struct( ...
        'background', NaN(10,10,1), ...
        'methanol', NaN(10,10,1), ...
        'water', NaN(10,10,1) ...
    );
end

function setNrImg(src, ~, model)
    model.calibration.nrImg = str2double(get(src, 'String'));
end

function selectSample(src, ~, model)
    val = get(src,'Value');
    samples = get(src,'String');
    str = samples{val};
    switch str
        case 'None (Background)'
            sample = 'background';
        case 'Water'
            sample = 'water';
        case 'Methanol'
            sample = 'methanol';
    end        
    model.calibration.selected = sample;
end

function selectImage(src, ~, model)
    model.calibration.imgNr = get(src, 'Value');
end

function setClim(UIControl, ~, model)
    field = get(UIControl, 'Tag');
    model.calibration.(field) = str2double(get(UIControl, 'String'));
end

function toggleAutoscale(~, ~, model, view)
    model.calibration.autoscale = get(view.calibration.autoscale, 'Value');
end

function zoom(src, ~, str, view)
switch get(src, 'UserData')
    case 0
        set(view.calibration.panButton,'UserData',0);
        set(view.calibration.panHandle,'Enable','off');
        switch str
            case 'in'
                set(view.calibration.zoomHandle,'Enable','on','Direction','in');
                set(view.calibration.zoomIn,'UserData',1);
                set(view.calibration.zoomOut,'UserData',0);
            case 'out'
                set(view.calibration.zoomHandle,'Enable','on','Direction','out');
                set(view.calibration.zoomOut,'UserData',1);
                set(view.calibration.zoomIn,'UserData',0);
        end
    case 1
        set(view.calibration.zoomHandle,'Enable','off','Direction','in');
        set(view.calibration.zoomOut,'UserData',0);
        set(view.calibration.zoomIn,'UserData',0);
end
        
end

function pan(src, ~, view)
    set(view.calibration.zoomOut,'UserData',0);
    set(view.calibration.zoomIn,'UserData',0);
    switch get(src, 'UserData')
        case 0
            set(view.calibration.panButton,'UserData',1);
            set(view.calibration.panHandle,'Enable','on');
        case 1
            set(view.calibration.panButton,'UserData',0);
            set(view.calibration.panHandle,'Enable','off');
    end
end

function decreaseClim(UIControl, ~, model)
    model.calibration.autoscale = 0;
    field = get(UIControl, 'Tag');
    dif = abs(0.1*(model.calibration.cap - model.calibration.floor));
    model.calibration.(field) = model.calibration.(field) - dif;
end

function increaseClim(UIControl, ~, model)
    model.calibration.autoscale = 0;
    field = get(UIControl, 'Tag');
    dif = abs(0.1*(model.calibration.cap - model.calibration.floor));
    model.calibration.(field) = model.calibration.(field) + dif;
end