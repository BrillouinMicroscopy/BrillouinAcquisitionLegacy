function [] = acquire(model)

%% Set the save path
path = 'RawData\';
filename = 'Test.h5';
if ~exist(path, 'dir')
    mkdir(path);
end

%% set scanning parameter
% name of the device (either 'LSM510' or 'XPS')
device = 'LSM510';

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
        xmin = model.settings.zeiss.startX;
        ymin = model.settings.zeiss.startY;
        xdiff = model.settings.zeiss.widthX;                 % [mikrometer] x-scanning range
        ydiff = model.settings.zeiss.widthY;                 % [mikrometer] y-scanning range
        centerposition = [xmin+xdiff/2 ymin+ydiff/2 0.0];        % [pix] start position
        x = linspace(centerposition(1) - xdiff/2, centerposition(1) + xdiff/2, resolutionX);
        y = linspace(centerposition(2) - ydiff/2, centerposition(2) + ydiff/2, resolutionY);
        z = linspace(centerposition(3) - zdiff/2, centerposition(3) + zdiff/2, resolutionZ);
    otherwise
        error('Stage type not known.');
end

[positionsX, positionsY, positionsZ] = meshgrid(x,y,z);

%% initialize stage
% get handle of the stage
zeiss = model.zeiss;
if ~exist('zeiss','var') || ~isa(zeiss,'ScanControl') || ~isvalid(zeiss)
    stage = Utils.ScanControl.ScanControl(device);
end

% move to start position
stage.position = [x(1), y(1), z(1)];

%% Open the HDF5 file for writing
% get the handle to the file or create the file
file = Utils.HDF5Storage.h5bmwrite([path filename]);
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
zyla.AOI.width = model.settings.andor.widthX;
zyla.AOI.left = model.settings.andor.startX;
zyla.AOI.height = model.settings.andor.widthY;
zyla.AOI.top = model.settings.andor.startY;

%% acquire images and move focus
disp('Aquisition started.');

%% Create frequency spectra image for every Pixel and save in HDF5 file
datestring = 'now';
totalImages = (model.settings.andor.nr*resolutionX*resolutionY*resolutionZ);
tic;
fig = figure(42);
for jj = 1:resolutionZ
    for kk = 1:resolutionY
        for ll = 1:resolutionX
            if ~model.settings.acquisition
                return
            end
            % move focus to desired position
            stage.position = [x(ll) y(kk) z(jj)];
            pause(0.1);

            % acquire and save image
            zyla.startAcquisition();
            images = NaN(model.settings.andor.widthX, model.settings.andor.widthY, model.settings.andor.nr);
            for mm = 1:model.settings.andor.nr
                buf = zyla.getBuffer();
                images(:,:,mm) = zyla.ConvertBuffer(buf);
                
                if ~ishandle(fig)
                    fig = figure(42);
                end
                set(0,'CurrentFigure',fig);
                imagesc(images(:,:,mm));
                caxis([100 300]);
                drawnow;

                finishedImages = ((jj-1)*(resolutionX*resolutionY*model.settings.andor.nr) + ...
                                  (kk-1)*resolutionX*model.settings.andor.nr + (ll-1)*model.settings.andor.nr + mm);
                remainingtime = toc/finishedImages *(totalImages-finishedImages);
                minutes = floor(remainingtime/60);
                seconds = floor(remainingtime - 60*minutes);
                clc;

                fprintf('Position  x/mm      y/mm      z/mm    Image\n        % 7.3f % 7.3f % 7.3f   % 4.0d\n', x(ll), y(kk), z(jj), mm);
                if minutes > 59
                    hours = floor(remainingtime/3600);
                    fprintf('Over %1.0f h remaining, %02.1f%% done.\n',hours,100*finishedImages/totalImages);
                else
                    fprintf('%02.0f:%02.0f min remaining, %02.1f%% done.\n',minutes,seconds,100*finishedImages/totalImages);
                end
            end
            zyla.stopAcquisition();
            
            file.writePayloadData(ll,kk,jj,images,'datestring',datestring);
        end
        pause(3);
    end
end
close(fig);

%% Close the HDF5 file
h5bmclose(file);

%% end aquisition and shut down camera
disp('Aquisition finished.');

delete(zyla);
disp('Camera shutdown.');

%% move to start position and close connection
% Return to home position
stage.init();

% Disconnect the stage
delete(stage);

end
