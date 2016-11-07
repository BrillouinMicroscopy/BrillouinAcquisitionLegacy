function handles = Acquisition(parent, model)
%% ACQUISITION View

    % build the GUI
    handles = initGUI(model, parent);
    initView(handles, model);    % populate with initial values

    % observe on model changes and update view accordingly
    % (tie listener to model object lifecycle)
%     addlistener(model, 'settings', 'PostSet', ...
%         @(o,e) onSettingsChange(handles, e.AffectedObject));
end

function handles = initGUI(model, parent)

    start = uicontrol('Parent', parent, 'Style','pushbutton', 'Units', 'normalized',...
        'String','Start','Position',[0.05,0.9,0.1,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left');

    stop = uicontrol('Parent', parent, 'Style','pushbutton', 'Units', 'normalized',...
        'String','Stop','Position',[0.17,0.9,0.1,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left');
    
    axesCamera = axes('Parent', parent, 'Position', [0.33 .085 .65 .87]);
    imageCamera = imagesc(axesCamera, flipud(model.settings.andor.image));
    set(axesCamera, 'box', 'on');
    xlabel(axesCamera, '$x$ [pix]', 'interpreter', 'latex');
    ylabel(axesCamera, '$y$ [pix]', 'interpreter', 'latex');
    zoom(gcf,'reset');
    zoomHandle = zoom;
    colorbar;
    
    %% Return handles
    handles = struct(...
        'start', start, ...
        'stop', stop, ...
        'axesCamera', axesCamera, ...
        'imageCamera', imageCamera, ...
        'zoomHandle', zoomHandle ...
	);
end

function initView(handles, model)
%% Initialize the view
end