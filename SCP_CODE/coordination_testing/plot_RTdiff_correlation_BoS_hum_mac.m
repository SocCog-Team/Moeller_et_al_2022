function plot_RTdiff_correlation_BoS_hum_mac(project_name)
% Changed for supplementary figure 4 of BoS paper draft
% function plots the composite figure demonstrating correlation of RT diff
% and Probability to select anti-preffered target


FontSize = 8;
FontType = 'Arial';

LineWidth = 1.4;


windowSize = 8;
%ispc = 1;
minDRT = 50;
k = 0.04;

A_color = [1 0 0];
B_color = [0 0 1];

B_color = [0, 0.4470, 0.7410];
A_color = [0.85, 0.325, 0.098];


AB_colors = [A_color; B_color];

if ~exist('project_name', 'var') || isempty(project_name)
	% this requires subject_bias_analysis_sm01 to have run with the same project_name
	% which essentially defines the subset of sessions to include
	project_name = 'BoS_human_monkey_2019';	
	project_name = 'BoS_manuscript';
end



SCPDirs = GetDirectoriesByHostName('local');
InputPath = fullfile(SCPDirs.SCP_DATA_BaseDir, 'SCP_DATA', 'ANALYSES', SCPDirs.CurrentShortHostName, '2019');

if ~isempty(project_name)
	InputPath = fullfile(InputPath, project_name);
end

folder =fullfile(InputPath, 'CoordinationCheck');

OutputPath = fullfile(InputPath, '4BoSPaper2019');


if ~isdir(OutputPath)
	mkdir(OutputPath);
end


Macaques_early.filenames = {...
	'DATA_20181127T122556.A_Curius.B_Linus.SCP_01.triallog.A.Curius.B.Linus_IC_JointTrials.isOwnChoice_sideChoice', ...
	'DATA_20180516T090940.A_Tesla.B_Elmo.SCP_01.triallog.A.Tesla.B.Elmo_IC_JointTrials.isOwnChoice_sideChoice', ...
	'DATA_20180504T114516.A_Tesla.B_Flaffus.SCP_01.triallog.A.Tesla.B.Flaffus_IC_JointTrials.isOwnChoice_sideChoice', ...
	'DATA_20180525T091512.A_Tesla.B_Curius.SCP_01.triallog.A.Tesla.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
	'DATA_20180605T091549.A_Curius.B_Elmo.SCP_01.triallog.A.Curius.B.Elmo_IC_JointTrials.isOwnChoice_sideChoice', ...
	'DATA_20171108T140407.A_Magnus.B_Curius.SCP_01.triallog.A.Magnus.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
	'DATA_20171019T132932.A_Flaffus.B_Curius.SCP_01.triallog.A.Flaffus.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
	'DATA_20171129T100056.A_Magnus.B_Flaffus.SCP_01.triallog.A.Magnus.B.Flaffus_IC_JointTrials.isOwnChoice_sideChoice', ...
	'DATA_20181023T103422.A_Linus.B_Elmo.SCP_01.triallog.A.Linus.B.Elmo_IC_JointTrials.isOwnChoice_sideChoice', ...
	};

[Macaques_early.pSee, Macaques_early.pOtherChoice, Macaques_early.corrCoefValue, Macaques_early.corrPValue, ...
    Macaques_early.corrCoefAveraged, Macaques_early.corrPValueAveraged] = compute_prob_to_see_for_dataset(folder, Macaques_early.filenames, windowSize, [], minDRT, k);

Macaques_early.df = zeros(size(Macaques_early.pSee));
for i_sess = 1 : length(Macaques_early.pSee)
	Macaques_early.df(i_sess) = length(Macaques_early.pSee{i_sess}) - 2;
end
tmp_corr_data_arr = [(1:1:length(Macaques_early.df))', Macaques_early.df', Macaques_early.corrCoefAveraged', Macaques_early.corrPValueAveraged', Macaques_early.corrCoefValue', Macaques_early.corrPValue'];
xlswrite(fullfile(OutputPath, ['Composite.PseeSotherCCor.Macaques_early', '.xls']), tmp_corr_data_arr);

macaque_pair_ID_list = {'CL', 'TE', 'TF', 'TC', 'CE', 'MC', 'FC', 'MF', 'LE'};

composite_figh = figure('Name', 'pSee_SOtherC_Correlation: Macaques_early');
axis_h = fn_plot_corr_data( Macaques_early.corrCoefAveraged, {'A', 'B'}, 'bar', AB_colors, LineWidth, macaque_pair_ID_list, 'Pairs', 'Correlation coefficient r', 'Macaques_early', FontSize, FontType);
fn_configure_paper_for_figure();
write_out_figure(composite_figh, fullfile(OutputPath, ['Composite.PseeSotherCCor.Macaques_early', '.', 'pdf']));



Macaques_late.filenames = {...
	'DATA_20181211T134136.A_Curius.B_Linus.SCP_01.triallog.A.Curius.B.Linus_IC_JointTrials.isOwnChoice_sideChoice', ...
	'DATA_20180524T103704.A_Tesla.B_Elmo.SCP_01.triallog.A.Tesla.B.Elmo_IC_JointTrials.isOwnChoice_sideChoice', ...
	'DATA_20180509T122330.A_Tesla.B_Flaffus.SCP_01.triallog.A.Tesla.B.Flaffus_IC_JointTrials.isOwnChoice_sideChoice', ...
	'DATA_20180530T153325.A_Tesla.B_Curius.SCP_01.triallog.A.Tesla.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
	'DATA_20180615T111344.A_Curius.B_Elmo.SCP_01.triallog.A.Curius.B.Elmo_IC_JointTrials.isOwnChoice_sideChoice', ...
	'DATA_20180214T171119.A_Magnus.B_Curius.SCP_01.triallog.A.Magnus.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
	'DATA_20171103T143324.A_Flaffus.B_Curius.SCP_01.triallog.A.Flaffus.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
	'DATA_20180125T155742.A_Magnus.B_Flaffus.SCP_01.triallog.A.Magnus.B.Flaffus_IC_JointTrials.isOwnChoice_sideChoice', ...
	'DATA_20181120T083354.A_Linus.B_Elmo.SCP_01.triallog.A.Linus.B.Elmo_IC_JointTrials.isOwnChoice_sideChoice', ...
	};

