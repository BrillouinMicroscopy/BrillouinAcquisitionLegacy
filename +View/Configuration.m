function handles = Configuration(parent, model)
    %CONFIGURATION

    % build the GUI
    handles = initGUI(parent);
    initView(handles, model);    % populate with initial values

    % observe on model changes and update view accordingly
    % (tie listener to model object lifecycle)
    addlistener(model, 'settings', 'PostSet', ...
        @(o,e) onSettingsChange(handles,e.AffectedObject));
end

function handles = initGUI(parent)
    %% Microscope panel
    microscope = uipanel('Parent', parent, 'Title', 'Microscope – Region of Interest', 'FontSize', 11,...
        'Position', [.02 .02 .47 .96]);

    select = uicontrol('Parent', microscope, 'Style','pushbutton', 'Units', 'normalized',...
        'String','Select ROI','Position',[0.72,0.94,0.25,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left');
    
    %% x-direction
    x = uipanel('Parent', microscope, 'Title', 'x-direction', 'FontSize', 11,...
        'Position', [.03 .71 .3 .225]);
    
    uicontrol('Parent', x, 'Style', 'text', 'String', 'Resolution', 'Units', 'normalized',...
        'Position', [0.05,0.05,0.6,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    resX = uicontrol('Parent', x, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.67,0.09,0.28,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center');
    
    uicontrol('Parent', x, 'Style', 'text', 'String', 'Width', 'Units', 'normalized',...
        'Position', [0.05,0.35,0.96,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    widthX = uicontrol('Parent', x, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.67,0.39,0.28,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center');
    
    uicontrol('Parent', x, 'Style', 'text', 'String', 'Start', 'Units', 'normalized',...
        'Position', [0.05,0.65,0.96,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    startX = uicontrol('Parent', x, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.67,0.69,0.28,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center');
    
    %% y-direction
    y = uipanel('Parent', microscope, 'Title', 'y-direction', 'FontSize', 11,...
        'Position', [.35 .71 .3 .225]);
    
    uicontrol('Parent', y, 'Style', 'text', 'String', 'Resolution', 'Units', 'normalized',...
        'Position', [0.05,0.05,0.6,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    resY = uicontrol('Parent', y, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.67,0.09,0.28,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center');
    
    uicontrol('Parent', y, 'Style', 'text', 'String', 'Width', 'Units', 'normalized',...
        'Position', [0.05,0.35,0.96,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    widthY = uicontrol('Parent', y, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.67,0.39,0.28,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center');
    
    uicontrol('Parent', y, 'Style', 'text', 'String', 'Start', 'Units', 'normalized',...
        'Position', [0.05,0.65,0.96,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    startY = uicontrol('Parent', y, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.67,0.69,0.28,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center');
    
    %% z-direction
    z = uipanel('Parent', microscope, 'Title', 'z-direction', 'FontSize', 11,...
        'Position', [.67 .71 .3 .225]);
    
    uicontrol('Parent', z, 'Style', 'text', 'String', 'Resolution', 'Units', 'normalized',...
        'Position', [0.05,0.05,0.6,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    resZ = uicontrol('Parent', z, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.67,0.09,0.28,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center');
    
    uicontrol('Parent', z, 'Style', 'text', 'String', 'Width', 'Units', 'normalized',...
        'Position', [0.05,0.35,0.96,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    widthZ = uicontrol('Parent', z, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.67,0.39,0.28,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center');
    
    uicontrol('Parent', z, 'Style', 'text', 'String', 'Start', 'Units', 'normalized',...
        'Position', [0.05,0.65,0.96,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    startZ = uicontrol('Parent', z, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.67,0.69,0.28,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center');
    
    set(findall(z, '-property', 'enable'), 'enable', 'off');
    
    %% screenshot
    ZENimage = axes('Parent', microscope, 'Position', [0.12 .085 .85 .6]);
    hold on;
    set(ZENimage, 'box', 'on');
    xlabel(ZENimage, '$x$ [pix]', 'interpreter', 'latex');
    ylabel(ZENimage, '$y$ [pix]', 'interpreter', 'latex');
    
    %% Camera panel
    camera = uipanel('Parent', parent, 'Title', 'Camera', 'FontSize', 11,...
        'Position', [.51 .02 .47 .96]);

    connect = uicontrol('Parent', camera, 'Style','pushbutton', 'Units', 'normalized',...
        'String','Connect','Position',[0.72,0.75,0.25,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left');
    
    ZENimage = axes('Parent', camera, 'Position', [0.12 .085 .85 .6]);
    hold on;
    set(ZENimage, 'box', 'on');
    xlabel(ZENimage, '$x$ [pix]', 'interpreter', 'latex');
    ylabel(ZENimage, '$y$ [pix]', 'interpreter', 'latex');
	
    %% Return handles
    handles = struct(...
        'microscope', microscope, ...
        'select',   select, ...
        'camera', camera, ...
        'connect', connect ...
	);
end

function initView(handles, model)
%% Initialize the view
%     onSettingsChange(handles, model);
end