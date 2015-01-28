function vrWorld = loadVirmenWorld(world)

[objSurface objVertices objTriangles] = world.coords3D;
vrWorld.surface.vertices = objSurface.vertices';
vrWorld.surface.triangulation = int32(flipud(objSurface.triangulation')-1);
vrWorld.surface.visible = true(1,size(objSurface.triangulation,1));
vrWorld.surface.colors = objSurface.cdata';

switch world.transparency
    case 0
        if size(vrWorld.surface.colors,1) == 4
            vrWorld.surface.colors(4,:) = [];
        end
    case 1
        if size(vrWorld.surface.colors,1) == 3
            vrWorld.surface.colors(4,:) = 1;
        else
            vrWorld.surface.colors(4,isnan(vrWorld.surface.colors(4,:))) = 1-eps;
        end
end

vrWorld.objects.indices = [];
for obj = 1:length(world.objects)
    vrWorld.objects.indices.(world.objects{obj}.name) = obj;
    
end
vrWorld.objects.vertices = objVertices;
vrWorld.objects.triangles = objTriangles;
edges = zeros(0,4);
radius = zeros(0,1);
vrWorld.objects.edges  = zeros(length(world.objects),2);
for obj = 1:length(world.objects)
    r = world.objects{obj}.edgeRadius;
    if isnan(r)
        continue
    end
    edges = [edges; world.objects{obj}.edges]; %#ok<AGROW>
    numEdges = size(world.objects{obj}.edges,1);
    radius = [radius; repmat(r,numEdges,1)]; %#ok<AGROW>
    if obj == 1
        vrWorld.objects.edges(obj,1) = 1;
    else
        vrWorld.objects.edges(obj,1) = max(vrWorld.objects.edges(1:obj-1,2))+1;
    end
    vrWorld.objects.edges(obj,2) = size(edges,1);
end
vrWorld.edges.endpoints = edges;
vrWorld.edges.radius = radius;
vrWorld.backgroundColor = world.backgroundColor;
vrWorld.startLocation = world.startLocation;