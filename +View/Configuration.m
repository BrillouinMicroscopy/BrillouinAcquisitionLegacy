function handles = Configuration(parent, model)
    %CONFIGURATION

    % build the GUI
    handles = initGUI(parent);
    initView(handles, model);    % populate with initial values

    % observe on model changes and update view accordingly
    % (tie listener to model object lifecycle)
%     addlistener(model, 'device', 'PostSet', ...
%         @(o,e) onConnectionChange(handles,e.AffectedObject));
end

function handles = initGUI(parent)
    %% General settings panel
    settings = uipanel('Parent', parent, 'Title', 'Region of Interest', 'FontSize', 11,...
        'Position', [.02 .7 .47 .28]);

    select = uicontrol('Parent', settings, 'Style','pushbutton', 'Units', 'normalized',...
        'String','Select ROI','Position',[0.4,0.75,0.25,0.2],...
        'FontSize', 11, 'HorizontalAlignment', 'left');
	
    %% Return handles
    handles = struct(...
        'settings', settings, ...
        'select',   select ...
	);
end

function initView(handles, model)
%% Initialize the view
%     onSettingsChange(handles, model);
end