[Macaques_late.pSee, Macaques_late.pOtherChoice, Macaques_late.corrCoefValue, Macaques_late.corrPValue, ...
    Macaques_late.corrCoefAveraged, Macaques_late.corrPValueAveraged] = compute_prob_to_see_for_dataset(folder, Macaques_late.filenames, windowSize, [], minDRT, k);

Macaques_late.df = zeros(size(Macaques_late.pSee));
for i_sess = 1 : length(Macaques_late.pSee)
	Macaques_late.df(i_sess) = length(Macaques_late.pSee{i_sess}) - 2;
end
tmp_corr_data_arr = [(1:1:length(Macaques_late.df))', Macaques_late.df', Macaques_late.corrCoefAveraged', Macaques_late.corrPValueAveraged', Macaques_late.corrCoefValue', Macaques_late.corrPValue'];
xlswrite(fullfile(OutputPath, ['Composite.PseeSotherCCor.Macaques_late', '.xls']), tmp_corr_data_arr);

composite_figh = figure('Name', 'pSee_SOtherC_Correlation: Macaques_late');
axis_h = fn_plot_corr_data( Macaques_late.corrCoefAveraged, {'A', 'B'}, 'bar', AB_colors, LineWidth, macaque_pair_ID_list, 'Pairs', 'Correlation coefficient r', 'Macaques_late', FontSize, FontType);
fn_configure_paper_for_figure()
write_out_figure(composite_figh, fullfile(OutputPath, ['Composite.PseeSotherCCor.Macaques_late', '.', 'pdf']));




% compute for humans
humanFilenames = {...
    'DATA_20171115T165545.A_20013.B_10014.SCP_01.triallog.A.20013.B.10014_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20171116T164137.A_20015.B_10016.SCP_01.triallog.A.20015.B.10016_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20171121T165717.A_10018.B_20017.SCP_01.triallog.A.10018.B.20017_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20171123T165158.A_20019.B_10020.SCP_01.triallog.A.20019.B.10020_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20171127T164730.A_20021.B_20022.SCP_01.triallog.A.20021.B.20022_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20171128T165159.A_20024.B_10023.SCP_01.triallog.A.20024.B.10023_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20171130T145412.A_20025.B_20026.SCP_01.triallog.A.20025.B.20026_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20171130T164300.A_20027.B_10028.SCP_01.triallog.A.20027.B.10028_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20171205T163542.A_20029.B_10030.SCP_01.triallog.A.20029.B.10030_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20181030T155123.A_181030ID0061S1.B_181030ID0062S1.SCP_01.triallog.A.181030ID0061S1.B.181030ID0062S1_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20181031T135826.A_181031ID63S1.B_181031ID64S1.SCP_01.triallog.A.181031ID63S1.B.181031ID64S1_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20181031T170224.A_181031ID65S1.B_181031ID66S1.SCP_01.triallog.A.181031ID65S1.B.181031ID66S1_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20181101T133927.A_181101ID67S1.B_181101ID68S1.SCP_01.triallog.A.181101ID67S1.B.181101ID68S1_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20181102T131833.A_181102ID69S1.B_181102ID70S1.SCP_01.triallog.A.181102ID69S1.B.181102ID70S1_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20190416T115438.A_190416ID103S1.B_190416ID104S1.SCP_01.triallog.A.190416ID103S1.B.190416ID104S1_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20190417T115027.A_190417ID105S1.B_190417ID106S1.SCP_01.triallog.A.190417ID105S1.B.190417ID106S1_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20190418T172245.A_190418ID107S1.B_190418ID108S1.SCP_01.triallog.A.190418ID107S1.B.190418ID108S1_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20190419T120024.A_190419ID109S1.B_190419ID110S1.SCP_01.triallog.A.190419ID109S1.B.190419ID110S1_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20190419T163215.A_190419ID111S1.B_190419ID112S1.SCP_01.triallog.A.190419ID111S1.B.190419ID112S1_IC_JointTrials.isOwnChoice_sideChoice', ...
    };
index = [1:19];
% index sorted by AR
human_sort_index = [4 19 15 11 5 3 1 14 13 2 12 16 7 9 17 8 6 10 18];


[pSeeHUmans, probOtherChoiceHumans, corrCoefValueHumans, corrPValueHumans, ...
    corrCoefAveragedHumans, corrPValueAveragedHumans] = compute_prob_to_see_for_dataset(folder, humanFilenames(human_sort_index), windowSize, index, minDRT, k);
intended_indexToShow = 12;
indexToShow = find(human_sort_index == intended_indexToShow);
indexToShow_human = indexToShow;

df_human = zeros(size(pSeeHUmans));
for i_sess = 1 : length(pSeeHUmans)
	df_human(i_sess) = length(pSeeHUmans{i_sess}) - 2;
end
pSeeHuman = pSeeHUmans{indexToShow};
pOtherChoiceHuman = probOtherChoiceHumans{indexToShow};
% these are already sorted...
humanCorr = corrCoefAveragedHumans;
humanCorrPValue = corrPValueHumans;
humancorrCoefValue = corrCoefValueHumans;
humancorrPValue = corrPValueHumans;

humanCorrToShow = corrCoefAveragedHumans(:,indexToShow);
humanPValueToShow = corrPValueAveragedHumans(:,indexToShow);

% the humans in
Humans.filenames = humanFilenames;
[Humans.pSee, Humans.pOtherChoice, Humans.corrCoefValue, Humans.corrPValue, ...
    Humans.corrCoefAveraged, Humans.corrPValueAveraged] = compute_prob_to_see_for_dataset(folder, Humans.filenames(human_sort_index), windowSize, [], minDRT, k);

