classdef objectYTrapezoid < virmenObject
    properties (SetObservable)
        bottom = 0;
        top = 10;
        theta = pi/6;
    end
    methods
        function obj = objectYTrapezoid
            obj.iconLocations = [0 0; 30 0; 30 -30];
        end
        function obj = getPoints(obj)
            [x y] = getline(gcf);
            if length(x)==1
                obj.x = [];
                obj.y = [];
            else
                obj.x = x;
                obj.y = y;
            end
        end
        function [x y] = coords2D(obj)
            x = obj.locations(:,1);
            y = obj.locations(:,2);
        end
        function objSurface = coords3D(obj)
            texture = tile(obj.texture,obj.tiling);
            
            x = texture.triangles.vertices(:,1);
            y = texture.triangles.vertices(:,2);
            x_norm = (x-min(x(:)))/range(x(:));
            dst = [0; sqrt(sum((obj.locations(2:end,:)-obj.locations(1:end-1,:)).^2,2))];
            pos = cumsum(dst);
            pos = pos/pos(end);
            X = zeros(size(x));
            Y = zeros(size(x));
            for ndx = 1:length(pos)-1
                f = find(x_norm(:)>=pos(ndx));
                X(f) = obj.locations(ndx,1)+(x_norm(f)-pos(ndx))/(pos(ndx+1)-pos(ndx))*(obj.locations(ndx+1,1)-obj.locations(ndx,1));
                Y(f) = obj.locations(ndx,2)+(x_norm(f)-pos(ndx))/(pos(ndx+1)-pos(ndx))*(obj.locations(ndx+1,2)-obj.locations(ndx,2));
            end
            Z = (y-min(y(:)))/range(y(:))*(obj.top-obj.bottom)+obj.bottom;
            
            X = X + sign(X).*(Z*tan(obj.theta));
            
            objSurface.vertices = [X Y Z];
            objSurface.cdata = texture.triangles.cdata;
            objSurface.triangulation = texture.triangles.triangulation;
        end
        function edges = edges(obj)
            edges = [obj.locations(1:end-1,:) obj.locations(2:end,:)];
        end
    end
end