classdef Model < handle
    %MODEL

    % observable properties, listeners are notified on change
    properties (SetObservable = true)
        andor;      % handle to the Andor camera
        zeiss;      % handle to the LSM system
        file;       % handle to the HDF5 file
        settings;   % handle to the settings
    end

    methods
        function obj = Model()
            obj.andor = [];
            obj.zeiss = [];
            obj.file = [];
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
        end
    end
end