Humans.df = zeros(size(Humans.pSee));
for i_sess = 1 : length(Humans.pSee)
	Humans.df(i_sess) = length(Humans.pSee{i_sess}) - 2;
end
pair_ID_list = human_sort_index;
tmp_corr_data_arr = [pair_ID_list', Humans.df', Humans.corrCoefAveraged', Humans.corrPValueAveraged', Humans.corrCoefValue', Humans.corrPValue'];
xlswrite(fullfile(OutputPath, ['Composite.PseeSotherCCor.Humans', '.xls']), tmp_corr_data_arr);

composite_figh = figure('Name', 'pSee_SOtherC_Correlation: Humans');
axis_h = fn_plot_corr_data( Humans.corrCoefAveraged, {'A', 'B'}, 'bar', AB_colors, LineWidth, pair_ID_list, 'Pairs', 'Correlation coefficient r', 'Human', FontSize, FontType);
fn_configure_paper_for_figure();
write_out_figure(composite_figh, fullfile(OutputPath, ['Composite.PseeSotherCCor.Humans', '.', 'pdf']));





% compute for Flaffus-Curius
flaffusCuriusNaiveFilenames = {...
    'DATA_20171019T132932.A_Flaffus.B_Curius.SCP_01.triallog.A.Flaffus.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20171020T124628.A_Flaffus.B_Curius.SCP_01.triallog.A.Flaffus.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20171026T150942.A_Flaffus.B_Curius.SCP_01.triallog.A.Flaffus.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20171027T145027.A_Flaffus.B_Curius.SCP_01.triallog.A.Flaffus.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20171031T124333.A_Flaffus.B_Curius.SCP_01.triallog.A.Flaffus.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20171101T123413.A_Flaffus.B_Curius.SCP_01.triallog.A.Flaffus.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20171102T102500.A_Flaffus.B_Curius.SCP_01.triallog.A.Flaffus.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20171103T143324.A_Flaffus.B_Curius.SCP_01.triallog.A.Flaffus.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
    };
flaffusCuriusConfFilenames = {...
    'DATA_20180418T143951.A_Flaffus.B_Curius.SCP_01.triallog.A.Flaffus.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180419T141311.A_Flaffus.B_Curius.SCP_01.triallog.A.Flaffus.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180424T121937.A_Flaffus.B_Curius.SCP_01.triallog.A.Flaffus.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180425T133936.A_Flaffus.B_Curius.SCP_01.triallog.A.Flaffus.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180426T171117.A_Flaffus.B_Curius.SCP_01.triallog.A.Flaffus.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180427T142541.A_Flaffus.B_Curius.SCP_01.triallog.A.Flaffus.B.Curius_IC_JointTrials.isOwnChoice_sideChoice'
    };
[pSeeNaiv, pOtherChoiceNaiv, corrCoefValueNaive, corrPValueNaive, ...
    corrCoefAveragedNaive, corrPValueAveragedNaive] = compute_prob_to_see_for_dataset(folder, flaffusCuriusNaiveFilenames, windowSize, [], minDRT, k);
df_naive = zeros(size(pSeeNaiv));
naive_indexToShow = 8;
for i_sess = 1 : length(pSeeNaiv)
	df_naive(i_sess) = length(pSeeNaiv{i_sess}) - 2;
end

[pSeeConf, pOtherChoiceConf, corrCoefValueConf, corrPValueConf, ...
    corrCoefAveragedConf, corrPValueAveragedConf] = compute_prob_to_see_for_dataset(folder, flaffusCuriusConfFilenames, windowSize, [], minDRT, k);
df_conf = zeros(size(pSeeConf));
for i_sess = 1 : length(pSeeConf)
	df_conf(i_sess) = length(pSeeConf{i_sess}) - 2;
end

indexToShow = 2;
FC_indexToShow = indexToShow;
pSeeFlaffusCuriusConf = pSeeConf{indexToShow};
pOtherChoiceFlaffusCuriusConf = pOtherChoiceConf{indexToShow};
corrCoefFlaffusCuriusConf = corrCoefAveragedConf(:,indexToShow);
corrPValueFlaffusCuriusConf = corrPValueAveragedConf(:,indexToShow);
%flaffusCuriusCorr = [corrCoefAveragedNaive, corrCoefAveragedConf];
nFlaffusCuriusNaive = length(corrCoefAveragedNaive);

allOwnChoice = [];
allInitialFixationTime = [];
nSession = 5;
sessionBorderFlaffusCuriusNaive = zeros(1, nSession);
iSession = 2;

% only the last session:
nSession = 1;

initialFixationTime = [];
targetAcquisitionTime = [];
IniTargRel_05MT_Time = [];

for i = nFlaffusCuriusNaive - nSession + 1 : nFlaffusCuriusNaive
    fullname = [folder, filesep, flaffusCuriusNaiveFilenames{i} '.mat'];
    load(fullname);
    
    % copy the rest to the processing function
    %targetAcquisitionTime = [PerTrialStruct.A_TargetAcquisitionRT'; PerTrialStruct.B_TargetAcquisitionRT'];
    initialFixationTime = [PerTrialStruct.A_InitialTargetReleaseRT'; PerTrialStruct.B_InitialTargetReleaseRT'];
    allInitialFixationTime = [allInitialFixationTime, initialFixationTime];
	
    initialFixationTime = [initialFixationTime, [PerTrialStruct.A_InitialTargetReleaseRT'; PerTrialStruct.B_InitialTargetReleaseRT']];
    targetAcquisitionTime = [targetAcquisitionTime, [PerTrialStruct.A_TargetAcquisitionRT'; PerTrialStruct.B_TargetAcquisitionRT']];
	IniTargRel_05MT_Time = [IniTargRel_05MT_Time, [PerTrialStruct.A_IniTargRel_05MT_RT'; PerTrialStruct.B_IniTargRel_05MT_RT']];	
	
    allOwnChoice = [allOwnChoice, isOwnChoice];
    if (iSession <= nSession)
        sessionBorderFlaffusCuriusNaive(iSession) = length(current_reference_Time);
        iSession = iSession + 1;
    end
