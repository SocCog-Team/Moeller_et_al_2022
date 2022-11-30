function [strategy, shortStrategy, nStateVisit, shortStateVisit] = estimate_strategy(target, side, RT, minDRT)
nRow = 4;      % previous location x current location
nColBasic = 4; % previous own choice x previous partner choce
if (~exist('RT', 'var'))
    nCol = nColBasic;
    RT = zeros(size(target));
else
    nCol = 3*nColBasic; % 3 possible partner choices: invisible, own, other
end
if (~exist('minDRT', 'var'))
    minDRT = 0;
end
nTrial = length(target);
nStateVisit = cell(2, 1);
nStateChoices = cell(2, 1);
for iPlayer = 1:2
    nStateVisit{iPlayer} = zeros(nRow, nCol);
    nStateChoices{iPlayer} = zeros(nRow, nCol);
end
shortStrategy = zeros(2, nCol);
shortStateVisit = zeros(2, nCol);

% for each trial starting from 2nd compute row and column indices
% describing the corresponding entry in strategy matrix
[rowIndex, colIndex] = compute_strategy_entries(target, side, RT, minDRT);

if isempty(rowIndex) && isempty(colIndex)
   disp('Could not compute staretgy entries, too few trials in selected subset?');
   strategy = [];
   return
end

% compute number of visits in each entry of a strategy and probability to
% select own in each entry (the strategy)
for iTrial = 2:nTrial
    iRow = rowIndex(iTrial-1);
    for iPlayer = 1:2
        iCol = colIndex(iPlayer, iTrial-1);
        nStateVisit{iPlayer}(iRow, iCol) = nStateVisit{iPlayer}(iRow, iCol) + 1;
        nStateChoices{iPlayer}(iRow, iCol) = nStateChoices{iPlayer}(iRow, iCol) + target(iPlayer, iTrial);
    end
end
strategy = cellfun(@rdivide, nStateChoices, nStateVisit, 'UniformOutput', false);

shortStrategy(1,:) = sum(nStateChoices{1}, 1)./sum(nStateVisit{1}, 1);
shortStrategy(2,:) = sum(nStateChoices{2}, 1)./sum(nStateVisit{2}, 1);
shortStateVisit(1,:) = sum(nStateVisit{1}, 1);
shortStateVisit(2,:) = sum(nStateVisit{2}, 1);
end