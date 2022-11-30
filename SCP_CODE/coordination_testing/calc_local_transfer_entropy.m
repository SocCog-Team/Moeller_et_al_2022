function transferEntropy = calc_local_transfer_entropy(x, y, order, windowSize)
% calc_local_transfer_entropy computes local transfer entropy (LTE).
% Given integer-valued signals x and y, LTE(x, y) characterizes causal
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
 localTE = calc_local_transfer_entropy(y, x, 1, 30);
 plot(localTE);
 % result: signal with clear peaks at 42,82 and 122
%}
  x = x - min(x) + 1; %make numbers in x start from 1 if it was not so
  y = y - min(y) + 1; %make numbers in x start from 1 if it was not so
  cardX = max(x); %compute size of alphabet
  cardY = max(y); %compute size of alphabet
  
  lengthX = length(x);
  if (~exist('windowSize', 'var'))
    windowSize = 5*cardX^(order+1)*cardY^(order);
  end
  if (windowSize > lengthX - order)
    windowSize = lengthX - order;
  end
  
  % initialize distributions allowing for finite sample size
  nAllX = (1/cardX)*ones(cardX, cardX^order);
  nPrevX = ones(1, cardX^order);
  nAllXY = (1/cardX)*ones(cardX, (cardY^order)*(cardX^order));
  nPrevXY = ones(1, (cardY^order)*(cardX^order));
  
  allPrevXstr = zeros(1, lengthX);
  allPrevYstr = zeros(1, lengthX);
  allPrevXYstr = zeros(1, lengthX);   
  transferEntropy = zeros(1, lengthX);
  
  lastXstr = sum((x(1:order) - 1).*(cardX.^(0:order-1)));
  lastYstr = sum((y(1:order) - 1).*(cardY.^(0:order-1)));
  lastXYstr = lastXstr + lastYstr*(cardX^order);
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
      if (i == order+windowSize) %compute surprise for first samples
        for j = order+1:i-1
          transferEntropy(j) = -log2(condProbX(x(j), allPrevXstr(j)) ... 
                                    /condProbXY(x(j), allPrevXYstr(j)));
        end  
      end  
      % remove last symbols from the probability distribution      
      j = i - windowSize + 1;      
      nAllX(x(j), allPrevXstr(j)) = nAllX(x(j), allPrevXstr(j)) - 1;
      nPrevX(allPrevXstr(j)) = nPrevX(allPrevXstr(j)) - 1;
      nAllXY(x(j), allPrevXYstr(j)) = nAllXY(x(j), allPrevXYstr(j)) - 1;
      nPrevXY(allPrevXYstr(j)) = nPrevXY(allPrevXYstr(j)) - 1;    
      
      transferEntropy(i) = -log2(condProbX(x(i), allPrevXstr(i)) ... 
                                    /condProbXY(x(i), allPrevXYstr(i)));
    end
  end  
end