end
current_reference_Time = IniTargRel_05MT_Time;

FCnaive_indexToShow = nFlaffusCuriusNaive;
allOtherChoice = 1 - allOwnChoice;
pSeeRawNaive = calc_probabilities_to_see(current_reference_Time, minDRT);
[tmp_r, tmp_p, corrCoefFlaffusCuriusNaiveJoint, corrPValueFlaffusCuriusNaiveJoint] ...
    = calc_prob_to_see_correlation(pSeeRawNaive, allOwnChoice, windowSize);
pSeeFlaffusCuriusNaiveJoint = movmean(pSeeRawNaive, windowSize, 2);
pOtherChoiceFlaffusCuriusNaiveJoint = movmean(allOtherChoice, windowSize, 2);

%
[tmp_r_50, tmp_p_50, corrCoefFlaffusCuriusNaiveJoint_50, corrPValueFlaffusCuriusNaiveJoint_50] ...
    = calc_prob_to_see_correlation(pSeeRawNaive(:, 50:end), allOwnChoice(:, 50:end), windowSize);



SMFlaffusFilenames = {...
    'DATA_20180131T155005.A_SM.B_Flaffus.SCP_01.triallog.A.SM.B.Flaffus_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180201T162341.A_SM.B_Flaffus.SCP_01.triallog.A.SM.B.Flaffus_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180202T144348.A_SM.B_Flaffus.SCP_01.triallog.A.SM.B.Flaffus_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180205T122214.A_SM.B_Flaffus.SCP_01.triallog.A.SM.B.Flaffus_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180209T145624.A_SM.B_Flaffus.SCP_01.triallog.A.SM.B.Flaffus_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180213T133932.A_SM.B_Flaffus.SCP_01.triallog.A.SM.B.Flaffus_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180214T141456.A_SM.B_Flaffus.SCP_01.triallog.A.SM.B.Flaffus_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180215T131327.A_SM.B_Flaffus.SCP_01.triallog.A.SM.B.Flaffus_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180216T140913.A_SM.B_Flaffus.SCP_01.triallog.A.SM.B.Flaffus_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180220T133215.A_SM.B_Flaffus.SCP_01.triallog.A.SM.B.Flaffus_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180221T133419.A_SM.B_Flaffus.SCP_01.triallog.A.SM.B.Flaffus_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180222T121106.A_SM.B_Flaffus.SCP_01.triallog.A.SM.B.Flaffus_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180223T143339.A_SM.B_Flaffus.SCP_01.triallog.A.SM.B.Flaffus_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180227T151756.A_SM.B_Flaffus.SCP_01.triallog.A.SM.B.Flaffus_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180228T132647.A_SM.B_Flaffus.SCP_01.triallog.A.SM.B.Flaffus_IC_JointTrials.isOwnChoice_sideChoice'%, ...
    %'DATA_20180406T111431.A_Flaffus.B_SM.SCP_01.triallog.A.Flaffus.B.SM_IC_JointTrials.isOwnChoice_sideChoice', ...
    %'DATA_20180409T145457.A_Flaffus.B_SM.SCP_01.triallog.A.Flaffus.B.SM_IC_JointTrials.isOwnChoice_sideChoice', ...
    %'DATA_20180410T125708.A_Flaffus.B_SM.SCP_01.triallog.A.Flaffus.B.SM_IC_JointTrials.isOwnChoice_sideChoice', ...
    %'DATA_20180411T104941.A_Flaffus.B_SM.SCP_01.triallog.A.Flaffus.B.SM_IC_JointTrials.isOwnChoice_sideChoice', ...
    %'DATA_20180413T113720.A_Flaffus.B_SM.SCP_01.triallog.A.Flaffus.B.SM_IC_JointTrials.isOwnChoice_sideChoice', ...
    %'DATA_20180416T122545.A_Flaffus.B_SM.SCP_01.triallog.A.Flaffus.B.SM_IC_JointTrials.isOwnChoice_sideChoice', ...
    %'DATA_20180416T124439.A_Flaffus.B_SM.SCP_01.triallog.A.Flaffus.B.SM_IC_JointTrials.isOwnChoice_sideChoice', ...
    %'DATA_20180417T161836.A_Flaffus.B_SM.SCP_01.triallog.A.Flaffus.B.SM_IC_JointTrials.isOwnChoice_sideChoice', ...
    %'DATA_20180423T141825.A_Flaffus.B_SM.SCP_01.triallog.A.Flaffus.B.SM_IC_JointTrials.isOwnChoice_sideChoice', ...
    };

SMCuriusFilenames = {...
    'DATA_20171206T141710.A_SM.B_Curius.SCP_01.triallog.A.SM.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20171208T140548.A_SM.B_Curius.SCP_01.triallog.A.SM.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20171211T110911.A_SM.B_Curius.SCP_01.triallog.A.SM.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20171212T104819.A_SM.B_Curius.SCP_01.triallog.A.SM.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180111T130920.A_SM.B_Curius.SCP_01.triallog.A.SM.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180112T103626.A_SM.B_Curius.SCP_01.triallog.A.SM.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180118T120304.A_SM.B_Curius.SCP_01.triallog.A.SM.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
    'DATA_20180423T162330.A_SM.B_Curius.SCP_01.triallog.A.SM.B.Curius_IC_JointTrials.isOwnChoice_sideChoice', ...
    };

pSeeMonkeyTraining = cell(2,1);
pOtherChoiceMonkeyTraining = cell(2,1);
monkeyTrainingCorr = cell(2,1);
monkeyTrainingPValue = cell(2,1);
monkeyTrainingCorrRaw = cell(2,1);
monkeyTrainingPValueRaw = cell(2,1);
df_monkeyTraining = cell(2,1);

monkeyTrainingCorrToShow = zeros(2,1);
monkeyTrainingPValueToShow = zeros(2,1);


