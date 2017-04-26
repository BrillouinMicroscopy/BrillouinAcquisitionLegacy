function acquisition = Acquisition(model, view)
%% ACQUISITON Controller

    %% callbacks Acquisition
    set(view.acquisition.start, 'Callback', {@startAcquisition, model, view});
    
    set(view.acquisition.zoomIn, 'Callback', {@zoom, 'in', view});
    set(view.acquisition.zoomOut, 'Callback', {@zoom, 'out', view});
    set(view.acquisition.panButton, 'Callback', {@pan, view});
    
    set(view.acquisition.autoscale, 'Callback', {@toggleAutoscale, model, view});
    set(view.acquisition.cap, 'Callback', {@setCameraParameters, model});
    set(view.acquisition.floor, 'Callback', {@setCameraParameters, model});
    
    set(view.acquisition.increaseFloor, 'Callback', {@increaseClim, model});
    set(view.acquisition.decreaseFloor, 'Callback', {@decreaseClim, model});
    set(view.acquisition.increaseCap, 'Callback', {@increaseClim, model});
    set(view.acquisition.decreaseCap, 'Callback', {@decreaseClim, model});
    
    %% Callbacks for Live Calibration
    set(view.acquisition.postCalibration, 'Callback', {@toggleCalibrations, model});
    set(view.acquisition.continuousCalibration, 'Callback', {@toggleCalibrations, model});
    set(view.acquisition.preCalibration, 'Callback', {@toggleCalibrations, model});
    set(view.acquisition.calibrationSample, 'Callback', {@toggleCalibrations, model});
    
    set(view.acquisition.continuousCalibrationTime, 'Callback', {@setCalibrations, model});
    set(view.acquisition.nrCalibrationImages, 'Callback', {@setCalibrations, model});
    set(view.acquisition.exposureTimeCalibration, 'Callback', {@setCalibrations, model});
    
    set(view.acquisition.numberMeasurements, 'Callback', {@setCalibrations, model});
    set(view.acquisition.timeBetweenMeasurements, 'Callback', {@setCalibrations, model});
        
    acquisition = struct( ...
    ); 
end

function startAcquisition(~, ~, model, view)
    if isa(model.andor,'BA_Utils.AndorControl.AndorControl') && isvalid(model.andor)
        model.acquisition.acquisition = ~model.acquisition.acquisition;
        if model.acquisition.acquisition
            if model.settings.preview
                model.settings.preview = 0;
                model.andor.stopAcquisition();
            end
            
            mesTic = tic;
            for gg = 1:model.acquisition.numberMeasurements
                if gg > 1
                    while(toc(mesTic) < model.acquisition.timeBetweenMeasurements * 60)
                        pause(5);
                    end
                end
                mesTic = tic;
                acquire(model, view);
            end
            model.acquisition.acquisition = 0;
        end
    else
        model.acquisition.acquisition = 0;
        disp('Please connect to the camera first.');
    end
end

