function coordinationStruct = check_coordination(isOwnChoice, sideChoice, alpha)
% check_coordination tests whether there is a coordination between two players.
% The test is compound and consists of 7 subtests
% 1) Test of target choice independendence:
%    Fisher test on target choices contingency table (TCCT),
%    rejecting null hypothesis is an indication of coordination.
%    Outcome: pValue. pValue > alpha => independent choices;
%                     pValue < alpha => coordinated choices.
% 2) Test of side choice independendence:
%    Fisher test on side choices contingency table,
%    rejecting null hypothesis is an indication of coordination.
%    Outcome: pValue. pValue > alpha => independent choices;
%                     pValue < alpha => coordinated choices.
% 3) Test of same choice preference:
%    Upper-tailed binomial test:
%    is proportion of same choices (sum over TCCT anti-diagonal) higher than
%    chance (0.5)? If same choices are significantly more frequent than 50%,
%    this indicates that players effectively coordinate to increase total payoff.
%    Outcome: pValue. pValue > alpha => uneffective or non-pay-off driven coordination;
%                     pValue < alpha => effective coordination.
% 4-5) Tests of selfishness for each player:
%    Two-tailed binomial test:
%    is proportion of OWN choices (sum over TCCT 1st row/column) higher than
%    chance (0.5)? If OWN choices are significantly more frequent than 50%,
%    this indicates player selfishness. If tests 1-2 indicate coordination,
%    prevalence of OWN choices for one player indicates that coordination is
%    unfair and beneficial for him.
%    Outcome: zScore. zScore > epsilon => selfish choices;
%                     epsilon > zScore > -epsilon => may indicate fair coordination;
%                     zScore < -epsilon => self-sacrificing choices.
% 6-7) Tests of matching avoidance for each player:
%    Upper-tailed Binomial test:
%    is proportion of different choices among other choices higher than
%    chance (0.5)? If different choices of a player are significantly more
%    frequent than 50% of other choices, this indicates matching avoidance.
%    Outcome: pValue. pValue > alpha => no matching avoidance;
%                     pValue < alpha => matching avoidance.
%
% INPUT
%   - isOwnChoice - 2xN array of booleans,
%     isOwnChoice(i,j) = 1 indicated that player i at trial j selected own target;
%   - sideChoice - 2xN array of booleans,
%     sideChoice(i,j) = 1 indicated that player i at trial j selected side 1;
% OPTIONAL INPUT
%  - alpha - significance level (by default alpha = 0.05)
%
% OUTPUT:
%   coordinationStruct - a structure with fields:
%   - targetChoiceIndependence - pValue for independence of side choices of two players;
%   - sideChoiceIndependence - pValue for independence of target choices of two players;
%   - noSamePreference - pValue for proportion of same choices being at chance
%      level (50%) or below;
%   - ownPreference - 1x2 array of zScores for proportions of OWN choices of
%     each player being significantly higher than 50%;
%   - noMatchingAvoidance - 1x2 array of pValues for proportions of different
%     choices among other choices of each player being at chance level (50%)
%     or below.
%   - SummaryString - test results condensed to a single-line string; 
%   - SummaryCell - test results condensed to a cell array (multi-line string);
%   - shortOutcome - 1x7 array with short description of players' interaction:
%        shortOutcome[1] = 1 for coordinated target choice, 0 otherwise
%        shortOutcome[2] = 1 for coordinated side choice, 0 otherwise
%        shortOutcome[3] = 1 for joint prefernce of choosing same, 0 otherwise
%        shortOutcome[4-5] = 1 for own target preference,
%                           -1 for other side preference,
%                            0 otherwise (one value for each player)
%        shortOutcome[6-7] = 1 for matching avoidence, 0 otherwise (one value for each players)
%
% EXAMPLE of use
%{
 N = 200;
 target1 = randi(2, 1, N) - 1; %random choices
 side1 = randi(2, 1, N) - 1; %random choices
 target2 = (~target1) | side1; %P2 selects own target if P1 selects other target
                               %or P1 selects right target
 side2 = xor(side1, ~xor(target1, target2));
 isOwnChoice = [target1; target2];
 sideChoice = [side1; side2];
 coord = check_coordination(isOwnChoice, sideChoice);
 % expected outcomes:
 % coord.targetChoiceIndependence, coord.sideChoiceIndependence - almost 0;
 % coord.noSamePreference - almost 0;
 % coord.ownPreference[1] in [-1, 1], coord.ownPreference[2] > 2;
 % coord.noMatchingAvoidance - almost 1;
 % coord.shortOutcome
%}

