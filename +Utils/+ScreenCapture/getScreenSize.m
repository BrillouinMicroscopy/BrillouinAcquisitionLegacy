function [screenSize] = getScreenSize()
%% function returns the physical screen size
    screen = java.awt.Toolkit.getDefaultToolkit().getScreenSize();
    screenSize = [NaN, NaN, screen.getWidth(), screen.getHeight()];
    if strcmp(get(0, 'Units'), 'pixels')
        screenSize(1) = 1;
        screenSize(2) = 1;
    else
        screenSize(1) = 0;
        screenSize(2) = 0;
    end 
end