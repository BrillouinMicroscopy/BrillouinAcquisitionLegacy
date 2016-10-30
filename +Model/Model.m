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
                    'x', 0, ...         % ROI - x
                    'y', 0, ...         % ROI - y
                    'width', 100, ...   % ROI - width
                    'height', 100, ...  % ROI - height
                    'exp', 0.1, ...     % exposure time
                    'nr', 1 ...         % number of images per position
                ), ...
                'zeiss', struct( ...
                    'screen', NaN, ...  % screenshot of ZEN
                    'x', 100, ...       % Scanarea - x
                    'y', 100, ...       % Scanarea - y
                    'z', 0, ...         % Scanarea - z
                    'resX', 20, ...     % Resolution - x
                    'resY', 20, ...     % Resolution - y
                    'resZ', 1, ...      % Resolution - z
                    'width', 100, ...   % Scanarea - width
                    'height', 100 ...   % Scanarea - height
                ) ...
            );
        end
    end
end