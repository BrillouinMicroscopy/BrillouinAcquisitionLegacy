classdef Model < handle
    %MODEL

    % observable properties, listeners are notified on change
    properties (SetObservable = true)
        acquisition;    % settings for the acquisition view
        cooling;        % status of the sensor cooling
        coolingTimer;   % timer to update the cooling status
        calibration;    % calibration and background data
        pp;         % path to the program
        andor;      % handle to the Andor camera
        zeiss;      % handle to the LSM system
        filename;       % filename
        filenamebase;   % basic filename
        filepath;       % the path to the data files
        settings;   % handle to the settings
        sharedFunctions;    % functions shared among views and controllers
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
            obj.cooling = struct( ...
                'SensorCooling', 0, ...
                'SensorTemperatureStatus', 'Cooler Off', ...
                'SensorTemperature', 26.54 ...
            );
            obj.coolingTimer = timer( ...
                'Period',       2,...
                'StartDelay',   0,...
                'ExecutionMode','fixedRate',...
                'TimerFcn',     {@obj.updateCooling} ...
            );
            obj.calibration = struct( ...
                'autoscale', true, ...
                'cap', 500, ...
                'floor', 100, ...
                'selected', 'background', ...
                'imgNr', 1, ...
                'nrImg', 10, ...
                'images', struct( ...
                    'background', NaN(10,10,1), ...
                    'methanol', NaN(10,10,1), ...
                    'water', NaN(10,10,1) ...
                ), ...
                'acquisition', 0 ...
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
                    'stage', 'Translation Stage', ...   % selected translation stage
                    'reflector', 1, ...                 % selected position of the reflector
                    'objective', 1, ...                 % selected position of the objective
                    'tubelens', 3, ...                  % selected position of the tubelens
                    'baseport', 1, ...                  % selected position of the baseport
                    'sideport', 2, ...                  % selected position of the sideport
                    'mirror', 1, ...                    % selected position of the mirror
                    'presets', struct( ...
                        'brillouin', struct( ...        % Preset for observation with the Brillouin microscope
                            'name', 'Brillouin', ...    % name of the preset
                            'reflector', 1, ...         % position of the reflector
                            'objective', 1, ...         % position of the objective
                            'tubelens', 3, ...          % position of the tubelens
                            'baseport', 1, ...          % position of the baseport
                            'sideport', 2, ...          % position of the sideport
                            'mirror', 1 ...             % position of the mirror
                        ), ...
                        'brightfield', struct( ...      % Preset for the eyepiece of the Microscope
                            'name', 'Brightfield', ...  % name of the preset
                            'reflector', 1, ...         % position of the reflector
                            'objective', 1, ...         % position of the objective
                            'tubelens', 3, ...          % position of the tubelens
                            'baseport', 1, ...          % position of the baseport
                            'sideport', 2, ...          % position of the sideport
                            'mirror', 2 ...             % position of the mirror
                        ), ...
                        'eyepiece', struct( ...         % Preset for the eyepiece of the Microscope
                            'name', 'Eyepiece', ...     % name of the preset
                            'reflector', 1, ...         % position of the reflector
                            'objective', 1, ...         % position of the objective
                            'tubelens', 3, ...          % position of the tubelens
                            'baseport', 2, ...          % position of the baseport
                            'sideport', 3, ...          % position of the sideport
                            'mirror', 2 ...             % position of the mirror
                        ) ...
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
                'preview', 0, ...
                'update', 0 ...
            );
            obj.calibration.samples = {'None (Background)', 'Water', 'Methanol'};
            obj.settings.zeiss.stages = {'Scanning Mirrors', 'Translation Stage'}; % translation stages
            obj.settings.zeiss.reflectors = {1, 2, 3, 4, 5};    % positions of the reflector
            obj.settings.zeiss.objectives = {1, 2, 3, 4, 5, 6}; % positions of the objective
            obj.settings.zeiss.tubelenss = {1, 2, 3};           % positions of the tubelens
            obj.settings.zeiss.baseports = {1, 2, 3};           % positions of the baseport
            obj.settings.zeiss.sideports = {1, 2, 3};           % positions of the sideport
            obj.settings.zeiss.mirrors = {1, 2};                % positions of the mirror
        end
        
        %% function to query the cooling status and update the model
        function updateCooling(obj, ~, ~)
            tmp = struct();
            tmp.SensorCooling = obj.andor.SensorCooling;
            tmp.SensorTemperatureStatus = obj.andor.SensorTemperatureStatus;
            tmp.SensorTemperature = obj.andor.SensorTemperature;
            obj.cooling = tmp;
        end
    end
end