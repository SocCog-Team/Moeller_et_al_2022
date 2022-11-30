function mutualInf = calc_local_mutual_information(x, y, windowSize)
% calc_local_mutual_information computes local mutual information (LMI).
% Given integer-valued signals x and y, LMI(x, y) characterizes mutual dependence 
% between x and y (the "amount of information" obtained about one signal, 
% through the other signal)
%
% INPUT
%   - x, y - 1xN arrays of positive integers   
% OPTIONAL INPUT
%   - windowSize - length of the sliding window used for estimating probabilities of 
%     x and y; by default windowSize = 5*cardX*cardY is used, since this length 
%     provides reliable estimation of probabilities
%
% OUTPUT:
%   mutualInf - values of local transfer entropy. 
%   - values mutualInf(1:windowSize) are computed for probabilities of
%     x and y values calculated in x(1:windowSize) and y(1:windowSize); 
%   - values transferEntropy(i) for i > order+windowSize are computed for 
%     probabilities calculated in x(i-windowSize:i), y(i-order+windowSize:i); 
%
%
% EXAMPLE of use 
%{
  N = 200;
  x = randi(2, 1, N) - 1;
  y = xor(x, [randi(2, 1, N/2) - 1, ones(1, N/2)]);
  mutualInf = calc_local_mutual_information(x, y, 50);
  plot(mutualInf)
  % before 100 mutualInf near zero, after 100 mutualInf increases to 1
%}

  % x, y - sequences of integer numbers starting from 1 
  x = x - min(x) + 1; %make numbers in x start from 1 if it was not so
  y = y - min(y) + 1; %make numbers in x start from 1 if it was not so
  cardX = max(x); %compute size of alphabet
  cardY = max(y); %compute size of alphabet
  
  lengthX = length(x); 
  if (~exist('windowSize', 'var'))
    windowSize = 5*cardX*cardY;
  end
  if (windowSize > lengthX)
    windowSize = lengthX;
  end
  
  % initialize distributions allowing for finite sample size  
  nX = (1/cardX)*ones(cardX, 1);
  nY = (1/cardY)*ones(1, cardY);
  nXY = (1/(cardX*cardY))*ones(cardX, cardY);
    
  mutualInf = zeros(1, lengthX);
  for i = 1:lengthX  
    % add new symbols to the probability distribution
    nX(x(i)) = nX(x(i)) + 1;
    nY(y(i)) = nY(y(i)) + 1;
    nXY(x(i), y(i)) = nXY(x(i), y(i)) + 1;       
    
    if (i >= windowSize) % recompute distribution of x and y in current window
      pX = nX/(windowSize + 1);
      pY = nY/(windowSize + 1);
      pXY = nXY/(windowSize + 1);
      
      % compute MI
      if (i == windowSize) % compute MI for first samples
        for j = 1:i-1
          mutualInf(j) = log2(pXY(x(j), y(j))/(pX(x(j))*pY(y(j))));
        end  
      end              
      mutualInf(i) = log2(pXY(x(i), y(i))/(pX(x(i))*pY(y(i)))); 
      
      % remove last symbols from the probability distribution
      j = i - windowSize + 1;
      nX(x(j)) = nX(x(j)) - 1;
      nY(y(j)) = nY(y(j)) - 1;
      nXY(x(j), y(j)) = nXY(x(j), y(j)) - 1;   
    end
  end  
end
