function [ coordination_metrics_struct, coordination_metrics_row, coordination_metrics_row_header ] = fn_compute_coordination_metrics_session_by_indexedtrials( isOwnChoiceArray, sideChoiceArray, PerTrialStruct, cfg, trial_index, use_all_trials, prefix_string, suffix_string )
%FN_COMPUTE_COORDINATION_METRICS_SESSION_BY_INDEXEDTRIALS Summary of this function goes here
%   This is supposed to do the same as compute_coortdination_mtrics, but
%   only for a single session and expects to get the data passed in instead
%   of being passed a (list of) file name(s) for the data set(s)
%   This version should not special case the blocked trials anymore, but
%   simply operate on the indexed trials and append the supplied prefix and
%   suffix

% TODO:
%   if trial_index, use_all_trials, prefix_string, suffix_string are cell
%   arrays, loop over the elements and create and concatenate all sets.
%   Calculate and return the coordination measures for the confederate
%   case, so based on the confederates choices is that possible?
%   Add the calculation of correlation between chance to follow and RT
%   difference
%   Add the average rewrad for by RTdiff (for faster and slower player, test by fisher exact test)
%   Add the trial sums for all 4 choice combinations

% DONE:
%   change to take in a list of trial indices and just calculate and return
%   header and data for that set, also allow to pass in a common suffix
%   string to make sure the header fields can be made unique, that also
%   allows to get rid of the special casing of the invisibility trials and
%   will return the exact same measures for each subset.
%   Allow manual override of the stationarySegmentLength, minStationarySegmentStart
%   logic to use the full supplied index...
%


% use the following two to decorate all variable names for the coordination_metrics_row_header
if ~exist('prefix_string', 'var') || isempty(prefix_string)
	prefix_string = '';
end
if ~exist('suffix_string', 'var') || isempty(suffix_string)
	suffix_string = '';
end


coordination_metrics_row = [];
coordination_metrics_row_header = {};
linearize_coordination_metrics_struct = 0;
info_struct = struct();
RT_correlation_detrending_order_list = [0, 1, 2]; % which detrend orders to use, 0 de-means but gives the same correlations as without detrending
RT_confidence_interval_alpha = 0.05;
RT_AB_name_list = {'intialTargetReleaseTime', 'IniTargRel_05MT_Time', 'targetAcquisitionTime'};
% we use the RT_correlation_subgroup_idx later to get to the relevant
% trials
RT_AB_list = {[PerTrialStruct.A_InitialTargetReleaseRT(:)'; PerTrialStruct.B_InitialTargetReleaseRT(:)'], ...
	[PerTrialStruct.A_TargetAcquisitionRT(:)'; PerTrialStruct.B_TargetAcquisitionRT(:)'], ...
	[PerTrialStruct.A_IniTargRel_05MT_RT(:)'; PerTrialStruct.B_IniTargRel_05MT_RT(:)'] };

% names and indices for subsets of trials for which to calculate the
% RT correlations between A and B
RT_correlation_subgroup_name_list = {'all', 'AredBred', 'AyelByel', 'AredByel', 'AyelBred', 'Ared', 'Ayel', 'Bred', 'Byel', ...
										'AsLBsR', 'AsRBsL', 'AsLBsL', 'AsRBsR', 'AsL', 'AsR', 'BsL', 'BsR', ...
}; %

% get the relevant subsets
RT_correlation_subgroup_idx_list = {trial_index, ...
	intersect(trial_index, find(PerTrialStruct.PreferableTargetSelected_A .* PerTrialStruct.NonPreferableTargetSelected_B)), ...
	intersect(trial_index, find(PerTrialStruct.NonPreferableTargetSelected_A .* PerTrialStruct.PreferableTargetSelected_B)), ...
	intersect(trial_index, find(PerTrialStruct.PreferableTargetSelected_A .* PerTrialStruct.PreferableTargetSelected_B)), ...
	intersect(trial_index, find(PerTrialStruct.NonPreferableTargetSelected_A .* PerTrialStruct.NonPreferableTargetSelected_B)), ...
	intersect(trial_index, find(PerTrialStruct.PreferableTargetSelected_A)), ...	
	intersect(trial_index, find(PerTrialStruct.NonPreferableTargetSelected_A)), ...	
	intersect(trial_index, find(PerTrialStruct.NonPreferableTargetSelected_B)), ...	
	intersect(trial_index, find(PerTrialStruct.PreferableTargetSelected_B)), ...	
	intersect(trial_index, find(PerTrialStruct.SubjectiveLeftTargetSelected_A .* PerTrialStruct.SubjectiveRightTargetSelected_B)), ...
	intersect(trial_index, find(PerTrialStruct.SubjectiveRightTargetSelected_A .* PerTrialStruct.SubjectiveLeftTargetSelected_B)), ...
	intersect(trial_index, find(PerTrialStruct.SubjectiveLeftTargetSelected_A .* PerTrialStruct.SubjectiveLeftTargetSelected_B)), ...
	intersect(trial_index, find(PerTrialStruct.SubjectiveRightTargetSelected_A .* PerTrialStruct.SubjectiveRightTargetSelected_B)), ...	
	intersect(trial_index, find(PerTrialStruct.SubjectiveLeftTargetSelected_A)), ...	
	intersect(trial_index, find(PerTrialStruct.SubjectiveRightTargetSelected_A)), ...	
	intersect(trial_index, find(PerTrialStruct.SubjectiveLeftTargetSelected_B)), ...	
	intersect(trial_index, find(PerTrialStruct.SubjectiveRightTargetSelected_B)), ...	
}; %



