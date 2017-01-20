function handles = Tabs(model)
%% TABS View

    % build the GUI
    handles = initGUI(model);
end

function handles = initGUI(model)
    f = figure('Visible','off','Position',[2750,300,900,650]);
    % hide the menubar and prevent resizing
    set(f, 'menubar', 'none', 'Resize','off');
    
    % create the tabgroup for loading, calibrating and evaluating
    tabgroup = uitabgroup('Parent', f);
    configuration = uitab('Parent', tabgroup, 'Title', 'Configuration');
    calibration = uitab('Parent', tabgroup, 'Title', 'Calibration');
    acquisition = uitab('Parent', tabgroup, 'Title', 'Acquisition');
    
    configuration = BA_View.Configuration(configuration, model);
    calibration = BA_View.Calibration(calibration, model);
    acquisition = BA_View.Acquisition(acquisition, model);
                 
    % Assign the name to appear in the window title.
    f.Name = 'Brillouin Acquisition';

    % Move the window to the center of the screen.
    movegui(f,'center')

    % Make the window visible.
    f.Visible = 'on';
    
    % return a structure of GUI handles
    handles = struct(...
        'figure', f, ...
        'configuration', configuration, ...
        'calibration', calibration, ...
        'acquisition', acquisition ...
    );
end