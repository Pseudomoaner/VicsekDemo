classdef VicsekField
    properties
        xWidth %Width of field
        yHeight %Height of field
        
        xCells %Storage for x positions of rods
        yCells %Storage for y positions of rods
        cCells %Storage for colours of rods
        thetCells %Storage for directions of motion of rods
        cellDists %Current distance matrix for the system
        
        rho %Current density of system
        R %Neighbourhood radius
        dt %Timestep size
    end
    methods
        function obj = VicsekField(xWidth,yHeight,R,dt)
            if isnumeric(xWidth) && xWidth > 0 && isnumeric(yHeight) && yHeight > 0
                obj.xWidth = xWidth;
                obj.yHeight= yHeight;
                obj.R = R;
                obj.dt = dt;
                
                obj.xCells = [];
                obj.yCells = [];
                obj.thetCells = [];
                obj.cCells = [];
                obj.rho = 0;
            else
                error('Input arguments to VicsekField are not valid');
            end
        end
        
        function obj = changeRho(obj,tgtRho)
            %Ensure that the actual value of rho corresponds to an integer number of rods 
            tgtN = round(tgtRho*(obj.xWidth*obj.yHeight));
            newRho = tgtN/(obj.xWidth*obj.yHeight);
            oldN = round(obj.rho*(obj.xWidth*obj.yHeight));
            
            DN = oldN-tgtN;
            
            if DN < 0 %If new rho is greater than previously, add rods
                obj.xCells = [obj.xCells;rand(-DN,1)*obj.xWidth];
                obj.yCells = [obj.yCells;rand(-DN,1)*obj.yHeight];
                obj.thetCells = [obj.thetCells;(rand(-DN,1)*2*pi)-pi];
                obj.cCells = [obj.cCells;zeros(-DN,3)];
            elseif DN > 0 %If new rho is less than previously, remove rods
                obj.xCells = obj.xCells(1:tgtN);
                obj.yCells = obj.yCells(1:tgtN);
                obj.thetCells = obj.thetCells(1:tgtN);
            end %Otherwise, do nothing to the rod number
            
            obj.rho = newRho;
        end
        
        function obj = stepModel(obj,eta,v)
            %Increases the time by one step, updating cell positions based on their current velocities.
            
            %Calculate average neighbour orientations
            neighIDs = obj.compileNeighbors();
            avgOris = zeros(size(obj.xCells,1),1);
            for i = 1:size(obj.xCells,1)
                avgSin = mean(sin(obj.thetCells(neighIDs{i})));
                avgCos = mean(cos(obj.thetCells(neighIDs{i})));
                avgOris(i) = atan2(avgSin,avgCos);
            end
            
            %Update orientations, then move everything
            obj.thetCells = avgOris + ((rand(size(obj.xCells))*eta) - eta/2);
            obj.xCells = obj.xCells + cos(obj.thetCells)*obj.dt*v;
            obj.yCells = obj.yCells + sin(obj.thetCells)*obj.dt*v;
            
            obj.thetCells = mod(obj.thetCells + pi,2*pi)-pi;
            obj.xCells = mod(obj.xCells,obj.xWidth);
            obj.yCells = mod(obj.yCells,obj.yHeight);
        end
        
        function neighIDs = compileNeighbors(obj)
            obj.cellDists = calcManhattanDistMat(obj,true);
            neighIDs = cell(size(obj.xCells,1),1);
            for i = 1:size(obj.xCells,1)
                neighIDs{i} = find(obj.cellDists(i,:)<obj.R);
            end
        end
        
        function obj = setColours(obj,colourCells)
            %Sets the colours of the cells according to position.
            %Do any cell colouration steps here
            switch colourCells
                case 'Orientation'
                    map = colormap('hsv');
                    newColors = zeros(size(obj.cCells));
                    for k = 1:size(obj.cCells,1)
                        bin = ceil((mod(obj.thetCells(k)+pi,2*pi)/(2*pi)) * size(map,1));
                        newColors(k,:) = map(bin,:);
                    end
                    obj.cCells = newColors;
                case 'Position'
                    for k = 1:size(obj.cCells,1)
                        xFac = obj.xCells(k)/obj.xWidth;
                        yFac = obj.yCells(k)/obj.yHeight;
                        obj.cCells(k,:) = [xFac,1,yFac];
                    end
            end
        end
        
        function drawFieldFast(obj,axHand)
            %Draws the current state of the model - location and angles of all cells in model.
            v = cos(obj.thetCells);
            u = sin(obj.thetCells);
            
            cla(axHand)
            quiver(axHand,obj.xCells,obj.yCells,v,u,0,'Color','k');
            
            axis(axHand,'equal')
            axis(axHand,[0,obj.xWidth,0,obj.yHeight])
        end
        
        function drawFieldFancy(obj,axHand)
            %Draws the current state of the model - location and angles of all cells in model.
            %This version is designed to be used when individual agents are
            %hard to pick out.
            u = obj.xCells + cos(obj.thetCells);
            v = obj.yCells + sin(obj.thetCells);
            
            cla(axHand)
            for i = 1:size(obj.xCells,1)
                line(axHand,[obj.xCells(i),u(i)],[obj.yCells(i),v(i)],'Color',obj.cCells(i,:));
            end
            
            axis (axHand,'equal')            
            axis([0,obj.xWidth,0,obj.yHeight])
        end
    end
end