if nargout > 1
	linearize_coordination_metrics_struct = 1;
	structs_to_linearize_list = {'sessionMetrics', 'coordination_struct', 'info_struct'};
end
if nargout > 2
	create_coordination_metrics_row_header = 1;
end

coordination_metrics_struct = struct();

isTrialVisible = PerTrialStruct.isTrialInvisible_AB(trial_index)';

% reduce the data to the indexed subset
intialTargetReleaseTime = [PerTrialStruct.A_InitialTargetReleaseRT(trial_index)'; PerTrialStruct.B_InitialTargetReleaseRT(trial_index)'];
targetAcquisitionTime = [PerTrialStruct.A_TargetAcquisitionRT(trial_index)'; PerTrialStruct.B_TargetAcquisitionRT(trial_index)'];
IniTargRel_05MT_Time = [PerTrialStruct.A_IniTargRel_05MT_RT(trial_index)'; PerTrialStruct.B_IniTargRel_05MT_RT(trial_index)'];


% for the correlation between the choice vector
PreferableNoneNonpreferableSelected = [PerTrialStruct.PreferableNoneNonpreferableSelected_A(trial_index)'; PerTrialStruct.PreferableNoneNonpreferableSelected_B(trial_index)'];
RightNoneLeftSelected = [PerTrialStruct.RightNoneLeftSelected_A(trial_index)'; PerTrialStruct.RightNoneLeftSelected_B(trial_index)'];
SubjectiveRightNoneLeftSelected = [PerTrialStruct.SubjectiveRightNoneLeftSelected_A(trial_index)'; PerTrialStruct.SubjectiveRightNoneLeftSelected_B(trial_index)'];


RewardByTrial = [PerTrialStruct.RewardByTrial_A(trial_index)'; PerTrialStruct.RewardByTrial_B(trial_index)'];

full_isOwnChoiceArray = isOwnChoiceArray;
full_sideChoiceArray = sideChoiceArray;

isOwnChoiceArray = isOwnChoiceArray(:, trial_index);
sideChoiceArray = sideChoiceArray(:, trial_index);


%-------------------- initialization --------------------

% sessionMetrics = struct('teTarget', {}, ...
%     'teSide', {},  ...
%     'miTarget', {},...
%     'miTargetSignif', {}, ...
%     'miTargetThresh', {}, ...
%     'miSide', {}, ...
%     'miSideSignif', {}, ...
%     'miSideThresh', {}, ...
%     'playerReward', {}, ...
%     'averReward', {}, ...
%     'isPairProficient', {}, ...
%     'dltReward', {}, ...
%     'dltSignif', {}, ...
%     'dltConfInterval', {}, ...
%     'shareOwnChoices', {}, ...
%     'shareLeftChoices', {}, ...
%     'shareJointChoices', {}, ...
%     'avgRewardFasterIniTargRel', {}, ...
%     'avgRewardSlowerIniTargRel', {}, ...
%     'avgRewardFasterTargAcq', {}, ...
%     'avgRewardSlowerTargAcq', {}, ...
%      );


% strategy - probability to select own target given the state, incorporating
% previous outcome, current stimuli location and current partner's choice (if visible)
playerStrategy = {};    % estimated strategy
playerNStateVisit = {}; % number of state visits
%---------------- dataset processing --------------------



sessionMetrics.teTarget = NaN(2, 1);
sessionMetrics.teSide = NaN(2, 1);
sessionMetrics.miTarget = NaN(1, 1);
sessionMetrics.miTargetSignif = NaN(1, 1);
sessionMetrics.miTargetThresh = NaN(1, 1);
sessionMetrics.miSide = NaN(1, 1);
sessionMetrics.miSideSignif = NaN(1, 1);
sessionMetrics.miSideThresh = NaN(1, 1);
sessionMetrics.playerReward = NaN(2, 1);
sessionMetrics.averReward = NaN(1, 1);
sessionMetrics.isPairProficient = NaN(1, 1);
sessionMetrics.dltReward = NaN(1, 1);
sessionMetrics.dltSignif = NaN(1, 1);
sessionMetrics.dltConfInterval = NaN(2, 1);
sessionMetrics.shareOwnChoices = NaN(2, 1);
sessionMetrics.shareLeftChoices = NaN(2, 1);
sessionMetrics.shareJointChoices = NaN(1, 1);
% to get a handle on whether the faster player earned more reward
sessionMetrics.avgRewardFasterIniTargRel = NaN(1, 1);
sessionMetrics.avgRewardSlowerIniTargRel = NaN(1, 1);
sessionMetrics.avgRewardByIniTargRelDiffSignif = NaN(1, 1);
sessionMetrics.avgRewardFasterTargAcq = NaN(1, 1);
sessionMetrics.avgRewardSlowerTargAcq = NaN(1, 1);
sessionMetrics.avgRewardByTargAcqDiffSignif = NaN(1, 1);
sessionMetrics.avgRewardFasterIniTargRel_05MT = NaN(1, 1);
sessionMetrics.avgRewardSlowerIniTargRel_05MT = NaN(1, 1);
sessionMetrics.avgRewardByIniTargRel_05MTDiffSignif = NaN(1, 1);


