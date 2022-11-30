function [ ChangesScatterPlot_fh, legend_ah ] = plot_switches_scatter(plotProp, nUncoordinated, nSeamlessSwitch, nChallengeResolving, nChallengeStart)
minValue = 0.5; % we need to see minimal level > 0 to have a correct log-log plot
maxValue = 101;

logTicks = [minValue, 1, 3, 10, 30, 100];
logLabels = {'0', '1', '3', '10', '30', '100'};

legend_text = {};
legend_ah = [];

% compute confidence threshold
maxN = 100;
confidenceLevel = 0.05;
confThreshold = computeMinSignificantDeviationFromDiagonal(maxN, plotProp.sampleSizeCoeff, confidenceLevel);
xConfCurve = (1:maxN) + confThreshold;
yConfCurve = (1:maxN) - confThreshold;
yConfCurve(yConfCurve < minValue) = minValue/2;

nSet = length(nUncoordinated);
ChangesScatterPlot_fh = figure('Name', 'ChangesScatterPlot');
set( axes,'fontSize', plotProp.fontSize,  'FontName', plotProp.fontType);
for iPlot = 1:4
	subplot(2,2,iPlot);
	
	hold on
	for iSet = 1:nSet
		if (iPlot == 2)
			data = nUncoordinated{iSet}(:, 2:3);
			name = 'Uncoordinated trials';
			yLabel = 'Other-other (per 100 trials)';
			xLabel = 'Own-own (per 100 trials)';
% 			legend_text = {'human', 'human turn-taker', 'macaque late', 'F-C late', 'trained F-C', 'trained F-C turn-taking'};
% 			legend(legend_text, 'Location', 'NorthWest', 'FontSize', 8);
			legend_ah = gca();
		elseif (iPlot == 4)
			data = nChallengeResolving{iSet}(:, 2:3);
			name = 'Challenge resolutions';
			yLabel = 'Faster selects other (per 100 trials)';
			xLabel = 'Faster selects own (per 100 trials)';
		elseif (iPlot == 1)
			data = nSeamlessSwitch{iSet}(:, 2:3);
			name = 'Seamless switches';
			yLabel = 'Faster selects other (per 100 trials)';
			xLabel = 'Faster selects own (per 100 trials)';
		elseif (iPlot == 3)
			data = nChallengeStart{iSet}(:, 2:3);
			name = 'Challenge initiation';
			yLabel = 'Faster selects other (per 100 trials)';
			xLabel = 'Faster selects own (per 100 trials)';
		end
		
		data = data + minValue;
		scatter(data(plotProp.indexUnfilled{iSet},1), data(plotProp.indexUnfilled{iSet}, 2), plotProp.markerSize, plotProp.markerColor(iSet, :), plotProp.markerType(iSet));
		scatter(data(plotProp.indexFilled{iSet},1), data(plotProp.indexFilled{iSet}, 2), plotProp.markerSize, plotProp.markerColor(iSet, :), plotProp.markerType(iSet), 'filled');
		
	end
	plot([minValue,maxValue], [minValue,maxValue], 'k--', 'lineWidth', plotProp.lineWidth)
	plot(xConfCurve, yConfCurve, 'b--', 'lineWidth', plotProp.lineWidth);
	plot(yConfCurve, xConfCurve, 'b--', 'lineWidth', plotProp.lineWidth);
	hold off
	title(name);
	xlabel(xLabel, 'fontSize', plotProp.fontSize, 'FontName', plotProp.fontType);
	ylabel(yLabel, 'fontSize', plotProp.fontSize, 'FontName', plotProp.fontType);
	set( gca, 'fontSize', plotProp.fontSize, 'FontName', plotProp.fontType);
	%if (iPlot == 3)
	%    legendHandle = legend('humans coord', 'humans non-cooord', 'monkeys late', 'FC coord', 'FC non-cooord', 'location', 'eastoutside');
	%    set(legendHandle, 'fontSize', plotProp.fontSize, 'FontName', plotProp.fontType, 'Interpreter', 'latex');
	%end
	set(gca,'xscale','log','yscale','log','xTick', logTicks, 'xTickLabel', logLabels,'yTick', logTicks, 'yTickLabel', logLabels)
	
	if (iPlot == 1) || (iPlot == 2)
		axis([minValue, maxValue, minValue, maxValue]);
	else
		axis([minValue, 18, minValue, 18]);
	end
	
end

%     set( gcf, 'PaperUnits','centimeters' );
%     xLeft = 0; yTop = 0;
% 	set( gcf,'PaperPosition', [ xLeft yTop plotProp.xSize plotProp.ySize ] );
% 	print ( '-depsc', '-r600','ChangesScatterPlot');
% 	print('-dpdf', 'ChangesScatterPlot', '-r600');

end

function confThreshold = computeMinSignificantDeviationFromDiagonal(maxN, sampleSizeCoeff, confidenceLevel)
confThreshold = 1:maxN;

dlt = 1;
for valueOnDiagonal = 1:maxN
	while dlt <= valueOnDiagonal
		[~, p, ~] = fishertest(sampleSizeCoeff*[valueOnDiagonal+dlt, valueOnDiagonal-dlt; valueOnDiagonal, valueOnDiagonal], 'Tail','right');
		if (p < confidenceLevel)
			confThreshold(valueOnDiagonal) = dlt;
			break;
		end
		dlt = dlt + 1;
	end
end

%{
    xConfCurve = (1:maxN) - confThreshold;
    yConfCurve = (1:maxN) + confThreshold;
    figure
    hold on
    plot(1:100, 1:100, 'r');
    plot(xConfCurve, yConfCurve, 'b--');
    plot(yConfCurve, xConfCurve, 'b--');
    axis([1,100,1,100])
%}
end