%index = [1:21,21:23];
indexToShow = 15;
SMF_indexToShow = indexToShow;
[pSee, probOtherChoice, corrCoef, corrPValue, ...
    corrCoefAveraged, corrPValueAveraged] = compute_prob_to_see_for_dataset(folder, SMFlaffusFilenames, windowSize, [], minDRT, k);
pSeeMonkeyTraining{1} = pSee{indexToShow}(2,:);
pOtherChoiceMonkeyTraining{1} = probOtherChoice{indexToShow}(2,:);
monkeyTrainingCorr{1} = corrCoefAveraged(2,:);
monkeyTrainingPValue{1} = corrPValueAveraged(2,:);

monkeyTrainingCorrRaw{1} = corrCoef(2,:);
monkeyTrainingPValueRaw{1} = corrPValue(2,:);

monkeyTrainingCorrToShow(1) = corrCoefAveraged(2,indexToShow);
monkeyTrainingPValueToShow(1) = corrPValueAveraged(2,indexToShow);

for i_sess = 1 : length(pSee)
	df_monkeyTraining{1}(i_sess) = length(pSee{i_sess}) - 2;
end


indexToShow = 8;
SMC_indexToShow = indexToShow;
[pSee, probOtherChoice, corrCoef, corrPValue, ...
    corrCoefAveraged, corrPValueAveraged] = compute_prob_to_see_for_dataset(folder, SMCuriusFilenames, windowSize, [], minDRT, k);
pSeeMonkeyTraining{2} = pSee{indexToShow}(2,:);
pOtherChoiceMonkeyTraining{2} = probOtherChoice{indexToShow}(2,:);
monkeyTrainingCorr{2} = corrCoefAveraged(2,:);
monkeyTrainingPValue{2} = corrPValueAveraged(2,:);

monkeyTrainingCorrRaw{2} = corrCoef(2,:);
monkeyTrainingPValueRaw{2} = corrPValue(2,:);


monkeyTrainingCorrToShow(2) = corrCoefAveraged(2,indexToShow);
monkeyTrainingPValueToShow(2) = corrPValueAveraged(2,indexToShow);

for i_sess = 1 : length(pSee)
	df_monkeyTraining{2}(i_sess) = length(pSee{i_sess}) - 2;
end



% yellow-orange, purple
plotColor = [0.9290, 0.6940, 0.1250; ...
     0.4940, 0.1840, 0.5560];

imageName = 'correlationCompositePlot';

composite_figh = figure('Name', 'pSee_SOtherC_Correlation');
set( axes,'fontsize', FontSize, 'FontName', FontType);