% for the correlation between seeing the other's action and selecting the
% others target
sessionMetrics.IniTargRel_corrCoefValue = NaN(2, 1);
sessionMetrics.IniTargRel_corrPValue = NaN(2, 1);
sessionMetrics.IniTargRel_corrCoefAveraged = NaN(2, 1);
sessionMetrics.IniTargRel_corrPValueAveraged = NaN(2, 1);

sessionMetrics.TargAcq_corrCoefValue = NaN(2, 1);
sessionMetrics.TargAcq_corrPValue = NaN(2, 1);
sessionMetrics.TargAcq_corrCoefAveraged = NaN(2, 1);
sessionMetrics.TargAcq_corrPValueAveraged = NaN(2, 1);

sessionMetrics.IniTargRel_05MT_corrCoefValue = NaN(2, 1);
sessionMetrics.IniTargRel_05MT_corrPValue = NaN(2, 1);
sessionMetrics.IniTargRel_05MT_corrCoefAveraged = NaN(2, 1);
sessionMetrics.IniTargRel_05MT_corrPValueAveraged = NaN(2, 1);


% for the correlation between the choice vector
sessionMetrics.PreferableNoneNonpreferableSelected_df = NaN(1, 1);
sessionMetrics.PreferableNoneNonpreferableSelected_r = NaN(1, 1);
sessionMetrics.PreferableNoneNonpreferableSelected_p = NaN(1, 1);
sessionMetrics.RightNoneLeftSelected_df = NaN(1, 1);
sessionMetrics.RightNoneLeftSelected_r = NaN(1, 1);
sessionMetrics.RightNoneLeftSelected_p = NaN(1, 1);
sessionMetrics.SubjectiveRightNoneLeftSelected_df = NaN(1, 1);
sessionMetrics.SubjectiveRightNoneLeftSelected_r = NaN(1, 1);
sessionMetrics.SubjectiveRightNoneLeftSelected_p = NaN(1, 1);


% report some counts for the subsets
sessionMetrics.nARBR = NaN(1, 1);
sessionMetrics.nARBL = NaN(1, 1);
sessionMetrics.nALBR = NaN(1, 1);
sessionMetrics.nALBL = NaN(1, 1);
sessionMetrics.nAredBred = NaN(1, 1);
sessionMetrics.nAredByel = NaN(1, 1);
sessionMetrics.nAyelBred = NaN(1, 1);
sessionMetrics.nAyelByel = NaN(1, 1);
sessionMetrics.nCoordinated = NaN(1, 1);
sessionMetrics.nNoncoordinated = NaN(1, 1);


% reaction time measures
sessionMetrics.avg_intialTargetReleaseTime = NaN(2, 1);
sessionMetrics.avg_targetAcquisitionTime = NaN(2, 1);
sessionMetrics.avg_IniTargRel_05MT_Time = NaN(2, 1);


sessionMetrics.avg_intialTargetReleaseTime = mean(intialTargetReleaseTime, 2);
sessionMetrics.avg_targetAcquisitionTime = mean(targetAcquisitionTime, 2);
sessionMetrics.avg_IniTargRel_05MT_Time = mean(IniTargRel_05MT_Time, 2);


% analyse all sessions for the given players pair

% here we consider only equilibrium (stabilized) values
nTrial = length(isOwnChoiceArray);
if ~(use_all_trials)
	firstTestIndex = max(cfg.minStationarySegmentStart, nTrial-cfg.stationarySegmentLength);
else
	firstTestIndex = 1;
end
testIndices = firstTestIndex:nTrial;
nTestIndices = length(testIndices);

% add information about the number of analyzed trials to the output
info_struct.use_all_trials = use_all_trials;
info_struct.nTrials = nTrial;
info_struct.firstTestIndex = firstTestIndex;
info_struct.nTestIndices = nTestIndices;

if isempty(testIndices)
	disp([mfilename, ': found less than ', num2str(cfg.minStationarySegmentStart), ' trials, coordination metrics will not be calculated.']);
	return
end


% report some counts for the subsets
% objective sides
sessionMetrics.nARBR = length(find((sideChoiceArray(1, testIndices) == 0) & (sideChoiceArray(2, testIndices) == 0)));
sessionMetrics.nARBL = length(find((sideChoiceArray(1, testIndices) == 0) & (sideChoiceArray(2, testIndices) == 1)));
sessionMetrics.nALBR = length(find((sideChoiceArray(1, testIndices) == 1) & (sideChoiceArray(2, testIndices) == 0)));
sessionMetrics.nALBL = length(find((sideChoiceArray(1, testIndices) == 1) & (sideChoiceArray(2, testIndices) == 1)));
% value/color
sessionMetrics.nAredBred = length(find((isOwnChoiceArray(1, testIndices) == 1) & (isOwnChoiceArray(2, testIndices) == 0)));
sessionMetrics.nAredByel = length(find((isOwnChoiceArray(1, testIndices) == 1) & (isOwnChoiceArray(2, testIndices) == 1)));
sessionMetrics.nAyelBred = length(find((isOwnChoiceArray(1, testIndices) == 0) & (isOwnChoiceArray(2, testIndices) == 0)));
sessionMetrics.nAyelByel = length(find((isOwnChoiceArray(1, testIndices) == 0) & (isOwnChoiceArray(2, testIndices) == 1)));
% coordination
sessionMetrics.nCoordinated = length(find(isOwnChoiceArray(1, testIndices) ~= isOwnChoiceArray(2, testIndices)));
sessionMetrics.nNoncoordinated = length(find(isOwnChoiceArray(1, testIndices) == isOwnChoiceArray(2, testIndices)));




