%% Configure parameters
% get the screen size
scaling = 1.5;          % scaling factor for high resolution devices
set(0,'units','pixels');
screenSize = scaling*get(0, 'screensize');

% parameters of the area to click in
areaPosition = [990; 118];
width = [1130; 1130];

% number of different positions
nrPositions = [5; 5];

%%
pos.x = areaPosition(1) + width(1)/(nrPositions(1)-1)*((1:nrPositions(1))-1);
pos.y = areaPosition(2) + width(2)/(nrPositions(2)-1)*((1:nrPositions(2))-1);

mouseMove = moveAndClick();

mouseMove.move(areaPosition(1), areaPosition(2));
for ii = 1:nrPositions(1)
    for jj = 1:nrPositions(2)
        mouseMove.move(pos.x(ii), pos.y(jj));
        mouseMove.click();
        pause(1);
    end
end
