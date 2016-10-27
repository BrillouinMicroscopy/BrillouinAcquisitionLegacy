function MainController
    %CONTROLLER  main program

    % controller knows about model and view
    model = Model.Model();      % model is independent
    view = View.Tabs(model);    % view has a reference of the model
    
    set(view.figure, 'CloseRequestFcn', {@closeGUI, model});

    %% callbacks ROI panel
    set(view.configuration.select, 'Callback', {@selectROI, model});
    
end

function closeGUI(~, ~, model)
    disconnect('', '', model);
    delete(gcf);
end

function selectROI(~, ~, model)
    model.settings.zeiss.screen = screencapture(0, [0 0 2560 1600]);
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
    disp(rect);
end

function disconnect(~, ~, model)
    % Close the connection to the Andor camera
    andor = model.andor;
    if isa(andor,'Device.Control')
        delete(andor);
    end
    model.andor = [];
end