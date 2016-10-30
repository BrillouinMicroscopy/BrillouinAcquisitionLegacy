function MainController
    %CONTROLLER  main program

    % controller knows about model and view
    model = Model.Model();      % model is independent
    view = View.Tabs(model);    % view has a reference of the model
    
    controllers = controller(model, view);
    
    set(view.figure, 'CloseRequestFcn', {@closeGUI, model, controllers});    
end

function closeGUI(~, ~, model, controllers)
    controllers.configuration.disconnect('', '', model);
    delete(gcf);
end

function controllers = controller(model, view)
    configuration = Controller.Configuration(model, view);
    acquisition = Controller.Acquisition(model, view);
    controllers = struct( ...
        'configuration', configuration, ...
        'acquisition', acquisition ...
    );
end