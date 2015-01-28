classdef virmenWindow
    properties
        rendering3D = true;
        transformation = 1;
        primaryMonitor = true;
        monitor = 1;
        fullScreen = true;
        left = 0;
        bottom = 0;
        width = 300;
        height = 300;
        antialiasing = 0;
    end
    methods
        function val = get.transformation(obj)
            if ~obj.rendering3D;
                val = NaN;
            else
                val = obj.transformation;
            end
        end
        function val = get.monitor(obj)
            if obj.primaryMonitor
                val = NaN;
            else
                val = obj.monitor;
            end
        end
        function val = get.bottom(obj)
            if obj.fullScreen
                val = NaN;
            else
                val = obj.bottom;
            end
        end
        function val = get.left(obj)
            if obj.fullScreen
                val = NaN;
            else
                val = obj.left;
            end
        end
        function val = get.width(obj)
            if obj.fullScreen
                val = NaN;
            else
                val = obj.width;
            end
        end
        function val = get.height(obj)
            if obj.fullScreen
                val = NaN;
            else
                val = obj.height;
            end
        end
    end
end