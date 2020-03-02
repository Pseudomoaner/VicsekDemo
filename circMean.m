function outAngle = circMean(inAngles)
%CIRCMEAN calculates the circular average of a set of input angles.
%   Does this using the method discussed in en.wikipedia.org/wiki/Mean_of_circular_quantities.
%   inAngles should be 

if length(inAngles) ~= numel(inAngles)
    error('Input to circMean is not expected vector format.')
end

xs = cos(inAngles);
ys = sin(inAngles);
outAngle = atan2(mean(ys),mean(xs));