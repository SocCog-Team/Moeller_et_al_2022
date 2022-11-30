function [nUncoordinated, nSeamlessSwitch, nChallengeResolving, nChallengeStart, ...
          pValueUncoordinated, pValueSeamlessSwitch, pValueChallengeResolving, pValueChallengeStart] = ...
    perform_switches_test(datasetFilenames, trialsToConsider, minDRT)

nDataset = length(datasetFilenames);   
nUncoordinated = cell(1, nDataset);
nSeamlessSwitch = cell(1, nDataset);
nChallengeResolving = cell(1, nDataset);
nChallengeStart = cell(1, nDataset);

pValueUncoordinated = cell(1, nDataset);
pValueSeamlessSwitch = cell(1, nDataset);
pValueChallengeResolving = cell(1, nDataset);
pValueChallengeStart = cell(1, nDataset);
        
for iSet = 1:nDataset
    nFile = length(datasetFilenames{iSet}); 
    nUncoordinated{iSet} = zeros(nFile, 3);
    nSeamlessSwitch{iSet} = zeros(nFile, 3);
    nChallengeResolving{iSet} = zeros(nFile, 3);
    nChallengeStart{iSet}  = zeros(nFile, 3);
    
    disp(['Processing dataset' num2str(iSet)]);   
    for iFile = 1:nFile
        load(datasetFilenames{iSet}{iFile});
        nRawTrials = length(isOwnChoice);
        if (trialsToConsider(iSet) > 0)
            firstTrialIndex = max(2, nRawTrials - trialsToConsider(iSet) + 1);
        else
            firstTrialIndex = 1 - trialsToConsider(iSet);
        end 
        indexToConsider = firstTrialIndex:nRawTrials;
        
        nIndexToConsider = length(indexToConsider);
        isPrevOwnChoice = isOwnChoice(:, indexToConsider-1);
        isOwnChoice = isOwnChoice(:, indexToConsider);

        isPreceededByCorrectTrial = true(1, length(indexToConsider));
        % we currently ignore the fact that some trials can be preceeded by
        % informed-choice or aborted trials. 
        % To take this infromtation into account, uncomment the next line
        %isPreceededByCorrectTrial = ~(TrialsInCurrentSetIdx(index) - TrialsInCurrentSetIdx(index-1) - 1)';

        % we compute RT difference as average of intial fixation and target
        % acquisition times (which should correspond to the middle point of the motion)
        acquistionTimeDiff = PerTrialStruct.A_TargetAcquisitionRT - PerTrialStruct.B_TargetAcquisitionRT; 
        initFixTimeDiff = PerTrialStruct.A_InitialTargetReleaseRT - PerTrialStruct.B_InitialTargetReleaseRT;         
        reactionTimeDiff = 0.5*(initFixTimeDiff(indexToConsider) + acquistionTimeDiff(indexToConsider))';
        
        % compute number of uncoordinated trials (1st element)
        % with own-own (2d element) and other-other choices (3d element)
        uncoordTrials = isOwnChoice(1,:) == isOwnChoice(2,:);
        nUncoordinated{iSet}(iFile, 1) = sum(uncoordTrials);
        nUncoordinated{iSet}(iFile, 2) = sum(isOwnChoice(1,uncoordTrials) == 1);
        nUncoordinated{iSet}(iFile, 3) = sum(isOwnChoice(1,uncoordTrials) == 0);

        % compute number of seamless switches (1st element)
        % where faster player selecting own (2d element) or other target (3d element)
        seamlessSwitchTrials = (isOwnChoice(1,:) + isOwnChoice(2,:) == 1) & ...
                               (isPrevOwnChoice(1,:) + isPrevOwnChoice(2,:) == 1) & ...
                               (isOwnChoice(1,:) ~= isPrevOwnChoice(1,:)) & ...
                               (isPreceededByCorrectTrial);  

        nSeamlessSwitch{iSet}(iFile, 1) = sum(seamlessSwitchTrials);        

        selfishSwithTrials = (((isOwnChoice(1,seamlessSwitchTrials) == 1) & (reactionTimeDiff(seamlessSwitchTrials) < -minDRT)) |...
                              ((isOwnChoice(2,seamlessSwitchTrials) == 1) & (reactionTimeDiff(seamlessSwitchTrials) > minDRT)))  & ...
                               (isPreceededByCorrectTrial(seamlessSwitchTrials));
        benevolentSwithTrials = (((isOwnChoice(1,seamlessSwitchTrials) == 0) & (reactionTimeDiff(seamlessSwitchTrials) < -minDRT)) |...
                                 ((isOwnChoice(2,seamlessSwitchTrials) == 0) & (reactionTimeDiff(seamlessSwitchTrials) > minDRT))) & ...
                               (isPreceededByCorrectTrial(seamlessSwitchTrials));                          
        nSeamlessSwitch{iSet}(iFile, 2) = sum(selfishSwithTrials);
        nSeamlessSwitch{iSet}(iFile, 3) = sum(benevolentSwithTrials);
        
        % compute number of challenge (uncoordination) resolution
        % where faster player selecting own (2d element) or other target (3d element)        
        % !note that  nChallengeResolving{iSet}(iFile, 1) <= nUncoordinated{iSet}(iFile, 1)
        % since the former counts ALL uncoordinated trials and the latter
        % only those followed by coordinated trials
        challengeResolvedTrials = (isPrevOwnChoice(1,:) == isPrevOwnChoice(2,:)) & (isOwnChoice(1,:) ~= isOwnChoice(2,:));
        nChallengeResolving{iSet}(iFile, 1) = sum(challengeResolvedTrials);
        challengeResolvedSelfish = (((isOwnChoice(1,challengeResolvedTrials) == 1) &  ...
                                     (reactionTimeDiff(challengeResolvedTrials) < -minDRT)) |...
                                    ((isOwnChoice(2,challengeResolvedTrials) == 1) &  ...
                                     (reactionTimeDiff(challengeResolvedTrials) > minDRT)));  
        challengeResolvedBenevolent = (((isOwnChoice(1,challengeResolvedTrials) == 0) &  ...
                                        (reactionTimeDiff(challengeResolvedTrials) < -minDRT)) |...
                                       ((isOwnChoice(2,challengeResolvedTrials) == 0) &  ...
                                        (reactionTimeDiff(challengeResolvedTrials) > minDRT)));            
        nChallengeResolving{iSet}(iFile, 2) = sum(challengeResolvedSelfish);
        nChallengeResolving{iSet}(iFile, 3) = sum(challengeResolvedBenevolent);

        
        % compute number of challenge (uncoordination) initiation
        % where faster player selecting own (2d element) or other target (3d element)        
        % !note that  nChallengeStart{iSet}(iFile, 1) <= nUncoordinated{iSet}(iFile, 1)
        % since the former counts ALL uncoordinated trials and the latter
        % only those preceeded by coordinated trials.
        % However, nChallengeStart{iSet}(iFile, 1) is close to nChallengeResolving{iSet}(iFile, 1)
        % (still they may differ at most by 1)
        challengeStartTrials = (isPrevOwnChoice(1,:) ~= isPrevOwnChoice(2,:)) & (isOwnChoice(1,:) == isOwnChoice(2,:));
        nChallengeStart{iSet}(iFile, 1) = sum(challengeStartTrials);
        challengeStartSelfish = (((isOwnChoice(1,challengeStartTrials) == 1) &  ...
                                  (reactionTimeDiff(challengeStartTrials) < -minDRT)) |...
                                 ((isOwnChoice(2,challengeStartTrials) == 1) &  ...
                                  (reactionTimeDiff(challengeStartTrials) > minDRT)));  
        challengeStartBenevolent = (((isOwnChoice(1,challengeStartTrials) == 0) &  ...
                                     (reactionTimeDiff(challengeStartTrials) < -minDRT)) |...
                                    ((isOwnChoice(2,challengeStartTrials) == 0) &  ...
                                     (reactionTimeDiff(challengeStartTrials) > minDRT)));            
        nChallengeStart{iSet}(iFile, 2) = sum(challengeStartSelfish);
        nChallengeStart{iSet}(iFile, 3) = sum(challengeStartBenevolent);

        pValueUncoordinated{iSet}(iFile) = testSelfishness(nUncoordinated{iSet}(iFile, 2:3));
        pValueSeamlessSwitch{iSet}(iFile) = testSelfishness(nSeamlessSwitch{iSet}(iFile, 2:3));
        pValueChallengeResolving{iSet}(iFile) = testSelfishness(nChallengeResolving{iSet}(iFile, 2:3));
        pValueChallengeStart{iSet}(iFile) = testSelfishness(nChallengeStart{iSet}(iFile, 2:3));
                    
        % normalise all the computed quantities
        nUncoordinated{iSet}(iFile,:) = 100*nUncoordinated{iSet}(iFile,:)/nIndexToConsider;
        nSeamlessSwitch{iSet}(iFile,:) = 100*nSeamlessSwitch{iSet}(iFile,:)/nIndexToConsider;
        nChallengeResolving{iSet}(iFile,:) = 100*nChallengeResolving{iSet}(iFile,:)/nIndexToConsider;            
        nChallengeStart{iSet}(iFile,:) = 100*nChallengeStart{iSet}(iFile,:)/nIndexToConsider;                    
    end
end

end

function p = testSelfishness(n)
    nSelfish = n(1);
    nBenevolent = n(2);
    nChoicesIfEqual = floor(mean(n));
    [~,p,~] = fishertest([nSelfish, nBenevolent; nChoicesIfEqual, nChoicesIfEqual], 'Tail','right');
end

