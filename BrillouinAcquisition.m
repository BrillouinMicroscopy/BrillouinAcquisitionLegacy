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
    controllers.configuration.disconnect('', '', model);
    controllers.configuration.disconnectStage('', '', model);
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
    str = ['<html><img src="' iconUrl1 '" height="30" width="30"/></html>'];
end