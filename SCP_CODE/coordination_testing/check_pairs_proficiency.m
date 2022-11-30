% Example:
%{
 proficiencyThreshold = 2.5;
 isPairProficient = check_pairs_proficiency(playerMeanReward, proficiencyThreshold);
%}

function isPairProficient = check_pairs_proficiency(playerMeanReward, proficiencyThreshold)
    arePlayersProficient = playerMeanReward >= proficiencyThreshold;
    isPairProficient = arePlayersProficient(1,:) & arePlayersProficient(2,:);
end