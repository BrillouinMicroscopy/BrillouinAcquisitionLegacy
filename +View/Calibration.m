function handles = Calibration(parent, model)
%% CONFIGURATION View

    % build the GUI
    handles = initGUI(parent);
    initView(handles, model);    % populate with initial values

    % observe on model changes and update view accordingly
    % (tie listener to model object lifecycle)
%     addlistener(model, 'settings', 'PostSet', ...
%         @(o,e) onSettingsChange(handles, e.AffectedObject));
end

function handles = initGUI(parent)
    %% Return handles
    handles = struct(...
	);
end

function initView(handles, model)
%% Initialize the view
end