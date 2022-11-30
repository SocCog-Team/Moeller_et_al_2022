function [ pSee, sigmoid_struct ] = calc_probabilities_to_see( reactionTime, minDRT, k )
% calc_probabilitiesToSee computes probabilities to see partner choice for
% the two players given their reaction times (RT). For this RT difference
% is computed and then mapped to [0,1] interval by means of logistic curve
%
% INPUT
%   - reactionTime - 2xN array of players reaction times in ms
%   - minDRT - the turning point of logistic curve in ms
% OUTPUT:
%   - pSee - 2xN array of probabilities to see partner's choice
% EXAMPLE of use
%{
    % load the data file
    ispc = 1;
    filename = 'DATA_20180419T141311.A_Flaffus.B_Curius.SCP_01.triallog.A.Flaffus.B.Curius_IC_JointTrials.isOwnChoice_sideChoice.mat';
    if ispc
        fullname = ['Z:\taskcontroller\SCP_DATA\ANALYSES\PC1000\2018\CoordinationCheck\', filename];
    else
        fullname = fullfile('/', 'Volumes', 'social_neuroscience_data', 'taskcontroller', 'SCP_DATA', 'ANALYSES', 'PC1000', '2018', 'CoordinationCheck', filename);
    end
    load(fullname);
    
    % prepare the input and compute probabilities to see
    initialFixationTime = [PerTrialStruct.A_InitialTargetReleaseRT'; PerTrialStruct.B_InitialTargetReleaseRT'];
    minDRT = 50;
    pSee = calc_probabilities_to_see(initialFixationTime, minDRT);
%}

%function pSee = calc_probabilities_to_see(reactionTime, minDRT)

if ~exist('k', 'var')
	k = 0.04; % set the slope of the logistic curve
	% smaller k - smooth transition, higher k - abrupt transition
end

nTrial = length(reactionTime);
dRT = reactionTime(1,:) - reactionTime(2,:); % compute RT difference
player1SeesIndex = (dRT > 0);
player2SeesIndex = (dRT < 0);
absDRT = abs(dRT);
pSeeBothPlayers =  1./(1 + exp(-k*(absDRT - minDRT)));
pSee = zeros(2, nTrial);
pSee(1,player1SeesIndex) = pSeeBothPlayers(player1SeesIndex);
pSee(2,player2SeesIndex) = pSeeBothPlayers(player2SeesIndex);

% in case one requres to document the parameters somewhere
sigmoid_struct.slope = k;
sigmoid_struct.min = 0;
sigmoid_struct.max = 1;
sigmoid_struct.turning_point = minDRT;

return
end