% check_independence tests whether there is a coordination between two players 
% or if they are making choices ignoring each other 
%
% INPUT
%   - isOwnChoice - 2xN array of booleans 
%     isOwnChoice(i,j) = 1 indicated that player i at trial j selected own target;
%   - sideChoice - 2xN array of booleans 
%     sideChoice(i,j) = 1 indicated that player i at trial j selected side 1;
%
% OUTPUT:
%   - sideChoiceIndependence - pValue for independence of side choices of two players;
%   - partnerInluenceOnTarget - pValue for independence of target choices of two players;
%
%   if sideChoiceIndependence < alpha and partnerInluenceOnTarget < alpha
%   then choices of players are most likely not independent
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
 [sideChoiceIndep, targetChoiceIndep] = check_independence(isOwnChoice, sideChoice);
 % both values should be near to zero
%}
function [sideChoiceIndependence, targetChoiceIndependence] = ...
          check_independence(isOwnChoice, sideChoice)
  
  nOwnOwn = nnz(isOwnChoice(1, :) & isOwnChoice(2, :));
  nOwnOther = nnz(isOwnChoice(1, :) & (~isOwnChoice(2, :)));
  nOtherOwn = nnz((~isOwnChoice(1, :)) & isOwnChoice(2, :));
  nOtherOther = nnz((~isOwnChoice(1, :)) & (~isOwnChoice(2, :)));
  contMatrix = [nOwnOwn, nOwnOther; nOtherOwn, nOtherOther];
  [~, targetChoiceIndependence] = fishertest(contMatrix);
  
  nSide2Side2 = nnz(sideChoice(1, :) & sideChoice(2, :));
  nSide2Side1 = nnz(sideChoice(1, :) & (~sideChoice(2, :)));
  nSide1Side2 = nnz((~sideChoice(1, :)) & sideChoice(2, :));
  nSide1Side1 = nnz((~sideChoice(1, :)) & (~sideChoice(2, :)));
  contMatrix = [nSide1Side1, nSide1Side2; nSide2Side1, nSide2Side2];
  [~, sideChoiceIndependence] = fishertest(contMatrix);
end