function acquire(model, view)

    %% Set the save path
    path = 'RawData\';
    if ~exist(path, 'dir')
        mkdir(path);
    end

    model.filepath = [path model.filenamebase];
    model.filename = model.filenamebase;
    jj = 0;
    while exist([model.filepath '.h5'], 'file') || exist([model.filepath '.mat'], 'file')
        model.filename = [model.filenamebase sprintf('-%1d', jj)];
        model.filepath = [path model.filename];
        jj = jj + 1;
    end

    settings = model.settings; %#ok<NASGU>
    save([model.filepath '.mat'], 'settings');

    %% set scanning parameter
    % name of the device (either 'LSM510' or 'XPS')
    device = 'LSM510';
    %% initialize stage
    % get handle of the stage
    zeiss = model.zeiss;
    startPosition = zeiss.position;

    xdiff = model.settings.zeiss.widthX;                 % [mikrometer] x-scanning range
    ydiff = model.settings.zeiss.widthY;                 % [mikrometer] y-scanning range
    zdiff = model.settings.zeiss.widthZ;                  % [mikrometer] z-scanning range
    resolutionX = model.settings.zeiss.resX;           % [1]   resolution in x-direction
    resolutionY = model.settings.zeiss.resY;           % [1]   resolution in y-direction
    resolutionZ = model.settings.zeiss.resZ;            % [1]   resolution in z-direction

    switch (device)
        case 'XPS'
            % positions when working with XPS
            centerposition = [13.43 6.127 0.0];        % [mm] start position
            x = linspace(centerposition(1) - 1e-3*xdiff/2, centerposition(1) + 1e-3*xdiff/2, resolutionX);
            y = linspace(centerposition(2) - 1e-3*ydiff/2, centerposition(2) + 1e-3*ydiff/2, resolutionY);
            z = linspace(centerposition(3) - 1e-3*zdiff/2, centerposition(3) + 1e-3*zdiff/2, resolutionZ);
        case 'LSM510'
            % positions when working with LSM510, in pixels on screen. For now no
            % conversion to actual position in mikrometer
            switch model.settings.zeiss.stage
                case 'Translation Stage'
                    xmin = model.settings.zeiss.startX;
                    ymin = model.settings.zeiss.startY;
                    zmin = model.settings.zeiss.startZ;
                    xdiff = model.settings.zeiss.widthX;                 % [mikrometer] x-scanning range
                    ydiff = model.settings.zeiss.widthY;                 % [mikrometer] y-scanning range
                    zdiff = model.settings.zeiss.widthZ;                 % [mikrometer] y-scanning range
                    centerposition = [xmin+xdiff/2 ymin+ydiff/2 zmin+zdiff/2];        % [pix] start position
                    x = linspace(centerposition(1) - xdiff/2, centerposition(1) + xdiff/2, resolutionX);
                    y = linspace(centerposition(2) - ydiff/2, centerposition(2) + ydiff/2, resolutionY);
                    z = linspace(centerposition(3) - zdiff/2, centerposition(3) + zdiff/2, resolutionZ);
                    if model.settings.zeiss.relative
                        x = x + startPosition(1);
                        y = y + startPosition(2);
                        z = z + startPosition(3);
                    end
                case 'Scanning Mirrors'
                    xmin = model.settings.zeiss.startX;
                    ymin = model.settings.zeiss.startY;
                    xdiff = model.settings.zeiss.widthX;                 % [mikrometer] x-scanning range
                    ydiff = model.settings.zeiss.widthY;                 % [mikrometer] y-scanning range
                    centerposition = [xmin+xdiff/2 ymin+ydiff/2 0.0];        % [pix] start position
                    x = linspace(centerposition(1) - xdiff/2, centerposition(1) + xdiff/2, resolutionX);
                    y = linspace(centerposition(2) - ydiff/2, centerposition(2) + ydiff/2, resolutionY);
                    z = linspace(centerposition(3) - zdiff/2, centerposition(3) + zdiff/2, resolutionZ);
            end
        otherwise
            error('Stage type not known.');
    end

    [positionsX, positionsY, positionsZ] = meshgrid(x,y,z);

    % move to start position
    zeiss.position = [x(1), y(1), z(1)];

    %% Open the HDF5 file for writing
    % get the handle to the file or create the file
    file = BA_Utils.HDF5Storage.h5bmwrite([model.filepath '.h5']);
    % set the date attribute
    file.date = 'now';
    % set the comment
    file.comment = sprintf('This file contains image data scanned at the self build confocal microscope.');
    % set the resolution in x-direction
    file.resolutionX = resolutionX;
    % set the resolution in y-direction
    file.resolutionY = resolutionY;
    % set the resolution in z-direction
    file.resolutionZ = resolutionZ;
    % set the positions in x-direction
    file.positionsX = positionsX;
    % set the positions in y-direction
    file.positionsY = positionsY;
    % set the positions in z-direction
    file.positionsZ = positionsZ;

    % write background data
    n = isnan(model.calibration.images.background);
    if sum(n(:)) < numel(model.calibration.images.background)
        file.writeBackgroundData(model.calibration.images.background,'datestring','now');
    else
        disp('No background image available.');
    end

    %% write calibration data
    calibrationNumber = 1;
    samples = struct( ...
        'methanol', 3.799, ...
        'water', 5.088, ...
        'pmma', 10.64 ...
    );
    s = fields(samples);
    for jj = 1:length(s)
        sample = s{jj};
        bs = samples.(sample);
        n = isnan(model.calibration.images.(sample));
        if sum(n(:)) < numel(model.calibration.images.(sample))
            file.writeCalibrationData(calibrationNumber,model.calibration.images.(sample),bs,'datestring','now','sample',sample);
            calibrationNumber = calibrationNumber + 1;
        else
            disp(['No calibration for ' sample ' available.']);
        end
    end

    %% initialize camera
    zyla = model.andor;
    disp('Camera initialized.');

    %% set camera parameters
    zyla.ExposureTime = model.settings.andor.exp;
    zyla.CycleMode = 'Fixed';
    zyla.TriggerMode = 'Internal';
    zyla.SimplePreAmpGainControl = '16-bit (low noise & high well capacity)';
    zyla.PixelEncoding = 'Mono16';
    zyla.FrameCount = model.settings.andor.nr;

    %% set area of interest
    zyla.AOI.binning = '1x1';
    zyla.AOI.width = model.settings.andor.widthY;
    zyla.AOI.left = model.settings.andor.startY;
    zyla.AOI.height = model.settings.andor.widthX;
    zyla.AOI.top = model.settings.andor.startX;

    %% acquire images and move focus
    disp('Aquisition started.');

    %% Create frequency spectra image for every Pixel and save in HDF5 file
    datestring = 'now';
    finishedImages = 0;
    totalImages = (model.settings.andor.nr*resolutionX*resolutionY*resolutionZ);
    view.acquisition.progressBar.setValue(0);
    view.acquisition.calibrationProgressBar.setValue(0);
    if model.acquisition.preCalibration && model.acquisition.acquisition
       %% do live calibration
       calibrationNumber = liveCalibration(model, view, file, calibrationNumber);
    end
    totalTic = tic;
    calTic = tic;

    for jj = 1:resolutionZ
        if ~model.acquisition.acquisition
            break
        end
        for kk = 1:resolutionY
            if ~model.acquisition.acquisition
                break
            end
            if model.acquisition.continuousCalibration && model.acquisition.acquisition
                %% do live calibration
                % do a continous calibration every
                % "model.acquisition.continuousCalibrationTime" minutes
                if (toc(calTic) > model.acquisition.continuousCalibrationTime * 60)
                    calibrationNumber = liveCalibration(model, view, file, calibrationNumber);
                    calTic = tic;
                end
            end
            for ll = 1:resolutionX
                if ~model.acquisition.acquisition
                    break
                end
                % move focus to desired position
                zeiss.position = [x(ll) y(kk) z(jj)];
                pause(0.2);

                % acquire and save image
                zyla.startAcquisition();
                images = NaN(model.settings.andor.widthY, model.settings.andor.widthX, model.settings.andor.nr);
                for mm = 1:model.settings.andor.nr
                    if ~model.acquisition.acquisition
                        break
                    end
                    buf = zyla.getBuffer();
                    images(:,:,mm) = zyla.ConvertBuffer(buf);

                    imagesc(view.acquisition.axesCamera,images(:,:,mm));
                    colorbar(view.acquisition.axesCamera);
                    % its necessary to set the caxis again, when imagesc is
                    % called (not necessary with set CDATA)
                    if model.acquisition.autoscale
                        caxis(view.acquisition.axesCamera,'auto');
                    else
                        caxis(view.acquisition.axesCamera,[model.acquisition.floor model.acquisition.cap]);
                    end
                    drawnow;

                    finishedImages = ((jj-1)*(resolutionX*resolutionY*model.settings.andor.nr) + ...
                                      (kk-1)*resolutionX*model.settings.andor.nr + (ll-1)*model.settings.andor.nr + mm);
                    remainingtime = toc(totalTic)/finishedImages *(totalImages-finishedImages);
                    minutes = floor(remainingtime/60);
                    seconds = floor(remainingtime - 60*minutes);

                    posX = sprintf('%1.2f', x(ll)-startPosition(1));
                    posY = sprintf('%1.2f', y(kk)-startPosition(2));
                    posZ = sprintf('%1.2f', z(jj)-startPosition(3));

                    set(view.acquisition.posX, 'String', posX);
                    set(view.acquisition.posY, 'String', posY);
                    set(view.acquisition.posZ, 'String', posZ);

                    set(view.acquisition.imgNr, 'String', sprintf('%1.0d', mm));

                    if minutes > 59
                        hours = floor(remainingtime/3600);
                        str = sprintf('%02.1f%% completed, over %1.0f h left.', 100*finishedImages/totalImages, hours);
                    else
                        str = sprintf('%02.1f%% completed, %02.0f:%02.0f min left.',100*finishedImages/totalImages,minutes,seconds);
                    end
                    view.acquisition.progressBar.setValue(100*finishedImages/totalImages);
                    view.acquisition.progressBar.setString(str);
                    cal = toc(calTic) / (model.acquisition.continuousCalibrationTime * 0.6);
                    view.acquisition.calibrationProgressBar.setValue(cal);
                    view.acquisition.calibrationProgressBar.setString('Time to next calibration.');
                end
                zyla.stopAcquisition();

                file.writePayloadData(ll,kk,jj,images,'datestring',datestring);
            end
            if strcmp(model.settings.zeiss.stage , 'Scanning Mirrors')
                pause(3);
            end
        end
    end
    if model.acquisition.postCalibration && model.acquisition.acquisition
       %% do live calibration
       liveCalibration(model, view, file, calibrationNumber);
    end

    %% Show result
    if finishedImages/totalImages == 1
        result = 'Acquisition finished.';
    else
        result = 'Acquisition aborted.';
    end
    view.acquisition.progressBar.setString(result);
    view.acquisition.calibrationProgressBar.setString(result);

    %% Close the HDF5 file
    BA_Utils.HDF5Storage.h5bmclose(file);

    %% move to start position and close connection
    % Return to home position
    zeiss.position = [startPosition(1), startPosition(2), startPosition(3)];
    zeiss.init();
