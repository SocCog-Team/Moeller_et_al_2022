function transferEntropy = calc_transfer_entropy(x, y, order, windowSize)
% calc_transfer_entropy computes  transfer entropy (TE).
% Given integer-valued signals x and y, TE(x, y) characterizes average causal
% influence of y on x (strictly speaking: the amount of uncertainty reduced 
% in values of x by knowing the past values of y given past values of x.)
%
% INPUT
%   - x - 1xN array of positive integers representing the effect (resulting signal);   
%   - y - 1xN array of positive integers representing the cause;   
%   - order - number of points in the past taken into account.
% OPTIONAL INPUT
%   - windowSize - length of the sliding window used for estimating probabilities of 
%     x and y; by default windowSize = 5*cardX^(order+1)*cardY^(order) is
%     used, since this length provides reliable estimation of probabilities
%
% OUTPUT:
%   transferEntropy - values of local transfer entropy. 
%   - values transferEntropy(order:order+windowSize) are computed for probabilities 
%     calculated for x(1:order+windowSize) and y(1:order+windowSize); 
%   - values transferEntropy(i) for i > order+windowSize are computed for 
%     probabilities calculated in x(i-order-windowSize:i), y(i-order-windowSize:i); 
%
%
% EXAMPLE of use 
%{
 x = [ones(1, 40), zeros(1, 40), ones(1, 40), zeros(1, 40)];
 y = [0 x(1:end-1)];
 TE = calc_transfer_entropy(y, x, 1, 30);
 plot(TE);
 % result: signal with clear peaks at 41,81 and 121
%}
  x = x - min(x) + 1; %make numbers in x start from 1 if it was not so
  y = y - min(y) + 1; %make numbers in x start from 1 if it was not so
  cardX = max(x); %compute size of alphabet
  cardY = max(y); %compute size of alphabet
  
  lengthX = length(x);
  if (~exist('windowSize', 'var'))
    windowSize = 5*cardX^(order+1)*cardY^(order+1);
  end
  if (windowSize > lengthX - order)
    windowSize = lengthX - order;
  end
  
  % initialize distributions allowing for finite sample size
  nAllX = zeros(cardX, cardX^order); %joint distribution of current and previous x
  nPrevX = zeros(1, cardX^order); %distribution of previous x
  nAllXY = zeros(cardX, (cardY^order)*(cardX^order)); %joint distribution of current and previous x and previous y
  nPrevXY = zeros(1, (cardY^order)*(cardX^order)); %joint distribution of previous x and y
  
  allPrevXstr = zeros(1, lengthX);
  allPrevYstr = zeros(1, lengthX);
  allPrevXYstr = zeros(1, lengthX);   
  transferEntropy = zeros(1, lengthX);
  
  lastXstr = sum((x(1:order) - 1).*(cardX.^(0:order-1)));
  lastYstr = sum((y(1:order) - 1).*(cardY.^(0:order-1)));
  lastXYstr = lastXstr + lastYstr*(cardX^order);
  
  %denomAllXY = numel(nAllXY) + windowSize;
  %denomAllX = numel(nAllX) + windowSize;
  for i = order+1:lengthX
    % add new symbols to the probability distribution
    allPrevXstr(i) = lastXstr + 1;
    allPrevYstr(i) = lastYstr + 1;
    allPrevXYstr(i) = lastXYstr + 1;    
    nAllX(x(i), allPrevXstr(i)) = nAllX(x(i), allPrevXstr(i)) + 1;
    nPrevX(allPrevXstr(i)) = nPrevX(allPrevXstr(i)) + 1;
    nAllXY(x(i), allPrevXYstr(i)) = nAllXY(x(i), allPrevXYstr(i)) + 1;
    nPrevXY(allPrevXYstr(i)) = nPrevXY(allPrevXYstr(i)) + 1;    
    
    lastXstr = floor(lastXstr/cardX) + (x(i) - 1)*cardX^(order - 1);    
    lastYstr = floor(lastYstr/cardY) + (y(i) - 1)*cardY^(order - 1);    
    lastXYstr = lastXstr + lastYstr*(cardX^order);
    
    if (i >= order+windowSize) %recompute nX each time
      condProbX = bsxfun(@rdivide, nAllX, nPrevX);
      condProbXY = bsxfun(@rdivide, nAllXY, nPrevXY);
 
      transferEntropy(i) = condEntropy(nAllXY./windowSize, condProbXY) - ...
                           condEntropy(nAllX./windowSize, condProbX);
      
      % remove last symbols from the probability distribution      
      j = i - windowSize + 1;      
      nAllX(x(j), allPrevXstr(j)) = nAllX(x(j), allPrevXstr(j)) - 1;
      nPrevX(allPrevXstr(j)) = nPrevX(allPrevXstr(j)) - 1;
      nAllXY(x(j), allPrevXYstr(j)) = nAllXY(x(j), allPrevXYstr(j)) - 1;
      nPrevXY(allPrevXYstr(j)) = nPrevXY(allPrevXYstr(j)) - 1;    
    end
  end  
  transferEntropy(1:order+windowSize) = transferEntropy(order+windowSize);
end

function value = condEntropy(probDistrFull, probDistrCond)
  value = nansum(nansum(probDistrFull.*log2(probDistrCond)));
end  

%function value = entropyValue(p)
%  value = -sum(sum(p.*log2(p)));
%end  