% estimate strategy over equilibrium trials
% this analysis results in the strategy description vectors used in the
% transparent games simulations.
[playerStrategy, playerShortStrategy, playerNStateVisit] = ...
	estimate_strategy(isOwnChoiceArray(:, testIndices), sideChoiceArray(:,testIndices), targetAcquisitionTime(:,testIndices), cfg.minDRT);

[playerStrategy, playerShortStrategy, playerNStateVisit] = ...
	estimate_strategy(isOwnChoiceArray(:, testIndices), sideChoiceArray(:,testIndices), IniTargRel_05MT_Time(:,testIndices), cfg.minDRT);


strategy_struct.playerStrategy = playerStrategy;
strategy_struct.playerNStateVisit = playerNStateVisit;


[sessionMetrics.averReward, ...
	sessionMetrics.dltReward, ...
	sessionMetrics.dltSignif, ...
	sessionMetrics.dltConfInterval(:)] = ...
	calc_total_average_reward(isOwnChoiceArray(:,testIndices), sideChoiceArray(:,testIndices));



%target choices quantities
sessionMetrics.shareOwnChoices(:) = mean(isOwnChoiceArray(:, testIndices), 2);
sessionMetrics.shareJointChoices = mean(xor(isOwnChoiceArray(1, testIndices), isOwnChoiceArray(2, testIndices)));
sessionMetrics.playerReward(:) = 1 + sessionMetrics.shareOwnChoices(:) + 2*sessionMetrics.shareJointChoices;
x = isOwnChoiceArray(1, testIndices);
y = isOwnChoiceArray(2, testIndices);
[sessionMetrics.miTarget, ...
	sessionMetrics.miTargetSignif, ...
	sessionMetrics.miTargetThresh] = calc_whole_mutual_information(x, y, cfg.pValueForMI);
teValue1 = calc_transfer_entropy(y, x, cfg.memoryLength, nTestIndices);
teValue2 = calc_transfer_entropy(x, y, cfg.memoryLength, nTestIndices);
sessionMetrics.teTarget(:) = [teValue1(1); teValue2(1)];

%side choices quantities
sessionMetrics.shareLeftChoices(:) = mean(sideChoiceArray(:, testIndices), 2);
x = sideChoiceArray(1, testIndices);
y = sideChoiceArray(2, testIndices);
[sessionMetrics.miSide, ...
	sessionMetrics.miSideSignif, ...
	sessionMetrics.miSideThresh] = calc_whole_mutual_information(x, y, cfg.pValueForMI);
teValue1 = calc_transfer_entropy(y, x, cfg.memoryLength, nTestIndices);
teValue2 = calc_transfer_entropy(x, y, cfg.memoryLength, nTestIndices);
sessionMetrics.teSide(:) = [teValue1(1); teValue2(1)];



% get an handle on the advantage of being faster (ignore the equally fast case here)
IniTargRel_A_faster_idx = find(intialTargetReleaseTime(1,:) > intialTargetReleaseTime(2,:));
IniTargRel_B_faster_idx = find(intialTargetReleaseTime(1,:) < intialTargetReleaseTime(2,:));
IniTargRel_A_slower_idx = IniTargRel_B_faster_idx;
IniTargRel_B_slower_idx = IniTargRel_A_faster_idx;
% collect for each trial the amount of reward earne by the faster and the
% slower agent
RewardByFasterIniTargRelList = [RewardByTrial(1, IniTargRel_A_faster_idx), RewardByTrial(2, IniTargRel_B_faster_idx)];
RewardBySlowerIniTargRelList = [RewardByTrial(1, IniTargRel_A_slower_idx), RewardByTrial(2, IniTargRel_B_slower_idx)];
% now find the number of 4s in each set
cont_table = [length(find(RewardByFasterIniTargRelList == 4)), length(RewardByFasterIniTargRelList); length(find(RewardBySlowerIniTargRelList == 4)), length(RewardBySlowerIniTargRelList)];
[fet_h, fet_p, fet_stats] = fishertest(cont_table, 'Alpha', cfg.pValueForFisherExactTests, 'Tail', 'both');

sessionMetrics.avgRewardFasterIniTargRel = nanmean(RewardByFasterIniTargRelList);
sessionMetrics.avgRewardSlowerIniTargRel = nanmean(RewardBySlowerIniTargRelList);
sessionMetrics.avgRewardByIniTargRelDiffSignif = fet_p;


TargAcq_A_faster_idx = find(targetAcquisitionTime(1,:) > targetAcquisitionTime(2,:));
TargAcq_B_faster_idx = find(targetAcquisitionTime(1,:) < targetAcquisitionTime(2,:));
TargAcq_A_slower_idx = TargAcq_B_faster_idx;
TargAcq_B_slower_idx = TargAcq_A_faster_idx;
% collect for each trial the amount of reward earne by the faster and the
% slower agent
RewardByFasterTargAcqList = [RewardByTrial(1, TargAcq_A_faster_idx), RewardByTrial(2, TargAcq_B_faster_idx)];
RewardBySlowerTargAcqList = [RewardByTrial(1, TargAcq_A_slower_idx), RewardByTrial(2, TargAcq_B_slower_idx)];

