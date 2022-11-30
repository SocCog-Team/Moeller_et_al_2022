% calc_probabilitiesToSee computes probabilities to see partner choice for
% the two players given their reaction times (RT). For this RT difference
% is computed and then mapped to [0,1] interval by means of logistic curve
%
% INPUT
%   - reactionTime - 2xN array of players reaction times in ms 
%   - isOwnChoice - 2xN array where players own choices are indicated by 1 
%   - windowSize - window size for averaging 
% OUTPUT:
%   - corrCoefValue, corrPValue - correlations and p-Values for reactionTime and isOwnChoice
%   - corrCoefAveraged, corrPValueAveraged - correlations and p-Values for 
%        reactionTime and isOwnChoice running-averaged over windowSize
% EXAMPLE of use 
%{
 %}
function [corrCoefValue, corrPValue, corrCoefAveraged, corrPValueAveraged] ...
    = calc_prob_to_see_correlation(pSee, isOwnChoice, windowSize)

isOtherChoice = 1 - isOwnChoice;

[rValue1,pValue1] = corrcoef(pSee(1,:)', isOtherChoice(1,:)');
[rValue2,pValue2] = corrcoef(pSee(2,:)', isOtherChoice(2,:)');
corrCoefValue = [rValue1(2,1), rValue2(2,1)];
corrPValue = [pValue1(2,1), pValue2(2,1)];
corrCoefValue(isnan(corrCoefValue))=0;
corrPValue(isnan(corrPValue))=0;

pSeeAveraged = movmean(pSee, windowSize, 2);
pSelectOther = movmean(isOtherChoice, windowSize, 2);
 
[rValue1,pValue1] = corrcoef(pSeeAveraged(1,:)', pSelectOther(1,:)');
[rValue2,pValue2] = corrcoef(pSeeAveraged(2,:)', pSelectOther(2,:)');
corrCoefAveraged = [rValue1(2,1), rValue2(2,1)];
corrPValueAveraged = [pValue1(2,1), pValue2(2,1)];
corrCoefAveraged(isnan(corrCoefAveraged))=0;
corrPValueAveraged(isnan(corrPValueAveraged))=0;