%% Change current location
fp = mfilename('fullpath');
[pathstr,name,ext] = fileparts(fp);
cd(pathstr);

%% Load the dependencies
includeDependencies();

%% set image parameter
ExTime = 0.1;               % [s]   exposure time for a songle image

% area of interest of the camera image
width = 300;               % [pix] width of the AOI
height = 350;              % [pix] height of the AOI
left = 650;                 % [pix] distance of the AOI to the left
top = 1000;                  % [pix] distance of the AOI to the top

%% Set the save path
path = 'd:\brillouin-microscopy\Messdaten\20160718\USAF\';
if ~exist(path, 'dir')
    mkdir(path);
end

%% set scanning parameter
centerposition = [13.5 5.9 8.446];        % [mm] start position

xdiff = 600;                % [mikrometer] x-scanning range
ydiff = 600;                % [mikrometer] y-scanning range
zdiff = 0;                  % [mikrometer] z-scanning range
resolutionX = 40;           % [1]   resolution in x-direction
resolutionY = 40;           % [1]   resolution in y-direction
resolutionZ = 1;            % [1]   resolution in z-direction

x = linspace(centerposition(1) - 1e-3*xdiff/2, centerposition(1) + 1e-3*xdiff/2, resolutionX);
y = linspace(centerposition(2) - 1e-3*ydiff/2, centerposition(2) + 1e-3*ydiff/2, resolutionY);
z = linspace(centerposition(3) - 1e-3*zdiff/2, centerposition(3) + 1e-3*zdiff/2, resolutionZ);

[positionsX, positionsY, positionsZ] = meshgrid(x,y,z);

%% initialize stage
connection.IP = '192.168.0.254';    % IP Adress of the Controller
connection.Port = 5001;             % Port number of the Controller
connection.TimeOut = 60;            % Timeout to use

settings.velocity = 1;              % [mm/s]    velocity of the stage
settings.acceleration = 1;          % [mm/s^2]  acceleration of the stage

% Connect to the controller via TCP
% stage = XPS(connection.IP, connection.Port, connection.TimeOut);
% Initialize the home position of the stages
% stage.init();

% set parameters of the translation
stage.set(settings);

% move to start position
stage.position = [x(1), y(1), z(1)];

%% Open the HDF5 file for writing
% get the handle to the file or create the file
file = h5bmwrite([path 'Testchart07.h5']);
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
zyla.FrameCount = 1;

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
figure;
for jj = 1:resolutionZ
    for kk = 1:resolutionY
        for ll = 1:resolutionX
            % move focus to desired position
            stage.position = [x(ll) y(kk) z(jj)];

            % acquire and save image
            zyla.startAcquisition();
            buf = zyla.getBuffer();
            zyla.stopAcquisition();

            image = zyla.ConvertBuffer(buf);
            imagesc(image);
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

%% Close the HDF5 file
h5bmclose(file);

%% end aquisition and shut down camera
disp('Aquisition finished.');

delete(zyla);
disp('Camera shutdown.');

%% move to start position and close connection
% % Return to home position
% stage.init(false);
% 
% % Disconnect the stage
% delete(stage);