% now find the number of 4s in each set
cont_table = [length(find(RewardByFasterTargAcqList == 4)), length(RewardByFasterTargAcqList); length(find(RewardBySlowerTargAcqList == 4)), length(RewardBySlowerTargAcqList)];
[fet_h, fet_p, fet_stats] = fishertest(cont_table, 'Alpha', cfg.pValueForFisherExactTests, 'Tail', 'both');


sessionMetrics.avgRewardFasterTargAcq = nanmean(RewardByFasterTargAcqList);
sessionMetrics.avgRewardSlowerTargAcq = nanmean(RewardBySlowerTargAcqList);
sessionMetrics.avgRewardByTargAcqDiffSignif = fet_p;


%IniTargRel_05MT_Time
IniTargRel_05MT_A_faster_idx = find(IniTargRel_05MT_Time(1,:) > IniTargRel_05MT_Time(2,:));
IniTargRel_05MT_B_faster_idx = find(IniTargRel_05MT_Time(1,:) < IniTargRel_05MT_Time(2,:));
IniTargRel_05MT_A_slower_idx = IniTargRel_05MT_B_faster_idx;
IniTargRel_05MT_B_slower_idx = IniTargRel_05MT_A_faster_idx;
% collect for each trial the amount of reward earne by the faster and the
% slower agent
RewardByFasterIniTargRel_05MTList = [RewardByTrial(1, IniTargRel_05MT_A_faster_idx), RewardByTrial(2, IniTargRel_05MT_B_faster_idx)];
RewardBySlowerIniTargRel_05MTList = [RewardByTrial(1, IniTargRel_05MT_A_slower_idx), RewardByTrial(2, IniTargRel_05MT_B_slower_idx)];

% now find the number of 4s in each set
cont_table = [length(find(RewardByFasterIniTargRel_05MTList == 4)), length(RewardByFasterIniTargRel_05MTList); length(find(RewardBySlowerIniTargRel_05MTList == 4)), length(RewardBySlowerIniTargRel_05MTList)];
[fet_h, fet_p, fet_stats] = fishertest(cont_table, 'Alpha', cfg.pValueForFisherExactTests, 'Tail', 'both');


sessionMetrics.avgRewardFasterIniTargRel_05MT = nanmean(RewardByFasterIniTargRel_05MTList);
sessionMetrics.avgRewardSlowerIniTargRel_05MT = nanmean(RewardBySlowerIniTargRel_05MTList);
sessionMetrics.avgRewardByIniTargRel_05MTDiffSignif = fet_p;



% perform coordination tests.
% To simplify visual inspection, results of all tests are qathered in single table
coordStruct = ...
	check_coordination(isOwnChoiceArray(:,testIndices), sideChoiceArray(:,testIndices));


%%% THE FOLLOWING SHOULD MOVE OUT INTO the caller, as this is showing per

% NOTE WE ONLY CALCULATE THIS FOR THE CURRENT TRIAL SUBSET

%%% trial data instead of per session aggregates
% compute MI and TE, as well as local MI and TE in windows
x = isOwnChoiceArray(1, :);
y = isOwnChoiceArray(2, :);
targetTE1 = calc_transfer_entropy(y, x, cfg.memoryLength, cfg.minSampleNum);
targetTE2 = calc_transfer_entropy(x, y, cfg.memoryLength, cfg.minSampleNum);
localTargetTE1 = calc_local_transfer_entropy(y, x, cfg.memoryLength, cfg.minSampleNum);
localTargetTE2 = calc_local_transfer_entropy(x, y, cfg.memoryLength, cfg.minSampleNum);
locMutualInf = calc_local_mutual_information(x, y, cfg.minSampleNum);
mutualInf = calc_mutual_information(x, y, cfg.minSampleNum);
% minValue = min([minValue, min(localTargetTE1), min(localTargetTE2)]);
% maxValue = max([maxValue, max(localTargetTE1), max(localTargetTE2)]);
% minMIvalue = min([minMIvalue, min(locMutualInf)]);
% maxMIvalue = max([maxMIvalue, max(locMutualInf)]);

per_trial.targetTE1 = targetTE1;
per_trial.targetTE2 = targetTE2;
per_trial.localTargetTE1 = localTargetTE1;
per_trial.localTargetTE2 = localTargetTE2;
per_trial.mutualInf = mutualInf;
per_trial.locMutualInf = locMutualInf;

% now calculate and add the probability to see the other curves here
% do this for all trials
per_trial.pSee_iniTargRel = calc_probabilities_to_see(intialTargetReleaseTime, cfg.minDRT);
per_trial.pSee_TargAcq = calc_probabilities_to_see(targetAcquisitionTime, cfg.minDRT);
per_trial.pSee_IniTargRel_05MT = calc_probabilities_to_see(IniTargRel_05MT_Time, cfg.minDRT);

% the probability to select the other's target is the inverse of selecting
% the preferred target
per_trial.full_isOtherChoice = 1 - full_isOwnChoiceArray;
per_trial.isOtherChoice = 1 - isOwnChoiceArray;
cfg.pSee_windowSize = 8;
% these go to the
[sessionMetrics.IniTargRel_corrCoefValue, sessionMetrics.IniTargRel_corrPValue, sessionMetrics.IniTargRel_corrCoefAveraged, sessionMetrics.IniTargRel_corrPValueAveraged] ...
	= calc_prob_to_see_correlation(per_trial.pSee_iniTargRel, isOwnChoiceArray, cfg.pSee_windowSize);
