function [averageTotalReward, deltaTotalReward, deltaTotalSignif, deltaConfInterval] = ... 
  calc_total_average_reward(isOwnChoice, sideChoice, alpha)

totalReward = 1 + 2.5*(isOwnChoice(1,:)+isOwnChoice(2,:));
totalReward(totalReward == 6) = 2;
averageTotalReward = mean(totalReward);

%rewardP1 = 1 + isOwnChoice(1,:) + 2*(isOwnChoice(1,:) ~= isOwnChoice(2,:));
%rewardP2 = 1 + isOwnChoice(2,:) + 2*(isOwnChoice(1,:) ~= isOwnChoice(2,:));
%averagePlayerReward = [mean(rewardP1); mean(rewardP2)];
%averageTotalReward = mean(averagePlayerReward);

shareSide = mean(sideChoice,2);
shareOwn = mean(isOwnChoice,2);
shareOwnSide = mean(sideChoice&isOwnChoice,2);
chanceReward = calc_chance_reward(shareOwn,shareSide,shareOwnSide);
deltaTotalReward = averageTotalReward - chanceReward;
%[shareOwnSide(1), shareSide(1) - shareOwnSide(1); shareOwn(1) - shareOwnSide(1), 1 - shareSide(1) + shareOwnSide(1) - shareOwn(1)]
%[shareOwnSide(2), shareSide(2) - shareOwnSide(2); shareOwn(2) - shareOwnSide(2), 1 - shareSide(2) + shareOwnSide(2) - shareOwn(2)]

%compute significance for non-random reward for given alpha
n = length(isOwnChoice);
if (~exist('alpha', 'var'))
  alpha = 0.05;
end
zScore = norminv((1-alpha/2));

%compute confidence intervals for non-random reward
dltShare = zScore*sqrt(shareSide.*(1-shareSide)./n);
shareSideInt = [shareSide(1) - dltShare(1), shareSide(1) - dltShare(1), ... 
                shareSide(1) + dltShare(1), shareSide(1) + dltShare(1); ...
                shareSide(2) - dltShare(2), shareSide(2) + dltShare(2), ... 
                shareSide(2) - dltShare(2), shareSide(2) + dltShare(2)];
shareSideInt(shareSideInt>1) = 1;
shareSideInt(shareSideInt<0) = 0;

dltShare = zScore*sqrt(shareOwn.*(1-shareOwn)./n);              
shareOwnInt = [shareOwn(1) - dltShare(1), shareOwn(1) - dltShare(1), ... 
               shareOwn(1) + dltShare(1), shareOwn(1) + dltShare(1); ...
               shareOwn(2) - dltShare(2), shareOwn(2) + dltShare(2), ... 
               shareOwn(2) - dltShare(2), shareOwn(2) + dltShare(2)];
shareOwnInt(shareOwnInt>1) = 1;
shareOwnInt(shareOwnInt<0) = 0;

%shareOwnSideInt(shareOwnSideInt<0) = 0;

maxChanceReward = chanceReward;
minChanceReward = chanceReward;
for iOwn = 1:4
  for iSide = 1:4
    shareOwnSideCurr = shareOwnSide + ...
      0.5*(shareOwnInt(:,iOwn) + shareSideInt(:,iSide) - shareOwn - shareSide);
    currChanceReward = calc_chance_reward(shareOwnInt(:,iOwn), ...
                           shareSideInt(:,iSide), shareOwnSideCurr);  
    if (maxChanceReward < currChanceReward);
      maxChanceReward = currChanceReward;
    end  
    if (minChanceReward > currChanceReward);
      minChanceReward = currChanceReward;
    end 
    if (minChanceReward < 1)
      minChanceReward = 1;
      warning('wrong chance reward!')
    end 
    if (maxChanceReward > 3.5)
      maxChanceReward = 3.5;
      warning('wrong chance reward!')
    end      
  end
end  

deltaTotalSignif = (averageTotalReward < minChanceReward) | (averageTotalReward > maxChanceReward);
deltaConfInterval = averageTotalReward - [maxChanceReward; minChanceReward];
%maxChanceReward - minChanceReward             
%disp('************************')
end

function chanceReward = calc_chance_reward(shareOwn,shareSide,shareOwnSide)
  % compute frequency for each of two possible target locations
  shareLocationType = shareOwnSide + (1-shareSide - shareOwn + shareOwnSide);
  
  % compute chance reward obtained for each of two locations                  
  chanceRewardSide = 2.5*(shareOwnSide.*flip(shareSide-shareOwnSide) + ...
                      (1 - shareSide - shareOwn + shareOwnSide).*flip(shareOwn-shareOwnSide)) + ...
                 shareOwnSide.*flip(shareOwn - shareOwnSide);

  chanceReward = sum(chanceRewardSide./shareLocationType) + 1;               
end  


  
%{

shareOwn = [0.6, 0.6];
shareSide = [0.8 0.8];
shareOwnSide = [0.45 0.45];

chanceReward = 4*( shareOwnSide.*flip(2*shareSide+shareOwn-3*shareOwnSide) + ... 
                    (shareOwn - shareOwnSide).*flip(2 - 2*shareSide - 2*shareOwn + 3*shareOwnSide)) + ...
                 2*((shareSide - shareOwnSide).*flip(1 - shareSide - shareOwn + 4*shareOwnSide) + ...
                    (1 - shareSide - shareOwn + shareOwnSide).*flip(shareSide + 3*shareOwn - 4*shareOwnSide))
%}