if (nargin >= 3) && isnumeric(alpha) && (alpha >= 0) && (alpha <= 1)
    % nothing to do we just accept the given alpha as valid
else
    alpha = 0.05;
end

% Test 1: target choice independendence
nOwnOwn = nnz(isOwnChoice(1, :) & isOwnChoice(2, :));
nOwnOther = nnz(isOwnChoice(1, :) & (~isOwnChoice(2, :)));
nOtherOwn = nnz((~isOwnChoice(1, :)) & isOwnChoice(2, :));
nOtherOther = nnz((~isOwnChoice(1, :)) & (~isOwnChoice(2, :)));
contMatrix = [nOwnOwn, nOwnOther; nOtherOwn, nOtherOther];
[~, coordinationStruct.targetChoiceIndependence] = fishertest(contMatrix);

% Test 2: side choice independendence
nSide2Side2 = nnz(sideChoice(1, :) & sideChoice(2, :));
nSide2Side1 = nnz(sideChoice(1, :) & (~sideChoice(2, :)));
nSide1Side2 = nnz((~sideChoice(1, :)) & sideChoice(2, :));
nSide1Side1 = nnz((~sideChoice(1, :)) & (~sideChoice(2, :)));
contMatrix = [nSide1Side1, nSide1Side2; nSide2Side1, nSide2Side2];
[~, coordinationStruct.sideChoiceIndependence] = fishertest(contMatrix);

% Test 3: same choice preference
nSame = nOwnOther + nOtherOwn;
nTotal = nOwnOwn + nSame + nOtherOther;
pChance = 0.5;
pValue = binocdf(nTotal - nSame, nTotal, pChance);
coordinationStruct.noSamePreference = pValue;

% Test 4-5: selfishness for each player
nOwnChoice = [nOwnOwn + nOwnOther,  nOwnOwn + nOtherOwn];
zScore = (nOwnChoice/nTotal - pChance)/sqrt(pChance*(1-pChance)/nTotal);
coordinationStruct.ownPreference = zScore;

% Test 6-7: matching avoidance for each player
nOtherTotal = [nOtherOwn + nOtherOther, nOwnOther + nOtherOther];
pValue = zeros(1, 2);
for i = 1:2
    pValue(i) = binocdf(nOtherTotal(i) - nOtherOther, nOtherTotal(i), pChance);
end
coordinationStruct.noMatchingAvoidance = pValue;

% Total outcome in simplified form
coordinationStruct.shortOutcome = zeros(1, 7);
coordinationStruct.shortOutcome(1) = coordinationStruct.targetChoiceIndependence < alpha;
coordinationStruct.shortOutcome(2) = coordinationStruct.sideChoiceIndependence < alpha;
coordinationStruct.shortOutcome(3) = coordinationStruct.noSamePreference < alpha;
coordinationStruct.shortOutcome(6:7) = coordinationStruct.noMatchingAvoidance < alpha;
zCritical = -norminv(alpha/2);
ownPreferenceTestOutcome = zeros(1, 2);
ownPreferenceTestOutcome(coordinationStruct.ownPreference < -zCritical) = -1;
ownPreferenceTestOutcome(coordinationStruct.ownPreference > zCritical) = 1;
coordinationStruct.shortOutcome(4:5) = ownPreferenceTestOutcome;

% now create a textual representation of the data
outString = ['Coordination summary: ', num2str(coordinationStruct.shortOutcome), ' ; significance threshold: ', num2str(alpha), ...
    ';p(TargetChoiceCoord): ', num2str(coordinationStruct.targetChoiceIndependence), '; p(sideChoiceCoord): ', num2str(coordinationStruct.sideChoiceIndependence), ...
    '; p(SameChoiceCoord): ', num2str(coordinationStruct.noSamePreference), '; Selfishness Zcrit: ', num2str(zCritical),'; Selfishness A Z: ', num2str(zScore(1)), '; Selfishness B Z: ', num2str(zScore(2)), ...
    '; p(MatchAvoidance) A: ', num2str(coordinationStruct.noMatchingAvoidance(1)), '; p(MatchAvoidance) B: ', num2str(coordinationStruct.noMatchingAvoidance(2))];



