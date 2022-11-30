function [miValue, isSignificant, significanceThreshold] = calc_whole_mutual_information(x, y, pCritValue)
% calc_local_mutual_information computes  mutual information (MI).
% Given integer-valued signals x and y, MI(x, y) characterizes mutual dependence 
% between x and y (the "amount of information" obtained about one signal, 
% through the other signal)
%
% USES: Whittle Surrogate, 
%     https://de.mathworks.com/matlabcentral/fileexchange/40188-whittle-surrogate 
%
% INPUT
%   - x, y - 1xN arrays of positive integers   
% OPTIONAL INPUT
%   - pCritValue - significance level of MI. 
%     If unspecified or 0, significance is not tested.
%
% OUTPUT:
%   - mutualInf - value of mutual information in the time series. 
%   - isSignificant = 1 if MI is significant, = 0 if MI is not significan, 
%   - significanceThreshold - the minimal value MI should take to be significant
% EXAMPLE of use 
%{
  N = 200;
  x = randi(2, 1, N) - 1;
  y = xor(x, [randi(2, 1, N/2) - 1, ones(1, N/2)]);
  mutualInf = calc_local_mutual_information(x, y, 0.05);
  plot(mutualInf)
  % before 100 mutualInf near zero, after 100 mutualInf increases to 1
%}  

  % x, y - sequences of integer numbers starting from 1 
  x = x - min(x) + 1; %make numbers in x start from 1 if it was not so
  y = y - min(y) + 1; %make numbers in x start from 1 if it was not so

  miValue = calcMIvalue(x, y);
  
  % initialize output values
  isSignificant = 0;
  significanceThreshold = 0;
  if (exist('pCritValue', 'var') && (pCritValue > 0) && (pCritValue <= 1) && ...
     (length(unique(x)) > 1) && (length(unique(y)) > 1)) && numel(x) > 2
    % for constant values, mi is insignificant anyway)
    nSurrogate = floor(1/pCritValue);
    miSurrogate = zeros(1, nSurrogate);
%{    
    maxProbOrder = 4;
    probOrderX = MarkovOrderTests(x, 100, maxProbOrder); 
    [~, orderX] = max(probOrderX);
    orderX = orderX - 1;
    probOrderY = MarkovOrderTests(y, 100, maxProbOrder);
    [~, orderY] = max(probOrderY);    
    orderY = orderY - 1;    
%}
    orderX = 1;
    orderY = 1;
    [fx, wx, ux, vx] = trans_count(x, orderX);
    [fy, wy, uy, vy] = trans_count(y, orderY); 
    for i = 1:nSurrogate
      xSurr = whittle_surrogate(fx, wx, ux, vx);
      ySurr = whittle_surrogate(fy, wy, uy, vy);
      miSurrogate(i) = calcMIvalue(xSurr, ySurr);
    end  
    significanceThreshold = max(miSurrogate);
    if (miValue >= significanceThreshold)
      isSignificant = 1;
    end  
  end 
end

function mi = calcMIvalue(x, y) 
  lengthX = length(x); 
  cardX = max(x); %compute size of alphabet
  cardY = max(y); %compute size of alphabet
  % initialize distributions allowing for finite sample size  
  nX = (1/cardX)*ones(cardX, 1);
  nY = (1/cardY)*ones(1, cardY);
  nXY = (1/(cardX*cardY))*ones(cardX, cardY);
  for i = 1:lengthX  
    % add new symbols to the probability distribution
    nX(x(i)) = nX(x(i)) + 1;
    nY(y(i)) = nY(y(i)) + 1;
    nXY(x(i), y(i)) = nXY(x(i), y(i)) + 1;       
  end  
  pX = nX/(lengthX + 1);
  pY = nY/(lengthX + 1);
  pXY = nXY/(lengthX + 1);
  mi = sum(sum(pXY.*log2(pXY))) - sum(pX.*log2(pX)) - sum(pY.*log2(pY));
end