% plot humans
playerName = {'A', 'B'};
subplot(4,3,10)
b = bar(corrCoefAveragedHumans');
% b(1).FaceColor = [0, 0.4470, 0.7410];
% b(2).FaceColor = [0.85, 0.325, 0.098];
b(2).FaceColor = [0, 0.4470, 0.7410];
b(1).FaceColor = [0.85, 0.325, 0.098];
box(gca, 'off');
set( gca, 'fontsize', FontSize, 'FontName', FontType);
xlabel( 'Pair', 'fontsize', FontSize, 'FontName', FontType);
set(gca, 'XTick', (1:1:length(index)));
set(gca, 'XTickLabel', human_sort_index, 'XTickLabelRotation', 90);
ylabel( 'Correlation', 'fontsize', FontSize, 'FontName', FontType);
titleText = 'Human pairs';
title(titleText, 'fontsize', FontSize, 'FontName',FontType)
axis( [0.5, length(corrCoefAveragedHumans)+0.5, -1, 1]);

%tmp_corr_data_arr = [human_sort_index', df_human', humanCorr', humanCorrPValue', humancorrCoefValue', corrPValueAveraged'];
tmp_corr_data_arr = [human_sort_index', df_human', corrCoefAveragedHumans', corrPValueAveragedHumans', corrCoefValueHumans', corrPValueHumans'];


xlswrite(fullfile(OutputPath, ['Composite.PseeSotherCCor.Human', '.xls']), tmp_corr_data_arr);

for iPlot = 1:2
    nTrial = length(pSeeHuman(1,:));
    subplot(4,3,10 + iPlot)
    hold on
    plot (pSeeHuman(iPlot,:), 'color', plotColor(1,:), 'linewidth', LineWidth);
    %plot (pOtherChoiceHuman(iPlot,:), 'color', plotColor(2,:), 'linewidth', LineWidth);
    plot (pOtherChoiceHuman(iPlot,:), 'color', AB_colors(iPlot, :), 'linewidth', LineWidth);
    hold off;
    if (iPlot == 2)
        lHandle = legend('p_{see}', 'p_{other}', 'Location', 'NorthEast');
        set(lHandle, 'fontsize', FontSize, 'FontName',FontType);
    end
    set( gca, 'fontsize', FontSize, 'FontName', FontType);
    xlabel( 'Trials', 'fontsize', FontSize, 'FontName', FontType);
    ylabel( 'Probability', 'fontsize', FontSize, 'FontName', FontType);
    
    titleText = ['Pair ', num2str(intended_indexToShow), ' ', playerName{iPlot}, sprintf(', %.2f (%.0d)', humanCorrToShow(iPlot), humanPValueToShow(iPlot))];
    titleText = ['Pair ', num2str(intended_indexToShow), ' ', playerName{iPlot}, ': r(', num2str(nTrial-2),'): ', num2str(humanCorrToShow(iPlot), '%.2f'), ', p <= ', num2str(humanPValueToShow(iPlot), '%.0d')];
    title(titleText, 'fontsize', FontSize, 'FontName',FontType)
    axis( [0, nTrial, 0, 1.1]);
end

% plot Naive macaques
playerName = {'F', 'C'};
subplot(4,3,1)
hold on
plot(corrCoefAveragedNaive(1, :), '-o', 'linewidth', LineWidth, 'color', AB_colors(1, :));
plot(corrCoefAveragedNaive(2, :), '-o', 'linewidth', LineWidth, 'color', AB_colors(2, :));
plot([.8, length(corrCoefAveragedNaive)+0.2], [0,0], 'k--', 'linewidth', 1);
hold off
set( gca, 'fontsize', FontSize, 'FontName', FontType);
lHandle = legend(playerName, 'Location', 'SouthEast');
set(lHandle, 'fontsize', FontSize-4, 'FontName',FontType);
xlabel( 'Session', 'fontsize', FontSize, 'FontName', FontType);
ylabel( 'Correlation', 'fontsize', FontSize, 'FontName', FontType);
titleText = 'F-C naive';
title(titleText, 'fontsize', FontSize, 'FontName',FontType)
axis( [0.8, length(corrCoefAveragedNaive)+0.2, -1, 1]);

tmp_corr_data_arr = [(1:1:length(df_naive))', df_naive', corrCoefAveragedNaive', corrPValueAveragedNaive', corrCoefValueNaive', corrPValueNaive'];
xlswrite(fullfile(OutputPath, ['Composite.PseeSotherCCor.NaivMacaque', '.xls']), tmp_corr_data_arr);

for iPlot = 1:2
    nTrial = length(pSeeFlaffusCuriusNaiveJoint(1,:));
    subplot(4,3,1 + iPlot)
    hold on
    plot (pSeeFlaffusCuriusNaiveJoint(iPlot,:), 'color', plotColor(1,:), 'linewidth', 1);
    %plot (pOtherChoiceFlaffusCuriusNaiveJoint(iPlot,:), 'color', plotColor(2,:), 'linewidth', 1);
    plot(pOtherChoiceFlaffusCuriusNaiveJoint(iPlot,:), 'color', AB_colors(iPlot, :), 'linewidth', LineWidth);

    for iSession = 2:length(sessionBorderFlaffusCuriusNaive)
        x = sessionBorderFlaffusCuriusNaive(iSession);
        plot([x,x], [0,1.1], '--k', 'linewidth', 1);
    end
    hold off;
    set( gca, 'fontsize', FontSize, 'FontName', FontType);
    xlabel( 'Trials', 'fontsize', FontSize, 'FontName', FontType);
    ylabel( 'Probability', 'fontsize', FontSize, 'FontName', FontType);
    %    titleText = ['Player ', num2str(iPlot) ': ' sprintf('%.2f', corrCoefValue(iPlot)) ' (' sprintf('%.0d', corrPValue(iPlot)) ') / ' ...
    %        sprintf('%.2f', corrCoefAveraged(iPlot)) ' (' sprintf('%.0d', corrPValueAveraged(iPlot)) ')'];
    titleText = [num2str(FCnaive_indexToShow), ': ', playerName{iPlot}, sprintf(' late sessions, %.2f (%.0d)', corrCoefFlaffusCuriusNaiveJoint(iPlot), corrPValueFlaffusCuriusNaiveJoint(iPlot))];
    titleText = [num2str(FCnaive_indexToShow), ': ', playerName{iPlot}, ': r(', num2str(nTrial-2),'): ', num2str(corrCoefFlaffusCuriusNaiveJoint(iPlot), '%.2f'), ', p <= ', num2str(corrPValueFlaffusCuriusNaiveJoint(iPlot), '%.0d')];

    title(titleText, 'fontsize', FontSize, 'FontName',FontType)
    axis( [0, nTrial, 0, 1.1]);
end

% plot macaques during training
playerName = {'F', 'C'};
subplot(4,3,4)
nSession = max(length(monkeyTrainingCorr{1}), length(monkeyTrainingCorr{2}));
hold on
plot(monkeyTrainingCorr{1}, '-o', 'linewidth', LineWidth, 'color', AB_colors(1, :));
plot(monkeyTrainingCorr{2}, '-o', 'linewidth', LineWidth, 'color', AB_colors(2, :));
plot([.8, nSession+0.2], [0,0], 'k--', 'linewidth', 1);
hold off
set( gca, 'fontsize', FontSize, 'FontName', FontType);
lHandle = legend(playerName, 'Location', 'SouthEast');
set(lHandle, 'fontsize', FontSize-4, 'FontName',FontType);
xlabel( 'Session', 'fontsize', FontSize, 'FontName', FontType);
ylabel( 'Correlation', 'fontsize', FontSize, 'FontName', FontType);
titleText = 'Confederate training';
title(titleText, 'fontsize', FontSize, 'FontName',FontType)
axis( [0.8, nSession+0.2, -1, 1]);

tmp_corr_data_arr = [[(1:1:length(df_monkeyTraining{1})), (1:1:length(df_monkeyTraining{2}))]', ...
	[df_monkeyTraining{1}, df_monkeyTraining{2}]', ...
	[monkeyTrainingCorr{1}, monkeyTrainingCorr{2}]', [monkeyTrainingPValue{1}, monkeyTrainingPValue{2}]', ...
	[monkeyTrainingCorrRaw{1}, monkeyTrainingCorrRaw{2}]', [monkeyTrainingPValueRaw{1}, monkeyTrainingPValueRaw{2}]'];
xlswrite(fullfile(OutputPath, ['Composite.PseeSotherCCor.ConfMacaque', '.xls']), tmp_corr_data_arr);

for iPlot = 1:2
    nTrial = length(pSeeMonkeyTraining{iPlot});
    subplot(4,3,4 + iPlot)
    hold on
    plot(pSeeMonkeyTraining{iPlot}, 'color', plotColor(1,:), 'linewidth', LineWidth);
    %plot(pOtherChoiceMonkeyTraining{iPlot}, 'color', plotColor(2,:), 'linewidth', LineWidth);
    plot(pOtherChoiceMonkeyTraining{iPlot}, 'color', AB_colors(iPlot, :), 'linewidth', LineWidth);
    
    hold off;
    set( gca, 'fontsize', FontSize, 'FontName', FontType);
    xlabel( 'Trials', 'fontsize', FontSize, 'FontName', FontType);
    ylabel( 'Probability', 'fontsize', FontSize, 'FontName', FontType);
	
    switch (iPlot)
		case 1
			cur_index_to_show = SMF_indexToShow;
		case 2
			cur_index_to_show = SMC_indexToShow;
	end
	
	titleText = [num2str(cur_index_to_show), ': ', playerName{iPlot}, sprintf(', %.2f (%.0d)', monkeyTrainingCorrToShow(iPlot), monkeyTrainingPValueToShow(iPlot))];
	titleText = [num2str(cur_index_to_show), ': ', playerName{iPlot}, ': r(', num2str(nTrial-2),'): ', num2str(monkeyTrainingCorrToShow(iPlot), '%.2f'), ', p <= ', num2str(monkeyTrainingPValueToShow(iPlot), '%.0d')];

    title(titleText, 'fontsize', FontSize, 'FontName',FontType)
    axis( [0, nTrial, 0, 1.1]);
end

monkeyTrainingCorr{2} = corrCoefAveraged(2,:);
monkeyTrainingCorrToShow(2) = corrCoefAveraged(2,indexToShow);
monkeyTrainingPValueToShow(2) = corrPValueAveraged(2,indexToShow);



% plot trained macaques
playerName = {'F', 'C'};
subplot(4,3,7)
hold on
%plot(corrCoefAveragedConf', '-o', 'linewidth', LineWidth);
plot(corrCoefAveragedConf(1, :), '-o', 'linewidth', LineWidth, 'color', AB_colors(1, :));
plot(corrCoefAveragedConf(2, :), '-o', 'linewidth', LineWidth, 'color', AB_colors(2, :));
plot([.8, length(corrCoefAveragedConf)+0.2], [0,0], 'k--', 'linewidth', 1);
hold off
set( gca, 'fontsize', FontSize, 'FontName', FontType);
lHandle = legend(playerName, 'Location', 'SouthEast');
set(lHandle, 'fontsize', FontSize-4, 'FontName',FontType);
xlabel( 'Session', 'fontsize', FontSize, 'FontName', FontType);
ylabel( 'Correlation', 'fontsize', FontSize, 'FontName', FontType);
titleText = 'F-C trained';
title(titleText, 'fontsize', FontSize, 'FontName',FontType)
axis( [0.8, length(corrCoefAveragedConf)+0.2, -1, 1]);

tmp_corr_data_arr = [(1:1:length(df_conf))', df_conf', corrCoefAveragedConf', corrPValueAveragedConf', corrCoefValueConf', corrPValueConf'];
xlswrite(fullfile(OutputPath, ['Composite.PseeSotherCCor.TrainedMacaquePair', '.xls']), tmp_corr_data_arr);


for iPlot = 1:2
    nTrial = length(pSeeFlaffusCuriusConf(1,:));
    subplot(4,3,7 + iPlot)
    hold on
    plot(pSeeFlaffusCuriusConf(iPlot,:), 'color', plotColor(1,:), 'linewidth', LineWidth);
    plot(pOtherChoiceFlaffusCuriusConf(iPlot,:), 'color', plotColor(2,:), 'linewidth', LineWidth);
    plot(pOtherChoiceFlaffusCuriusConf(iPlot,:), 'color', AB_colors(iPlot, :), 'linewidth', LineWidth);
    
    hold off;
    set( gca, 'fontsize', FontSize, 'FontName', FontType);
    xlabel( 'Trials', 'fontsize', FontSize, 'FontName', FontType);
    ylabel( 'Probability', 'fontsize', FontSize, 'FontName', FontType);
    %    titleText = ['Player ', num2str(iPlot) ': ' sprintf('%.2f', corrCoefValue(iPlot)) ' (' sprintf('%.0d', corrPValue(iPlot)) ') / ' ...
    %        sprintf('%.2f', corrCoefAveraged(iPlot)) ' (' sprintf('%.0d', corrPValueAveraged(iPlot)) ')'];
    titleText = [num2str(FC_indexToShow), ': ', playerName{iPlot}, sprintf(', %.2f (%.0d)', corrCoefFlaffusCuriusConf(iPlot), corrPValueFlaffusCuriusConf(iPlot))];
    titleText = [num2str(FC_indexToShow), ': ', playerName{iPlot}, ': r(', num2str(nTrial-2),'): ', num2str(corrCoefFlaffusCuriusConf(iPlot), '%.2f'), ', p <= ', num2str(corrPValueFlaffusCuriusConf(iPlot), '%.0d')];
    title(titleText, 'fontsize', FontSize, 'FontName',FontType)
    axis( [0, nTrial, 0, 1.1]);
end

%axis( [min(dltX), max(dltX), 0, 1.15*max(dRT)] );

% 	[output_rect] = fnFormatPaperSize(DefaultPaperSizeType, gcf, output_rect_fraction);
% 	set(gcf(), 'Units', 'centimeters', 'Position', output_rect, 'PaperPosition', output_rect);


% set( gcf, 'Units', 'centimeters', 'PaperUnits','centimeters' );
% xSize = 20; ySize = 20; %10;
% xLeft = 0; yTop = 0;
% set(gcf, 'PaperSize', [ xSize ySize ], 'PaperOrientation', 'portrait', 'PaperUnits', 'centimeters');
% set( gcf,'PaperPosition', [ xLeft yTop xSize ySize ],  'Position',  [ xLeft yTop xSize ySize ]);

fn_configure_paper_for_figure();
OutPutType = 'pdf';
outfile_fqn = fullfile(OutputPath, ['Composite.PseeSotherCCor.byGroup', '.', OutPutType]);
write_out_figure(composite_figh, outfile_fqn);

%OutPutType = 'fig';
%outfile_fqn = fullfile(OutputPath, ['Composite.PseeSotherCCor.byGroup', '.', OutPutType]);
%write_out_figure(composite_figh, outfile_fqn);

% print ( '-depsc', '-r600', [imageName '.eps']);
% print ( '-dtiff', '-r600', [imageName '.tiff']);


set( gcf, 'Units', 'centimeters', 'PaperUnits','centimeters' );
xSize = 27; ySize = 27; %10;
xLeft = 0; yTop = 0;
set( gcf,'PaperPosition', [ xLeft yTop xSize ySize ],  'Position',  [ xLeft yTop xSize ySize ]);

OutPutType = 'png';
outfile_fqn = fullfile(OutputPath, ['Composite.PseeSotherCCor.byGroup', '.', OutPutType]);
print ( '-dpng', '-r600', outfile_fqn);
end



function [pSee, probOtherChoice, corrCoefValue, corrPValue, ...
    corrCoefAveraged, corrPValueAveraged] = compute_prob_to_see_for_dataset(folder, fileArray, windowSize, sessionIndex, minDRT, k )

if (~exist('minDRT', 'var') || isempty(minDRT) )
    minDRT = 50;
end

if (~exist('sessionIndex', 'var') || isempty(sessionIndex) )
    sessionIndex = 1:length(fileArray);
end





nFile = length(unique(sessionIndex));
pSee = cell(1, nFile);
probOtherChoice = cell(1, nFile);
corrCoefValue = zeros(2,nFile);
corrPValue = zeros(2,nFile);
corrCoefAveraged = zeros(2,nFile);
corrPValueAveraged = zeros(2,nFile);

indexLast = 0;
for i = 1:length(fileArray)
    fullname = fullfile(folder, [fileArray{i} '.mat']);
    load(fullname, 'isOwnChoice', 'PerTrialStruct');
    if sessionIndex(i) ~= indexLast
        initialFixationTime = [];
		targetAcquisitionTime = [];
		IniTargRel_05MT_Time = [];
        isOtherChoice = [];
    end
    isOtherChoice = [isOtherChoice, 1 - isOwnChoice];
    initialFixationTime = [initialFixationTime, [PerTrialStruct.A_InitialTargetReleaseRT'; PerTrialStruct.B_InitialTargetReleaseRT']];
    targetAcquisitionTime = [targetAcquisitionTime, [PerTrialStruct.A_TargetAcquisitionRT'; PerTrialStruct.B_TargetAcquisitionRT']];
	IniTargRel_05MT_Time = [IniTargRel_05MT_Time, [PerTrialStruct.A_IniTargRel_05MT_RT'; PerTrialStruct.B_IniTargRel_05MT_RT']];
	
	current_reference_Time = IniTargRel_05MT_Time;
	
    if sessionIndex(i) ~= indexLast
        iSession = sessionIndex(i);
        isOwnChoice = 1 - isOtherChoice; % recompute back to  ensure merging of several files
        % copy the rest to the processing function
        pSeeRaw = calc_probabilities_to_see(current_reference_Time, minDRT, k);
        [corrCoefValue(:,iSession), corrPValue(:,iSession), ...
            corrCoefAveraged(:,iSession), corrPValueAveraged(:,iSession)] ...
            = calc_prob_to_see_correlation(pSeeRaw, isOwnChoice, windowSize);
        
        pSee{iSession} = movmean(pSeeRaw, windowSize, 2);
        probOtherChoice{iSession} = movmean(isOtherChoice, windowSize, 2);
    end
    indexLast = sessionIndex(i);
end
end


function [ axis_h ] = fn_plot_corr_data( data, row_names, plot_type_string, AB_color_arr, LineWidth, xtick_label_list, xlabel_string, ylabel_string, title_string, FontSize, FontType )
%TODO turn into function for bar plot and/line plot
%playerName = {'A', 'B'};


set( gca, 'fontsize', FontSize, 'FontName', FontType);

switch plot_type_string
	case 'bar'
		axis_h = bar(data');
		% b(1).FaceColor = [0, 0.4470, 0.7410];
		% b(2).FaceColor = [0.85, 0.325, 0.098];
		axis_h(2).FaceColor = AB_color_arr(1, :); %[0, 0.4470, 0.7410];
		axis_h(1).FaceColor = AB_color_arr(2, :); %[0.85, 0.325, 0.098];
		box(gca, 'off');
		axis( [0.5, length(data)+0.5, -1, 1]);

	case 'line'
		hold on
		%plot(corrCoefAveragedConf', '-o', 'linewidth', LineWidth);
		plot(data(1, :), '-o', 'linewidth', LineWidth, 'color', AB_color_arr(1, :));
		plot(data(2, :), '-o', 'linewidth', LineWidth, 'color', AB_color_arr(2, :));
		plot([.8, length(data)+0.2], [0,0], 'k--', 'linewidth', 1);
		hold off	
		axis( [0.8, length(data)+0.2, -1, 1]);
end

xlabel( xlabel_string, 'fontsize', FontSize, 'FontName', FontType, 'Interpreter', 'none');
if ~isempty(xtick_label_list)
	set(gca, 'XTick', (1:1:length(xtick_label_list)));
	
	XTickLabelRotation_val = 0;
	if length(xtick_label_list) > 12
		XTickLabelRotation_val = 90;
	end
	set(gca, 'XTickLabel', xtick_label_list, 'XTickLabelRotation', XTickLabelRotation_val);
end
ylabel( ylabel_string, 'fontsize', FontSize, 'FontName', FontType, 'Interpreter', 'none');
title(title_string, 'fontsize', FontSize, 'FontName', FontType, 'Interpreter', 'none')

%legend?
if ~isempty(row_names)
	lHandle = legend(row_names, 'Location', 'SouthEast');
	set(lHandle, 'fontsize', FontSize-4, 'FontName', FontType);
end

return
end

function [] = fn_configure_paper_for_figure()

set( gcf, 'Units', 'centimeters', 'PaperUnits','centimeters' );
xSize = 20; ySize = 20; %10;
xLeft = 0; yTop = 0;
set(gcf, 'PaperSize', [ xSize ySize ], 'PaperOrientation', 'portrait', 'PaperUnits', 'centimeters');
set( gcf,'PaperPosition', [ xLeft yTop xSize ySize ],  'Position',  [ xLeft yTop xSize ySize ]);

return
end