end

function calibrationNumber = liveCalibration(model, view, file, calibrationNumber)
    %% function acquires a calibration
    view.acquisition.calibrationProgressBar.setValue(100);
    view.acquisition.calibrationProgressBar.setString('Acquire live calibration.');
    % store position of the sideport
    sideport = model.zeiss.device.can.stand.sideport;
    % set sideport to position 3
    model.zeiss.device.can.stand.sideport = 3;
    pause(1);
    
    % acquire calibration images
    zyla = model.andor;
    % set frame count and exposure time to calibration settings
    zyla.FrameCount = model.acquisition.nrCalibrationImages;
    zyla.ExposureTime = model.acquisition.exposureTimeCalibration;
    zyla.startAcquisition();
    images = NaN(model.settings.andor.widthY, model.settings.andor.widthX, model.acquisition.nrCalibrationImages);
    for mm = 1:model.acquisition.nrCalibrationImages
        if ~model.acquisition.acquisition
            break
        end
        drawnow;
        buf = zyla.getBuffer();
        images(:,:,mm) = zyla.ConvertBuffer(buf);
        
        imagesc(view.acquisition.axesCamera,images(:,:,mm));
        colorbar(view.acquisition.axesCamera);
        % its necessary to set the caxis again, when imagesc is
        % called (not necessary with set CDATA)
        if model.acquisition.autoscale
            caxis(view.acquisition.axesCamera,'auto');
        else
            caxis(view.acquisition.axesCamera,[model.acquisition.floor model.acquisition.cap]);
        end
        drawnow;
    end
    zyla.stopAcquisition();
    
    % reset frame count and exposure time
    zyla.FrameCount = model.settings.andor.nr;
    zyla.ExposureTime = model.settings.andor.exp;
    
    % find sample name and corresponding Brillouin shift
    samples = struct( ...
        'water', 5.088, ...
        'methanol', 3.799, ...
        'pmma', 10.64 ...
    );
    s = fields(samples);
    sample = s{model.acquisition.calibrationSample};
    bs = samples.(sample);
    
    % write calibration images to file
    file.writeCalibrationData(calibrationNumber,images,bs,'datestring','now','sample',sample);
    
    % restore position of the sideport
    model.zeiss.device.can.stand.sideport = sideport;
    calibrationNumber = calibrationNumber + 1;
    pause(1);
