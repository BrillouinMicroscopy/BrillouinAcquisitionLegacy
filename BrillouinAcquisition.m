function BrillouinAcquisition
%% MAINCONTROLLER  MainController

    % controller knows about model and view
    model = BA_Model.Model();      % model is independent
    
    includePath(model);
    sharedFunctions(model);
    
    view = BA_View.Tabs(model);    % view has a reference of the model
    
    controllers = controller(model, view);
    
    set(view.figure, 'CloseRequestFcn', {@closeGUI, model, controllers});    
end

function closeGUI(~, ~, model, controllers)
    controllers.configuration.disconnect(model);
    controllers.configuration.disconnectStage(model);
    delete(gcf);
end

function controllers = controller(model, view)
    configuration = BA_Controller.Configuration(model, view);
    calibration = BA_Controller.Calibration(model, view);
    acquisition = BA_Controller.Acquisition(model, view);
    controllers = struct( ...
        'configuration', configuration, ...
        'calibration', calibration, ...
        'acquisition', acquisition ...
    );
end

function includePath(model)
    fp = mfilename('fullpath');
    [model.pp,~,~] = fileparts(fp);
    addpath(model.pp);
end

function sharedFunctions(model)
    model.sharedFunctions.iconString = @iconString;
end

function str = iconString(filepath)
    iconFile = urlencode(fullfile(filepath));
    iconUrl1 = strrep(['file:/' iconFile],'\','/');
    scale = getScalingValue();
    width = scale*20;
    height = scale*20;
    str = ['<html><img src="' iconUrl1 '" height="' sprintf('%1.0f', height) '" width="' sprintf('%1.0f', width) '"/></html>'];
end

function scale = getScalingValue()
    screenSize = get(0,'ScreenSize');
    jScreenSize = java.awt.Toolkit.getDefaultToolkit.getScreenSize;
    scale = jScreenSize.width/screenSize(3);
end