pSee_iniTargRel.corrCoefValue = sessionMetrics.IniTargRel_corrCoefValue;
pSee_iniTargRel.corrPValue = sessionMetrics.IniTargRel_corrPValue;
pSee_iniTargRel.corrCoefAveraged = sessionMetrics.IniTargRel_corrCoefAveraged;
pSee_iniTargRel.corrPValueAveraged = sessionMetrics.IniTargRel_corrPValueAveraged;
per_trial.pSee_iniTargRel_Cor = pSee_iniTargRel;

[sessionMetrics.TargAcq_corrCoefValue, sessionMetrics.TargAcq_corrPValue, sessionMetrics.TargAcq_corrCoefAveraged, sessionMetrics.TargAcq_corrPValueAveraged] ...
	= calc_prob_to_see_correlation(per_trial.pSee_TargAcq, isOwnChoiceArray, cfg.pSee_windowSize);
pSee_TargAcq.corrCoefValue = sessionMetrics.TargAcq_corrCoefValue;
pSee_TargAcq.corrPValue = sessionMetrics.TargAcq_corrPValue;
pSee_TargAcq.corrCoefAveraged = sessionMetrics.TargAcq_corrCoefAveraged;
pSee_TargAcq.corrPValueAveraged = sessionMetrics.TargAcq_corrPValueAveraged;
per_trial.pSee_TargAcq_Cor = pSee_TargAcq;


[sessionMetrics.IniTargRel_05MT_corrCoefValue, sessionMetrics.IniTargRel_05MT_corrPValue, sessionMetrics.IniTargRel_05MT_corrCoefAveraged, sessionMetrics.IniTargRel_05MT_corrPValueAveraged] ...
	= calc_prob_to_see_correlation(per_trial.pSee_IniTargRel_05MT, isOwnChoiceArray, cfg.pSee_windowSize);
pSee_IniTargRel_05MT.corrCoefValue = sessionMetrics.IniTargRel_05MT_corrCoefValue;
pSee_IniTargRel_05MT.corrPValue = sessionMetrics.IniTargRel_05MT_corrPValue;
pSee_IniTargRel_05MT.corrCoefAveraged = sessionMetrics.IniTargRel_05MT_corrCoefAveraged;
pSee_IniTargRel_05MT.corrPValueAveraged = sessionMetrics.IniTargRel_05MT_corrPValueAveraged;
per_trial.pSee_IniTargRel_05MT_Cor = pSee_IniTargRel_05MT;


% % reduce the data to the indexed subset
% intialTargetReleaseTime = [PerTrialStruct.A_InitialTargetReleaseRT(trial_index)'; PerTrialStruct.B_InitialTargetReleaseRT(trial_index)'];
% targetAcquisitionTime = [PerTrialStruct.A_TargetAcquisitionRT(trial_index)'; PerTrialStruct.B_TargetAcquisitionRT(trial_index)'];
% IniTargRel_05MT_Time = [PerTrialStruct.A_IniTargRel_05MT_RT(trial_index)'; PerTrialStruct.B_IniTargRel_05MT_RT(trial_index)'];