% multi line outout
outCell = {['Coordination summary: ', num2str(coordinationStruct.shortOutcome), ' ; significance threshold ', num2str(alpha), ' uncorrected.']; ...
    ['p(TargetChoiceCoord): ', num2str(coordinationStruct.targetChoiceIndependence), '; p(sideChoiceCoord): ', num2str(coordinationStruct.sideChoiceIndependence), ...
    '; p(SameChoiceCoord): ', num2str(coordinationStruct.noSamePreference)]; ...
    ['Selfishness Zcrit: ', num2str(zCritical),'; Selfishness A Z: ', num2str(zScore(1)), '; Selfishness B Z: ', num2str(zScore(2)), ...
    '; p(MatchAvoidance) A: ', num2str(coordinationStruct.noMatchingAvoidance(1)), '; p(MatchAvoidance) B: ', num2str(coordinationStruct.noMatchingAvoidance(2))]};
coordinationStruct.SummaryString = outString;
coordinationStruct.SummaryCell = outCell;

key_value_struct.alpha = alpha;
key_value_struct.P_TargetChoiceCoord = coordinationStruct.targetChoiceIndependence;
key_value_struct.P_SideChoiceCoord = coordinationStruct.sideChoiceIndependence;
key_value_struct.P_SameChoiceCoord = coordinationStruct.noSamePreference;
key_value_struct.Z_crit_Selfishness = zCritical;
key_value_struct.Z_Selfishness_A = zScore(1);
key_value_struct.Z_Selfishness_B = zScore(2);
key_value_struct.P_MatchAvoidance_A = coordinationStruct.noMatchingAvoidance(1); 
key_value_struct.P_MatchAvoidance_B = coordinationStruct.noMatchingAvoidance(2); 

coordinationStruct.key_value_struct = key_value_struct;


end
%% old version
%{

% check_coordination tests whether there is a coordination between two players
% or if they are making choices ignoring each other
%
% INPUT
%   - isOwnChoice - 2xN array of booleans
%     isOwnChoice(i,j) = 1 indicated that player i at trial j selected own target;
%   - sideChoice - 2xN array of booleans
%     sideChoice(i,j) = 1 indicated that player i at trial j selected side 1;

% OUTPUT:
%   - partnerInluenceOnSide - 2-element vector indicating whether the choice
%     of side for player i is influenced by partner choices;
%   - partnerInluenceOnTarget - 2-element vector indicating whether the choice
%     of target for player i is influenced by partner choices;
%
%   if partnerInluenceOnSide(i) == partnerInluenceOnTarget(i) == 1 then
%   the choices of player i are most likely not independent on the choices
%   of the partner
%
%
function [partnerInluenceOnSide, partnerInluenceOnTarget] = ...
          check_coordination(isOwnChoice, sideChoice)
  sameChoice = xor(isOwnChoice(1,:), isOwnChoice(2,:));
  partnerInluenceOnSide = zeros(1, 2);
  partnerInluenceOnTarget = zeros(1, 2);
  for i = 1:2 % loop over players
    for iTable = 1:2 % loop over tables: 1st for targets, 2nd for sides
      if (iTable == 1)
        x = isOwnChoice(i, :);
      else
        x = sideChoice(i, :);
      end
      nSameCase1 = nnz(x & sameChoice);
      nDifCase1 = nnz(x & (~sameChoice));
      nSameCase2 = nnz((~x) & sameChoice);
      nDifCase2 = nnz((~x) & (~sameChoice));
      
      % first we test whether number of SAME choices is larger than number
      % of choices of each side/target. If yes, this is a clear indication
      % that player tends to choose the same target as the partner
      nSameTotal = nSameCase1 + nSameCase2;
      nTotal = nSameCase1 + nSameCase2 + nDifCase1 + nDifCase2;
      nCaseTotal = max(nSameCase1 + nDifCase1, nSameCase2 + nDifCase2);
      
      p1 = nSameTotal/nTotal;
      p2 = nCaseTotal/nTotal;
      pAver = (p1 + p2)/2;
      z = (p1 - p2)/sqrt((2/nCaseTotal)*pAver*(1-pAver));
      % tests are computed for alpha = 0.01
      if (z > 2.58) % # of SAME choices is significanly larger than of  any side/target
        isInfluence = 1;
      else  % if not - compute fisher test
        contMatrix = [nSameCase1, nSameCase2; nDifCase1, nDifCase2];
        isInfluence = fishertest(contMatrix, 'Alpha',0.01);
      end
      if (iTable == 1)
        partnerInluenceOnTarget(i) = isInfluence;
      else
        partnerInluenceOnSide(i) = isInfluence;
      end
    end
  end
end
%}