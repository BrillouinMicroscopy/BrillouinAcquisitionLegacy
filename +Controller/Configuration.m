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
    set(view.configuration.connect, 'Callback', {@connectAndor, model});
    set(view.configuration.selectROI_Camera, 'Callback', {@selectROI_Camera, model});
    
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

function selectROI_Camera(~, ~, model)
    andor = model.settings.andor;
    sel = figure;
    warning('off','images:initSize:adjustingMag');
    imshow(andor.image);
    warning('on','images:initSize:adjustingMag');
    [rect] = getrect(sel);
    andor.startX = round(rect(1));
    andor.startY = round(rect(2));
    andor.widthX = round(rect(3));
    andor.widthY = round(rect(4));
    close(sel);
    model.settings.andor = andor;
end

function connectAndor(~, ~, model)
    disp('test');
end

function disconnect(~, ~, model)
    % Close the connection to the Andor camera
    andor = model.andor;
    if isa(andor,'Device.Control')
        delete(andor);
    end
    model.andor = [];
end