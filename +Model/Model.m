classdef Model < handle
    %MODEL

    % observable properties, listeners are notified on change
    properties (SetObservable = true)
        acquisition;    % settings for the acquisition view
        andor;      % handle to the Andor camera
        zeiss;      % handle to the LSM system
        filename;       % filename
        filenamebase;   % basic filename
        filepath;       % the path to the data files
        settings;   % handle to the settings
    end

    methods
        function obj = Model()
            obj.andor = [];
            obj.zeiss = [];
            obj.filenamebase = 'Brillouin';
            obj.filename = 'Brillouin';
            obj.acquisition = struct( ...
                'autoscale', true, ...
                'cap', 500, ...
                'floor', 100, ...
                'image', NaN(2000,2000) ...   % current camera image
            );
            obj.filepath = '';
            obj.settings = struct( ...
                'andor', struct( ...    % Camera Settings
                    'image', NaN(2000,2000), ...   % current camera image
                    'widthXdefault', 2048, ... % Image width
                    'widthYdefault', 2048, ... % Image height
                    'autoscale', true, ...     % autoscale caxis
                    'cap', 300, ...     % Clim maximum
                    'floor', 100, ...   % Clim minimum
                    'startX', 100, ...  % ROI - x
                    'startY', 100, ...  % ROI - y
                    'widthX', 100, ...  % ROI - width
                    'widthY', 100, ...  % ROI - height
                    'exp', 0.1, ...     % exposure time
                    'nr', 1 ...         % number of images per position
                ), ...
                'zeiss', struct( ...
                    'stage', 'Translation Stage', ...       % selected translation stage
                    'reflector', 1, ...                     % selected position of the reflector
                    'objective', 1, ...                     % selected position of the objective
                    'tubelens', 3, ...                      % selected position of the tubelens
                    'baseport', 1, ...                      % selected position of the baseport
                    'sideport', 2, ...                      % selected position of the sideport
                    'mirror', 1, ...                        % selected position of the mirror
                    'default', struct( ...
                        'reflector', 1, ...                     % default position of the reflector
                        'objective', 1, ...                     % default position of the objective
                        'tubelens', 3, ...                      % default position of the tubelens
                        'baseport', 1, ...                      % default position of the baseport
                        'sideport', 2, ...                      % default position of the sideport
                        'mirror', 1 ...                        % default position of the mirror
                    ), ...
                    'relative', true, ...       % Move relative
                    'screen', NaN, ...  % screenshot of ZEN
                    'startX', 100, ...  % start of scanarea - x
                    'startY', 100, ...  % start of scanarea - y
                    'startZ', 0, ...    % start of scanarea - z
                    'resX', 20, ...     % resolution - x
                    'resY', 20, ...     % resolution - y
                    'resZ', 1, ...      % resolution - z
                    'widthX', 100, ...  % width of scanarea - x
                    'widthY', 100, ...  % width of scanarea - y
                    'widthZ', 0 ...     % width of scanarea - z
                ), ...
                'acquisition', 0, ...
                'preview', 0 ...
            );
            obj.settings.zeiss.stages = {'Scanning Mirrors', 'Translation Stage'}; % translation stages 
            obj.settings.zeiss.reflectors = {1, 2, 3, 4, 5};    % positions of the reflector
            obj.settings.zeiss.objectives = {1, 2, 3, 4, 5, 6}; % positions of the objective
            obj.settings.zeiss.tubelenss = {1, 2, 3};          % positions of the tubelens
            obj.settings.zeiss.baseports = {1, 2, 3};           % positions of the baseport
            obj.settings.zeiss.sideports = {1, 2, 3};           % positions of the sideport
            obj.settings.zeiss.mirrors = {1, 2};                % positions of the mirror
        end
    end
end