function handles = Acquisition(parent, model)
%% ACQUISITION View

    % build the GUI
    handles = initGUI(parent);
    initView(handles, model);    % populate with initial values

    % observe on model changes and update view accordingly
    % (tie listener to model object lifecycle)
%     addlistener(model, 'settings', 'PostSet', ...
%         @(o,e) onSettingsChange(handles, e.AffectedObject));
end

function handles = initGUI(parent)

    start = uicontrol('Parent', parent, 'Style','pushbutton', 'Units', 'normalized',...
        'String','Start','Position',[0.05,0.9,0.1,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left');
    
    %% Return handles
    handles = struct(...
        'start', start ...
	);
end

function initView(handles, model)
%% Initialize the view
end