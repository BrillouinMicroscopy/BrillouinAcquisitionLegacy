function handles = Configuration(parent, model)
%% CONFIGURATION View

    % build the GUI
    handles = initGUI(parent, model);
    initView(handles, model);    % populate with initial values

    % observe on model changes and update view accordingly
    % (tie listener to model object lifecycle)
    addlistener(model, 'settings', 'PostSet', ...
        @(o,e) onSettingsChange(handles, e.AffectedObject));
    addlistener(model, 'andor', 'PostSet', ...
        @(o,e) onConnectionChange(handles, e.AffectedObject));
end

function handles = initGUI(parent, model)
    %% Microscope panel
    microscope = uipanel('Parent', parent, 'Title', 'Microscope � Region of Interest', 'FontSize', 11,...
        'Position', [.02 .02 .47 .96]);

    selectROI_Microscope = uicontrol('Parent', microscope, 'Style','pushbutton', 'Units', 'normalized',...
        'String','Select ROI','Position',[0.72,0.94,0.25,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left');
    
    %% x-direction
    x = uipanel('Parent', microscope, 'Title', 'x-direction', 'FontSize', 11,...
        'Position', [.03 .71 .3 .225]);
    
    uicontrol('Parent', x, 'Style', 'text', 'String', 'Start', 'Units', 'normalized',...
        'Position', [0.05,0.65,0.96,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    startX = uicontrol('Parent', x, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.69,0.30,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'startX');
    
    uicontrol('Parent', x, 'Style', 'text', 'String', 'Width', 'Units', 'normalized',...
        'Position', [0.05,0.35,0.96,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    widthX = uicontrol('Parent', x, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.39,0.30,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'widthX');
    
    uicontrol('Parent', x, 'Style', 'text', 'String', 'Resolution', 'Units', 'normalized',...
        'Position', [0.05,0.05,0.6,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    resX = uicontrol('Parent', x, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.09,0.30,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'resX');
    
    %% y-direction
    y = uipanel('Parent', microscope, 'Title', 'y-direction', 'FontSize', 11,...
        'Position', [.35 .71 .3 .225]);
    
    uicontrol('Parent', y, 'Style', 'text', 'String', 'Start', 'Units', 'normalized',...
        'Position', [0.05,0.65,0.96,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    startY = uicontrol('Parent', y, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.69,0.30,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'startY');
    
    uicontrol('Parent', y, 'Style', 'text', 'String', 'Width', 'Units', 'normalized',...
        'Position', [0.05,0.35,0.96,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    widthY = uicontrol('Parent', y, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.39,0.30,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'widthY');
    
    uicontrol('Parent', y, 'Style', 'text', 'String', 'Resolution', 'Units', 'normalized',...
        'Position', [0.05,0.05,0.6,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    resY = uicontrol('Parent', y, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.09,0.30,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'resY');
    
    %% z-direction
    z = uipanel('Parent', microscope, 'Title', 'z-direction', 'FontSize', 11,...
        'Position', [.67 .71 .3 .225]);
    
    uicontrol('Parent', z, 'Style', 'text', 'String', 'Start', 'Units', 'normalized',...
        'Position', [0.05,0.65,0.96,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    startZ = uicontrol('Parent', z, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.69,0.30,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'startZ');
    
    uicontrol('Parent', z, 'Style', 'text', 'String', 'Width', 'Units', 'normalized',...
        'Position', [0.05,0.35,0.96,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    widthZ = uicontrol('Parent', z, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.39,0.30,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'widthZ');
    
    uicontrol('Parent', z, 'Style', 'text', 'String', 'Resolution', 'Units', 'normalized',...
        'Position', [0.05,0.05,0.6,0.25], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    resZ = uicontrol('Parent', z, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.09,0.30,0.25], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'resZ');
    
    set(findall(z, '-property', 'enable'), 'enable', 'off');
    
    %% screenshot
    screen = axes('Parent', microscope, 'Position', [0.12 .085 .85 .6]);
    hold on;
    set(screen, 'box', 'on');
    xlabel(screen, '$x$ [pix]', 'interpreter', 'latex');
    ylabel(screen, '$y$ [pix]', 'interpreter', 'latex');
    
    %% Camera panel
    camera = uipanel('Parent', parent, 'Title', 'Camera', 'FontSize', 11,...
        'Position', [.51 .02 .47 .96]);

    connect = uicontrol('Parent', camera, 'Style','pushbutton', 'Units', 'normalized',...
        'String','Connect','Position',[0.03,0.94,0.2,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left');

    disconnect = uicontrol('Parent', camera, 'Style','pushbutton', 'Units', 'normalized',...
        'String','Disconnect','Position',[0.24,0.94,0.2,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left', 'BackgroundColor', 'red');

    update = uicontrol('Parent', camera, 'Style','pushbutton', 'Units', 'normalized',...
        'CData', readTransparent('images/update.bmp'), 'Position',[0.74,0.94,0.11,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left', 'enable', 'off');

    play = uicontrol('Parent', camera, 'Style','pushbutton', 'Units', 'normalized',...
        'CData', readTransparent('images/play.bmp'), 'Position',[0.86,0.94,0.11,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left', 'enable', 'off');
    
    %% x-direction
    x_camera = uipanel('Parent', camera, 'Title', 'x-direction', 'FontSize', 11,...
        'Position', [.35 .775 .3 .160]);
    
    uicontrol('Parent', x_camera, 'Style', 'text', 'String', 'Start', 'Units', 'normalized',...
        'Position', [0.05,0.48,0.56,0.37], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    startX_camera = uicontrol('Parent', x_camera, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.53,0.30,0.37], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'startX');
    
    uicontrol('Parent', x_camera, 'Style', 'text', 'String', 'Width', 'Units', 'normalized',...
        'Position', [0.05,0.02,0.56,0.37], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    widthX_camera = uicontrol('Parent', x_camera, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.08,0.30,0.37], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'widthX');
    
    %% y-direction
    y_camera = uipanel('Parent', camera, 'Title', 'y-direction', 'FontSize', 11,...
        'Position', [.67 .775 .3 .160]);
    
    uicontrol('Parent', y_camera, 'Style', 'text', 'String', 'Start', 'Units', 'normalized',...
        'Position', [0.05,0.48,0.56,0.37], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    startY_camera = uicontrol('Parent', y_camera, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.53,0.30,0.37], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'startY');
    
    uicontrol('Parent', y_camera, 'Style', 'text', 'String', 'Width', 'Units', 'normalized',...
        'Position', [0.05,0.02,0.56,0.37], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    widthY_camera = uicontrol('Parent', y_camera, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.08,0.30,0.37], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'widthY');
    
    parameters_camera = uipanel('Parent', camera, 'Title', 'Parameters', 'FontSize', 11,...
        'Position', [.03 .775 .3 .160]);
    
    uicontrol('Parent', parameters_camera, 'Style', 'text', 'String', 'Exposure', 'Units', 'normalized',...
        'Position', [0.05,0.48,0.56,0.37], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    exp = uicontrol('Parent', parameters_camera, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.53,0.30,0.37], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'exp');
    
    uicontrol('Parent', parameters_camera, 'Style', 'text', 'String', 'Images', 'Units', 'normalized',...
        'Position', [0.05,0.02,0.56,0.37], 'FontSize', 11, 'HorizontalAlignment', 'left');
    
    nr = uicontrol('Parent', parameters_camera, 'Style', 'edit', 'Units', 'normalized',...
        'Position', [0.65,0.08,0.30,0.37], 'FontSize', 11, 'HorizontalAlignment', 'center', 'Tag', 'nr');
    
    zoomIn = uicontrol('Parent', camera, 'Style','pushbutton', 'Units', 'normalized',...
        'CData', readTransparent('images/zoomin.bmp'), 'Position',[0.03,0.71,0.075,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left');
    set(zoomIn, 'UserData', 0);
    
    zoomOut = uicontrol('Parent', camera, 'Style','pushbutton', 'Units', 'normalized',...
        'CData', readTransparent('images/zoomout.bmp'), 'Position',[0.12,0.71,0.075,0.055],...
        'FontSize', 11, 'HorizontalAlignment', 'left');
    set(zoomOut, 'UserData', 0);
    
    axesCamera = axes('Parent', camera, 'Position', [0.12 .085 .85 .6]);
    imageCamera = imagesc(axesCamera, flipud(model.settings.andor.image));
%     hold on;
    set(axesCamera, 'box', 'on');
    xlabel(axesCamera, '$x$ [pix]', 'interpreter', 'latex');
    ylabel(axesCamera, '$y$ [pix]', 'interpreter', 'latex');
    zoom(gcf,'reset')
    zoomHandle = zoom;
    colorbar;
	
    %% Return handles
    handles = struct(...
        'microscope', microscope, ...
        'select',   selectROI_Microscope, ...
        'camera',   camera, ...
        'connect',  connect, ...
        'disconnect', disconnect, ...
        'resX', resX, ...
        'resY', resY, ...
        'resZ', resZ, ...
        'startX', startX, ...
        'startY', startY, ...
        'startZ', startZ, ...
        'widthX', widthX, ...
        'widthY', widthY, ...
        'widthZ', widthZ, ...
        'screen', screen, ...
        'startX_camera', startX_camera, ...
        'startY_camera', startY_camera, ...
        'widthX_camera', widthX_camera, ...
        'widthY_camera', widthY_camera, ...
        'play', play, ...
        'update', update, ...
        'exp', exp, ...
        'nr', nr, ...
        'axesCamera', axesCamera, ...
        'imageCamera', imageCamera, ...
        'zoomIn', zoomIn, ...
        'zoomOut', zoomOut, ...
        'zoomHandle', zoomHandle ...
	);
end

function initView(handles, model)
%% Initialize the view
    onSettingsChange(handles, model);
end

function onConnectionChange(handles, model)
    if isa(model.andor,'Utils.AndorControl.AndorControl') && isvalid(model.andor)
        set(handles.connect, 'BackgroundColor', 'green');
        set(handles.disconnect, 'BackgroundColor', [0.94 0.94 0.94]);
        set(handles.update, 'enable', 'on');
        set(handles.play, 'enable', 'on');
    else
        set(handles.connect, 'BackgroundColor', [0.94 0.94 0.94]);
        set(handles.disconnect, 'BackgroundColor', 'red');
        set(handles.update, 'enable', 'off');
        set(handles.play, 'enable', 'off');
    end
end

function onSettingsChange(handles, model)
    %% Microscope settings
    set(handles.resX, 'String', model.settings.zeiss.resX);
    set(handles.resY, 'String', model.settings.zeiss.resY);
    set(handles.resZ, 'String', model.settings.zeiss.resZ);
    set(handles.startX, 'String', model.settings.zeiss.startX);
    set(handles.startY, 'String', model.settings.zeiss.startY);
    set(handles.startZ, 'String', model.settings.zeiss.startZ);
    set(handles.widthX, 'String', model.settings.zeiss.widthX);
    set(handles.widthY, 'String', model.settings.zeiss.widthY);
    set(handles.widthZ, 'String', model.settings.zeiss.widthZ);
    
    if ~isnan(model.settings.zeiss.screen)
        detailX = model.settings.zeiss.startX:(model.settings.zeiss.startX + model.settings.zeiss.widthX);
        detailY = model.settings.zeiss.startY:(model.settings.zeiss.startY + model.settings.zeiss.widthY);
        imagesc(handles.screen, flipud(model.settings.zeiss.screen(detailY,detailX, :)));
        axis(handles.screen, [0 model.settings.zeiss.widthX 0 model.settings.zeiss.widthY]);
    end
    
    %% Camera settings
    set(handles.startX_camera, 'String', model.settings.andor.startX);
    set(handles.startY_camera, 'String', model.settings.andor.startY);
    set(handles.widthX_camera, 'String', model.settings.andor.widthX);
    set(handles.widthY_camera, 'String', model.settings.andor.widthY);
    set(handles.exp, 'String', model.settings.andor.exp);
    set(handles.nr, 'String', model.settings.andor.nr);
    if ~isnan(model.settings.andor.image)
        imagesc(handles.axesCamera, flipud(model.settings.andor.image));
        colorbar;
        axis(handles.axesCamera, [model.settings.andor.startX ...
                                   model.settings.andor.startX + model.settings.andor.widthX ...
                                   model.settings.andor.startY ...
                                   model.settings.andor.startY + model.settings.andor.widthY]);
    end
    if model.settings.preview
        set(handles.play, 'CData', readTransparent('images/pause.bmp'));
    else
        set(handles.play, 'CData', readTransparent('images/play.bmp'));
    end
end

function img = readTransparent(file)
	img = imread(file);
    img = double(img)/255;
    index1 = img(:,:,1) == 225/255;
    index2 = img(:,:,2) == 225/255;
    index3 = img(:,:,3) == 225/255;
    
    indexWhite = index1+index2+index3==3;
    for idx = 1 : 3
       rgb = img(:,:,idx);     % extract part of the image
       rgb(indexWhite) = NaN;  % set the white portion of the image to NaN
       img(:,:,idx) = rgb;     % substitute the update values
    end
end