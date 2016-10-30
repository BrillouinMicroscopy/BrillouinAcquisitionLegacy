function configuration = Configuration(model, view)

    %% callbacks ROI panel
    set(view.configuration.select, 'Callback', {@selectROI, model});
    
    configuration = struct( ...
        'disconnect', @disconnect ...
    );
end

function selectROI(~, ~, model)
    model.settings.zeiss.screen = Utils.ScreenCapture.screencapture(0, [0 0 2560 1600]);
    sel = figure;
    warning('off','images:initSize:adjustingMag');
    imshow(model.settings.zeiss.screen);
    warning('on','images:initSize:adjustingMag');
    [rect] = getrect(sel);
    model.settings.zeiss.x = rect(1);
    model.settings.zeiss.y = rect(2);
    model.settings.zeiss.width = rect(3);
    model.settings.zeiss.height = rect(4);
    close(sel);
end

function disconnect(~, ~, model)
    % Close the connection to the Andor camera
    andor = model.andor;
    if isa(andor,'Device.Control')
        delete(andor);
    end
    model.andor = [];
end