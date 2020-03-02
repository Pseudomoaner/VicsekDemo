function cellDists = calcManhattanDistMat(Vfield,periodic)
%Exploits the triangle inequality to quickly figure out which pairs of
%cells need to have their separations explicitly calculated. Allows you to
%avoid square-rooting things too much.
%
%   INPUTS:
%       -Vfield: A VicsekField object, with fields xCells, yCells and
%       R.
%       -periodic: Whether or not the boundaries of your field are periodic
%       (wrap-around).
%
%   OUTPUTS:
%       -cellDists: (Actual) distances between objects, with NaNs in
%       locations where objects were sufficiently separated for their
%       explicit distances to be ignored.
%
%   Author: Oliver J. Meacock

x = Vfield.xCells;
y = Vfield.yCells;
upLim = Vfield.R*sqrt(2);

%Square matrices representing the distances of all pairs of objects in the
%x- and y-directions.
dX = repmat(x,1,size(x,1)) - repmat(x',size(x,1),1);
dY = repmat(y,1,size(y,1)) - repmat(y',size(y,1),1);

%Update x and y positions with their periodic values, if needed
if periodic
    Width = Vfield.xWidth;
    Height = Vfield.yHeight;
    boundX = Width/2;
    boundY = Height/2;
    
    periodX = abs(dX) > boundX; %These rods are closer in the wrap-around x direction.
    periodY = abs(dY) > boundY; %Likewise for y.
    
    %Find the distance between these segments in the wrap-around direction
    tmpX = dX(periodX);
    tmpY = dY(periodY);
    
    absX = abs(tmpX);
    sgnX = tmpX./absX;
    absY = abs(tmpY);
    sgnY = tmpY./absY;
    
    dX(periodX) = -sgnX.*(Width - absX);
    dY(periodY) = -sgnY.*(Height - absY);
end

%Manhattan distance between each pair of objects
manDist = abs(dX) + abs(dY);

%By triangle inequality, if Manhattan distance is less than the distance
%cut-off*sqrt(2), so too will be the Euclidean distance. Will include some cases
%where the Euclidean distance is actually lower than the real cut-off, but
%can eliminate those later.
closeDists = manDist < upLim;

cellDists = nan(size(dX));
cellDists(closeDists) = sqrt(dX(closeDists).^2 + dY(closeDists).^2);

cellDists(cellDists > Vfield.R) = nan;