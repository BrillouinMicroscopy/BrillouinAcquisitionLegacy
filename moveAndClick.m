classdef moveAndClick < handle
%MOVEANDCLICK move cursor and perform a left click
%
%   [] = moveAndClick(positionX, positionY) moves the cursor to the desired
%   coordinates and performs a left click
%
    properties (Access = private)
        robot;
        leftClick;
    end

    methods
        %% Constructor
        function obj = moveAndClick()
            import java.awt.Robot;
            import java.awt.event.InputEvent;
            obj.robot = Robot;
            obj.leftClick = InputEvent.BUTTON1_MASK;
        end

        %% Destructor
        function delete (~)
        end

        function move (obj, positionX, positionY)
            % move mouse to requested position
            obj.robot.mouseMove(positionX, positionY);
        end
        
        function click (obj)
            % click on the current position
            obj.robot.mousePress(obj.leftClick);
            obj.robot.mouseRelease(obj.leftClick);
        end
    end
end