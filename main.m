%% Change current location
fp = mfilename('fullpath');
[pathstr,name,ext] = fileparts(fp);
cd(pathstr);

%% Load the dependencies
includeDependencies();

%% set image parameter
ExTime = 0.1;               % [s]   exposure time for a songle image
NrImages = 10;              %       number of images to acquire at one position

% area of interest of the camera image
width = 300;               % [pix] width of the AOI
height = 350;              % [pix] height of the AOI
left = 650;                % [pix] distance of the AOI to the left
top = 1000;                % [pix] distance of the AOI to the top

%% Set the save path
path = 'd:\brillouin-microscopy\Messdaten\20160802\USAF\';
filename = 'Testchart01.h5';
if ~exist(path, 'dir')
    mkdir(path);
end

%% set scanning parameter
% name of the device (either 'LSM510' or 'XPS')
device = 'LSM510';

xdiff = 20;                 % [mikrometer] x-scanning range
ydiff = 20;                 % [mikrometer] y-scanning range
zdiff = 0;                  % [mikrometer] z-scanning range
resolutionX = 20;           % [1]   resolution in x-direction
resolutionY = 20;           % [1]   resolution in y-direction
resolutionZ = 1;            % [1]   resolution in z-direction

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
        centerposition = [1365 683 0.0];        % [mm] start position
        xdiff = 70;                 % [pix] x-scanning range
        ydiff = 70;                 % [pixel] y-scanning range
        x = linspace(centerposition(1) - xdiff/2, centerposition(1) + xdiff/2, resolutionX);
        y = linspace(centerposition(2) - ydiff/2, centerposition(2) + ydiff/2, resolutionY);
        z = linspace(centerposition(3) - zdiff/2, centerposition(3) + zdiff/2, resolutionZ);
    otherwise
        error('Stage type not known.');
end


[positionsX, positionsY, positionsZ] = meshgrid(x,y,z);

%% initialize stage
% get handle of the stage
if ~exist('stage','var') || ~isa(stage,'ScanControl')
    stage = ScanControl(device);
end

% move to start position
stage.position = [x(1), y(1), z(1)];

%% Open the HDF5 file for writing
% get the handle to the file or create the file
file = h5bmwrite([path filename]);
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
zyla = AndorControl();
disp('Camera initialized.');

%% set camera parameters
zyla.ExposureTime = ExTime;
zyla.CycleMode = 'Fixed';
zyla.TriggerMode = 'Internal';
zyla.SimplePreAmpGainControl = '16-bit (low noise & high well capacity)';
zyla.PixelEncoding = 'Mono16';
zyla.FrameCount = NrImages;

%% set area of interest
zyla.AOI.binning = '1x1';
zyla.AOI.width = width;
zyla.AOI.left = left;
zyla.AOI.height = height;
zyla.AOI.top = top;

%% get image size
imagesize = zyla.ImageSizeBytes;
height = zyla.AOI.height;
width = zyla.AOI.width;
stride = zyla.AOI.stride;

%% acquire images and move focus
disp('Aquisition started.');

%% Create frequency spectra image for every Pixel and save in HDF5 file
datestring = 'now';
t = 0;
totalPoints = (resolutionX*resolutionY*resolutionZ);
tic;
fig = figure;
for jj = 1:resolutionZ
    for kk = 1:resolutionY
        for ll = 1:resolutionX
            % move focus to desired position
            stage.position = [x(ll) y(kk) z(jj)];
            pause(0.1);

            % acquire and save image
            zyla.startAcquisition();
            images = NaN(width, height, NrImages);
            for mm = 1:NrImages
                buf = zyla.getBuffer();
                images(:,:,mm) = zyla.ConvertBuffer(buf);
            end
            zyla.stopAcquisition();

            set(0,'CurrentFigure',fig);
            imagesc(images(:,:,1));
            caxis([100 300]);
            drawnow;

            file.writePayloadData(ll,kk,jj,image,'datestring',datestring);
            
            finishedPoints = ((jj-1)*(resolutionX*resolutionY) + (kk-1)*resolutionX + ll);
            remainingtime = toc/finishedPoints *(totalPoints-finishedPoints);
            minutes = floor(remainingtime/60);
            seconds = floor(remainingtime - 60*minutes);
            clc;
            
            fprintf('Position  x/mm    y/mm    z/mm\n        % 7.3f % 7.3f % 7.3f\n', x(ll), y(kk), z(jj));
            if minutes > 59
                hours = floor(remainingtime/3600);
                strTime = fprintf('Over %1.0f h remaining, %02.1f%% done.\n',hours,100*finishedPoints/totalPoints);
            else
                strTime = fprintf('%02.0f:%02.0f min remaining, %02.1f%% done.\n',minutes,seconds,100*finishedPoints/totalPoints);
            end
        end
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
