%% Load the dependencies
includeDependencies();

%% set image parameter
ExTime = 0.1;               % [s]   exposure time for a songle image
FrameNumber = 11;           % [ ]   number of frames during the aquisition

% area of interest
width = 1000;               % [pix] width of the AOI
height = 1000;              % [pix] height of the AOI
left = 650;                 % [pix] distance of the AOI to the left
top = 750;                  % [pix] distance of the AOI to the top

path = 'd:\brillouin-microscopy\#Messdaten\FocusScan\M14_coll51_x164_y76_d50\';
if ~exist(path, 'dir')
    mkdir(path);
end

%% set focus scanning parameter
zdiff = 50;                 % [mikrometer]  scanning range

%% initialize microscope
zeiss = CANControl('COM1',9600);

startPos = zeiss.focus.z;
positionMin = startPos - zdiff/2;
stepSize = zdiff / (FrameNumber-1);

%% initialize camera
zyla = AndorControl();
disp('camera initialised');

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
disp('aqisition started');

for jj = 1:1:FrameNumber
    % move focus to desired position
    position = positionMin + (jj-1) * stepSize;
    zeiss.focus.z = position;
    pause(0.1);
    
    % acquire and save image
    zyla.startAcquisition();
    buf = zyla.getBuffer();
    zyla.stopAcquisition();
    
    image = zyla.ConvertBuffer(buf);
    imwrite(image,[path sprintf('image%03d.tiff',jj)]);
end 

%% end aquisition and shut down camera
disp('aquisition stopped');

zyla.delete();
disp('Camera shutdown');

%% move to start position and close connection
zeiss.focus.z = startPos;
delete(zeiss);
