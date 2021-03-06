function BodePlot(sys,order)

if nargin < 2
    order = 1;
end
dbshift = gain2db(order);

axesWidth = 261.120/10;
axesHeight = 190.293/10;

figureHandle = figure;
hold on
axes1Handle = gca;
axes1Handle.Units = 'centimeters';
axes1Position = get(axes1Handle, 'Position');
axes1Position(3:4) = [axesWidth axesHeight];
axes1Handle.Position = axes1Position;
set(axes1Handle, ...
    'YAxisLocation','Left', ...
    'YLim',[-42,34], ...
    'XAxisLocation','Origin', ...
    'XLim',[-26,26]+dbshift, ...
    'TickDir','out', ...
    'HitTest', 'off');
axes2Handle = axes( ...
    'Units','centimeters', ...
    'Position',axes1Position, ...
    'YAxisLocation','Right', ...
    'YLim',deg2db([-210,170]), ...
    'XTick',[], ...
    'XLim',[-26,26]+dbshift, ...
    'Color','none', ...
    'TickDir','out', ...
    'NextPlot','add', ...
    'HitTest', 'off');

AxesSetup(axes1Handle);
AxesSetup(axes2Handle);

linkaxes([axes1Handle, axes2Handle],'x');

xMajorTickMarks = [(0.06:0.01:0.1), (0.2:0.1:1), (2:1:10)]*order;
yMajorTickMarks = [(0.01:0.01:0.1), (0.2:0.1:1), (2:1:10), (20:10:40)];
yDegMajorTickMarks = [-180, -90, 0, 90];

xMajorTickPositions = gain2db(xMajorTickMarks);
yMajorTickPositions = gain2db(yMajorTickMarks);
yDegMajorTickPositions = deg2db(yDegMajorTickMarks);

axes1Handle.XTick = xMajorTickPositions;
axes1Handle.YTick = yMajorTickPositions;

axes2Handle.YTick = yDegMajorTickPositions;
axes2Handle.YTickLabel = cellfun(@(x) [num2str(x),'�'], num2cell(yDegMajorTickMarks),'UniformOutput',false);

labeledXTicks = [0.1, 0.2, 0.5, 1, 2, 5, 10]*order;
xLabels = tickLabels(xMajorTickMarks, labeledXTicks);
axes1Handle.XTickLabel = xLabels;

labeledYTicks = [0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10, 20];
yLabels = tickLabels(yMajorTickMarks, labeledYTicks);
axes1Handle.YTickLabel = yLabels;

for i = -210:10:170
    if i == 10
        plot(axes2Handle, [-26,-20.75]+dbshift, deg2db([i, i]), 'k', 'HitTest', 'off');
        plot(axes2Handle, [-19.25,-14.75]+dbshift, deg2db([i, i]), 'k', 'HitTest', 'off');
        plot(axes2Handle, [-13.25,-6.75]+dbshift, deg2db([i, i]), 'k', 'HitTest', 'off');
        plot(axes2Handle, [-5.25,-0.5]+dbshift, deg2db([i, i]), 'k', 'HitTest', 'off');
        plot(axes2Handle, [0.5,5.5]+dbshift, deg2db([i, i]), 'k', 'HitTest', 'off');
        plot(axes2Handle, [6.5,13.5]+dbshift, deg2db([i, i]), 'k', 'HitTest', 'off');
        plot(axes2Handle, [14.5,19.25]+dbshift, deg2db([i, i]), 'k', 'HitTest', 'off');
        plot(axes2Handle, [20.75,26]+dbshift, deg2db([i, i]), 'k', 'HitTest', 'off');
    elseif i == -180 || i==-90 || i==90
        plot(axes2Handle, [-26,26]+dbshift, deg2db([i, i]), 'k--', 'HitTest', 'off');
    elseif i == 0
        plot(axes2Handle, [-26,26]+dbshift, deg2db([i, i]), 'k', 'LineWidth', 2, 'HitTest', 'off');
    else
        plot(axes2Handle, [-26,26]+dbshift, deg2db([i, i]), 'k', 'HitTest', 'off');
    end
end

for i = -26:2:26
    if any(abs(gain2db(labeledXTicks/order) - i) < 0.1)
        plot(axes2Handle, [i, i]+dbshift, deg2db([-210, 8]), 'k', 'HitTest', 'off');
        plot(axes2Handle, [i, i]+dbshift, deg2db([18, 170]), 'k', 'HitTest', 'off');
    else
        plot(axes2Handle, [i, i]+dbshift, deg2db([-210, 170]), 'k', 'HitTest', 'off');
    end
end

[amp,phase,wout] = bode(sys, {db2gain(-26+dbshift),db2gain(26+dbshift)});
omega = gain2db(wout);
amp = amp(:);
phase = phase(:);
gain = gain2db(amp);

plot(axes1Handle, omega, gain, 'LineWidth', 2, 'HitTest', 'on');
plot(axes2Handle, omega, deg2db(phase),'--', 'LineWidth', 2, 'HitTest', 'on');

% TODO:
% Use datacursormode to make data tool tip clearer.
% Frequency rad/s
% Magnitude dB
% Phase deg

figureHandle.Units = 'centimeters';
FitFigure(figureHandle,axes1Handle,axes2Handle);

PrintFigure(figureHandle);

end

function labels = tickLabels(tickMarks, ticksLabeled)

labels = cell(size(tickMarks));
for i = 1:numel(labels)
    val = tickMarks(i);
    if any(abs(ticksLabeled/val - 1) < 0.005)
        labels{i} = num2str(val);
    else
        labels{i} = '';
    end
end

end

function gain = db2gain(db)

gain = 10.^(db/20);

end

function db = gain2db(gain)

db = 20*log10(gain);

end

function db = deg2db(deg)

db = deg/10*2;
db = deg;

end

function deg = db2deg(db)

deg = db/2*10;

end

function AxesSetup(axesHandle)

axesHandle.LabelFontSizeMultiplier = 1.0;
axesHandle.FontSize = 10;

end

function FitFigure(fig,ax1,ax2)

ti1 = ax1.TightInset;
ti2 = ax2.TightInset;

pos1 = ax1.Position;
pos2 = ax2.Position;

maxInsets = max([ti1;ti2]);

[size,pos] = getMinBoundingBox(pos1, maxInsets);

ip = fig.InnerPosition;
ip(3:4) = size;
ip(1:2) = [0 0];
fig.InnerPosition = ip;

pos1(1:2) = pos;
pos2(1:2) = pos;

ax1.Position = pos1;
ax2.Position = pos2;

op = fig.OuterPosition;
op(1:2) = [2 2];
fig.OuterPosition = op;

end

function [size,pos] = getMinBoundingBox(position, tightInset)

left = tightInset(1);
bottom = tightInset(2);
width = position(3) + tightInset(1) + tightInset(3);
height = position(4) + tightInset(2) + tightInset(4);

size = [width height];
pos = [left bottom];

end

function PrintFigure(fig)

fig.PaperPositionMode = 'auto';
figurePosition = fig.PaperPosition;
fig.PaperSize = [figurePosition(3) figurePosition(4)];

print(fig, 'untitled','-dpdf');

end