end

function setCameraParameters(UIControl, ~, model)
    field = get(UIControl, 'Tag');
    model.acquisition.(field) = str2double(get(UIControl, 'String'));
end

function toggleAutoscale(~, ~, model, view)
    model.acquisition.autoscale = get(view.acquisition.autoscale, 'Value');
end

function toggleCalibrations(src, ~, model)
    model.acquisition.(get(src, 'Tag')) = get(src, 'Value');
end

function setCalibrations(src, ~, model)
    model.acquisition.(get(src, 'Tag')) = str2double(get(src, 'String'));
end

function zoom(src, ~, str, view)
switch get(src, 'UserData')
    case 0
        set(view.acquisition.panButton,'UserData',0);
        set(view.acquisition.panHandle,'Enable','off');
        switch str
            case 'in'
                set(view.acquisition.zoomHandle,'Enable','on','Direction','in');
                set(view.acquisition.zoomIn,'UserData',1);
                set(view.acquisition.zoomOut,'UserData',0);
            case 'out'
                set(view.acquisition.zoomHandle,'Enable','on','Direction','out');
                set(view.acquisition.zoomOut,'UserData',1);
                set(view.acquisition.zoomIn,'UserData',0);
        end
    case 1
        set(view.acquisition.zoomHandle,'Enable','off','Direction','in');
        set(view.acquisition.zoomOut,'UserData',0);
        set(view.acquisition.zoomIn,'UserData',0);
end
        
end

function pan(src, ~, view)
    set(view.acquisition.zoomOut,'UserData',0);
    set(view.acquisition.zoomIn,'UserData',0);
    switch get(src, 'UserData')
        case 0
            set(view.acquisition.panButton,'UserData',1);
            set(view.acquisition.panHandle,'Enable','on');
        case 1
            set(view.acquisition.panButton,'UserData',0);
            set(view.acquisition.panHandle,'Enable','off');
    end
end

function decreaseClim(UIControl, ~, model)
    model.acquisition.autoscale = 0;
    field = get(UIControl, 'Tag');
    dif = abs(0.1*(model.acquisition.cap - model.acquisition.floor));
    model.acquisition.(field) = model.acquisition.(field) - dif;
end

function increaseClim(UIControl, ~, model)
    model.acquisition.autoscale = 0;
    field = get(UIControl, 'Tag');
    dif = abs(0.1*(model.acquisition.cap - model.acquisition.floor));
    model.acquisition.(field) = model.acquisition.(field) + dif;
end