for i_RT_AB = 1:length(RT_AB_list)
	cur_RT_name = RT_AB_name_list{i_RT_AB};
	cur_RT_AB = RT_AB_list{i_RT_AB};

	% process individual sub-sets
	for i_subset = 1 : length(RT_correlation_subgroup_name_list)
		cur_subset_name = RT_correlation_subgroup_name_list{i_subset};
		cur_subset_idx = RT_correlation_subgroup_idx_list{i_subset};
		
		% get some statistics for the reaction times in each subset...
		sessionMetrics.([cur_RT_name, '_', cur_subset_name, '_mean'])  = mean(cur_RT_AB(:, cur_subset_idx), 2, 'omitnan');
		sessionMetrics.([cur_RT_name, '_', cur_subset_name, '_std'])  = std(cur_RT_AB(:, cur_subset_idx), 0, 2, 'omitnan');
		sessionMetrics.([cur_RT_name, '_', cur_subset_name, '_n'])  = sum(~isnan(cur_RT_AB(:, cur_subset_idx)), 2);
		sessionMetrics.([cur_RT_name, '_', cur_subset_name, '_ci_alpha']) = RT_confidence_interval_alpha;
		sessionMetrics.([cur_RT_name, '_', cur_subset_name, '_cihw']) = calc_cihw(sessionMetrics.([cur_RT_name, '_', cur_subset_name, '_mean']), sessionMetrics.([cur_RT_name, '_', cur_subset_name, '_n']), sessionMetrics.([cur_RT_name, '_', cur_subset_name, '_ci_alpha']));

		cur_RT_A = cur_RT_AB(1, cur_subset_idx);
		cur_RT_B = cur_RT_AB(2, cur_subset_idx);
		%cur_trial_index = trial_index;
		cur_trial_index = (1:1:length(cur_RT_B))'; % we do not care about the actual trial number here, but want to use each data point
		
		for i_detrend_oder =1:length(RT_correlation_detrending_order_list)
			cur_detrend_order = RT_correlation_detrending_order_list(i_detrend_oder);
			
			% allow to specify order NaN to skip the detrending completely
			if ~isnan(cur_detrend_order)
				[cur_RT_A_p, cur_RT_A_s, cur_RT_A_mu] = polyfit(cur_trial_index, cur_RT_A', cur_detrend_order);
				[cur_RT_B_p, cur_RT_B_s, cur_RT_B_mu] = polyfit(cur_trial_index, cur_RT_B', cur_detrend_order);
				% store the fitting parameter in the struct list
				RT_correlation_struct.(cur_RT_name).(cur_subset_name).(['detrend_order_', num2str(cur_detrend_order)]).polyval.cur_RT_A_p = cur_RT_A_p;
				RT_correlation_struct.(cur_RT_name).(cur_subset_name).(['detrend_order_', num2str(cur_detrend_order)]).polyval.cur_RT_A_s = cur_RT_A_s;
				RT_correlation_struct.(cur_RT_name).(cur_subset_name).(['detrend_order_', num2str(cur_detrend_order)]).polyval.cur_RT_A_mu = cur_RT_A_mu;
				RT_correlation_struct.(cur_RT_name).(cur_subset_name).(['detrend_order_', num2str(cur_detrend_order)]).polyval.cur_RT_B_p = cur_RT_B_p;
				RT_correlation_struct.(cur_RT_name).(cur_subset_name).(['detrend_order_', num2str(cur_detrend_order)]).polyval.cur_RT_B_s = cur_RT_B_s;
				RT_correlation_struct.(cur_RT_name).(cur_subset_name).(['detrend_order_', num2str(cur_detrend_order)]).polyval.cur_RT_B_mu = cur_RT_B_mu;
				% no evaluate
				cur_RT_A_detrended = polyval(cur_RT_A_p, cur_trial_index, [], cur_RT_A_mu)';
				cur_RT_B_detrended = polyval(cur_RT_B_p, cur_trial_index, [], cur_RT_B_mu)';
				
				[cur_RT_AB_r, cur_RT_AB_p] = corrcoef((cur_RT_A - cur_RT_A_detrended), (cur_RT_B - cur_RT_B_detrended));
			else
				[cur_RT_AB_r, cur_RT_AB_p] = corrcoef(cur_RT_A, cur_RT_B);
			end
			% store the correlations in a struct
			RT_correlation_struct.(cur_RT_name).(cur_subset_name).(['detrend_order_', num2str(cur_detrend_order)]).df = length(cur_trial_index) - 2;
			RT_correlation_struct.(cur_RT_name).(cur_subset_name).(['detrend_order_', num2str(cur_detrend_order)]).r = cur_RT_AB_r;
			RT_correlation_struct.(cur_RT_name).(cur_subset_name).(['detrend_order_', num2str(cur_detrend_order)]).p = cur_RT_AB_p;
			% also flat in table?
			sessionMetrics.([cur_RT_name, '_', cur_subset_name,'corr_detrend_order_', num2str(cur_detrend_order), '_df']) = length(cur_trial_index) - 2;
			
			if ~isnan(cur_RT_AB_r)
				sessionMetrics.([cur_RT_name, '_', cur_subset_name, 'corr_detrend_order_', num2str(cur_detrend_order), '_r']) = cur_RT_AB_r(2, 1);
				sessionMetrics.([cur_RT_name, '_', cur_subset_name, 'corr_detrend_order_', num2str(cur_detrend_order), '_p']) = cur_RT_AB_p(2, 1);
			else
				sessionMetrics.([cur_RT_name, '_', cur_subset_name, 'corr_detrend_order_', num2str(cur_detrend_order), '_r']) = NaN;
				sessionMetrics.([cur_RT_name, '_', cur_subset_name, 'corr_detrend_order_', num2str(cur_detrend_order), '_p']) = NaN;
			end
			
		end
	end
end

% signed choices = SC
SC_AB_list = {PreferableNoneNonpreferableSelected, RightNoneLeftSelected, SubjectiveRightNoneLeftSelected};
SC_AB_name_list = {'PreferableNoneNonpreferableSelected_AB', 'RightNoneLeftSelected_AB', 'SubjectiveRightNoneLeftSelected_AB'};
for i_SC_AB = 1:length(SC_AB_list)
	cur_SC_name = SC_AB_name_list{i_SC_AB};
	
	cur_SC_AB = SC_AB_list{i_SC_AB};
	cur_SC_A = cur_SC_AB(1, :);
	cur_SC_B = cur_SC_AB(2, :);
	[cur_RT_AB_r, cur_RT_AB_p] = corrcoef(cur_SC_A, cur_SC_B);
	
	% store to table
	sessionMetrics.([cur_SC_name, '_df']) = length(trial_index) - 2;
	sessionMetrics.([cur_SC_name, '_r']) = cur_RT_AB_r(2, 1);
	sessionMetrics.([cur_SC_name, '_p']) = cur_RT_AB_p(2, 1);
	
	% 	if isnan(cur_RT_AB_r(2, 1)) || isnan(cur_RT_AB_p(2, 1))
	% 		disp('Doh...');
	% 	end
end


%%% THE PRECEEDING SHOULD MOVE OUT


%proficiencyThreshold = 2.75;
sessionMetrics.isPairProficient = check_pairs_proficiency(sessionMetrics.playerReward, cfg.proficiencyThreshold);

coordination_metrics_struct.strategy_struct = strategy_struct;
coordination_metrics_struct.sessionMetrics = sessionMetrics;
coordination_metrics_struct.coordination_struct = coordStruct;
coordination_metrics_struct.per_trial = per_trial;
coordination_metrics_struct.info_struct = info_struct;
coordination_metrics_struct.RT_correlation_struct = RT_correlation_struct;


%TODO:
%   linearize the data and create a matching header
if (linearize_coordination_metrics_struct)
	% TrialsInCurrentSetIdx can not be naively linearized (unequal length) so remove it
	fieldnames_to_remove_list = {'TrialsInCurrentSetIdx'}; % add all fields that should not be linearized to this list
	tmp_cfg = rmfield(cfg, fieldnames_to_remove_list);
	coordination_metrics_row = fn_linearize_struct(tmp_cfg, 'add_suffix_to_all_columns', {'_cfg'});
	coordination_metrics_row = [coordination_metrics_row, fn_linearize_struct(info_struct, 'add_suffix_to_all_columns', {'_info'})];
	coordination_metrics_row = [coordination_metrics_row, fn_linearize_struct(sessionMetrics, 'add_suffix', {'_A', '_B'})];
	coordination_metrics_row = [coordination_metrics_row, fn_linearize_struct(coordStruct.key_value_struct, 'add_suffix', {'_A', '_B'})];
end

if (create_coordination_metrics_row_header)
	% the cfg variables
	[~, coordination_metrics_row_header] = fn_linearize_struct(tmp_cfg, 'add_suffix_to_all_columns', {'_cfg'});
	%coordination_metrics_row_header = [coordination_metrics_row_header, tmp_coordination_metrics_row_header];
	
	[~, tmp_coordination_metrics_row_header] = fn_linearize_struct(info_struct, 'add_suffix_to_all_columns', {'_info'});
	coordination_metrics_row_header = [coordination_metrics_row_header, tmp_coordination_metrics_row_header];
	
	
	[~, tmp_coordination_metrics_row_header] = fn_linearize_struct(sessionMetrics, 'add_suffix', {'_A', '_B'});
	% fix up some column names...
	tmp_coordination_metrics_row_header{(strcmp('dltConfInterval_A', tmp_coordination_metrics_row_header))} = 'dltConfInterval_Lower';
	tmp_coordination_metrics_row_header{(strcmp('dltConfInterval_B', tmp_coordination_metrics_row_header))} = 'dltConfInterval_Upper';
	coordination_metrics_row_header = [coordination_metrics_row_header, tmp_coordination_metrics_row_header];
	
	% the coordStruct
	[ ~, tmp_coordination_metrics_row_header] = fn_linearize_struct(coordStruct.key_value_struct, 'add_suffix', {'_A', '_B'});
	coordination_metrics_row_header = [coordination_metrics_row_header, tmp_coordination_metrics_row_header];
	
	% now unconditionally sandwich all header items between prefix_string and
	% suffix_string
	for i_header_column = 1 : length(coordination_metrics_row_header)
		coordination_metrics_row_header{i_header_column} = [prefix_string, coordination_metrics_row_header{i_header_column}, suffix_string];
	end
	
end

return
end




function [data_row, header_list] = fn_linearize_struct(input_struct, list_handling_command, list_suffix_list)
data_row = [];
header_list = {};

convert_fieldnames_2_column_names = 0;
if (nargout > 1)
	convert_fieldnames_2_column_names = 1;
end

field_list = fieldnames(input_struct);

for i_field = 1 : length(field_list)
	current_data = input_struct.(field_list{i_field});
	if isstruct(current_data)
		% oh, this is a struct so recurse
		error('Not implemented yet.');
		[sub_data_row, sub_header_list] = fn_linearize_struct(current_data, list_handling_command, list_suffix_list);
		data_row = [data_row, sub_data_row];
		if (convert_fieldnames_2_column_names)
			header_list = [header_list, sub_header_list];
		end
		continue
	else
		if length(current_data) == 1
			% is scalar value, just grab value and name
			data_row(end + 1) = current_data;
			if (convert_fieldnames_2_column_names)
				
				if strcmp(list_handling_command, 'add_suffix_to_all_columns')
					header_list{end + 1} = [field_list{i_field}, list_suffix_list{1}];
				else
					header_list{end + 1} = field_list{i_field};
				end
			end
		else
			switch list_handling_command
				case 'add_suffix'
					% only add a suffix to non-scalar structure fields
					if length(current_data) == length(list_suffix_list)
						for i_item = 1 : length(current_data)
							data_row(end + 1) = current_data(i_item);
							if (convert_fieldnames_2_column_names)
								header_list{end + 1} = [field_list{i_field}, list_suffix_list{i_item}];
							end
						end
					else
						error(['Encountered data item with more elements than suffixes supplied in list_suffix_list, fix this.']);
					end
				case 'add_suffix_to_all_columns'
					% append the suffix to all fields
					if length(current_data) == length(list_suffix_list)
						for i_item = 1 : length(current_data)
							data_row(end + 1) = current_data(i_item);
							if (convert_fieldnames_2_column_names)
								header_list{end + 1} = [field_list{i_field}, list_suffix_list{i_item}];
							end
						end
					else
						error(['Encountered data item with more elements than suffixes supplied in list_suffix_list, fix this.']);
					end
					
					
				otherwise
					error(['Encountered unhandled list_handling_command: ', list_handling_command]);
			end
		end
	end
end

return
end