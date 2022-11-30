% @brief analyse_switches draws scatter plots characterizing how
% selfish/benevolent are player choices when
% - making uncoordinated choice
% - breaking coordination (for the faster player);
% - restoring coordination (for the faster player);
% - making a seamless switch between two coordinated choices (for the faster player).
% The function also tests whether the proportions of selfish choices are
% significantly different from 50%
%
% INPUT:
% - datasetFilenames - full paths to the files grouped into cell arrays
%   according to the type (human/ naive monkeys/confederate trained monkeys)
% - plotProp - various plot properties
% - trialsToConsider: define trials that are considered for the analysis
%      - trialsToConsider > 0: will be analysed 'trialsToConsider' trials from the END of the session
%      - trialsToConsider < 0: will be analysed all trials except FIRST 'trialsToConsider'
% - minDRT: minimal RT difference making partner's choice visible
% OUTPUT: pValues showing probabilities that the proportions of selfish choices are
% not significantly higher than 50%

function [pValueUncoordinated, pValueSeamlessSwitch, pValueChallengeResolving, pValueChallengeStart, ChangesScatterPlot_fh, legend_ah] = ...
    analyse_switches(datasetFilenames, plotProp, trialsToConsider, minDRT)

    [nUncoordinated, nSeamlessSwitch, nChallengeResolving, nChallengeStart, ...
     pValueUncoordinated, pValueSeamlessSwitch, pValueChallengeResolving, pValueChallengeStart] = ...
        perform_switches_test(datasetFilenames, trialsToConsider, minDRT);

    [ChangesScatterPlot_fh, legend_ah] = plot_switches_scatter(plotProp, ...
        nUncoordinated, nSeamlessSwitch, nChallengeResolving, nChallengeStart);
end