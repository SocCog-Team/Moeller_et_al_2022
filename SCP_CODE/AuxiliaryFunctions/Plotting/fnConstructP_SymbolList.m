function [ symbol_list, p_list, cols_idx_per_symbol] = fnConstructP_SymbolList( fisherexact_pairwaise_P_matrix, row_names, col_names, group_by_dim, match_suffix )
%CONSTRUCT_SYMBOL_LIST Summary of this function goes here
%   Detailed explanation goes here
% NOTE: if match suffix is chance and there is only one chance name pick
% prob diff from chance
% cols_idx_per_symbol: this contains the column indices for each reported significant pair
% this generates the full match table of msatc_suffix is identical to eval([group_by_dim, '_names'])) 
%TODO: 
%		allow to pass upper_bounds and sorted_symbol_list
%       remove tests with all zero columns


p_class_upper_bounds_list = [0.05, 0.01, 0.005];
sorted_symbol_list = {'*', '**', '***'};

% make sure this is a cell so we can iterate simpler
if ~iscell(match_suffix)
	match_suffix = {match_suffix};
end	
n_match_suffixes = length(match_suffix);

if isequal(match_suffix, eval([group_by_dim, '_names']))
	match_all = 1;
else
	match_all = 0;
end

data_group_names = eval([group_by_dim, '_names']);
p_list = cell([size(data_group_names, 1), size(data_group_names, 2) * n_match_suffixes]);
symbol_list = cell([size(data_group_names, 1), size(data_group_names, 2) * n_match_suffixes]);
cols_idx_per_symbol = zeros([2, size(data_group_names, 2) * n_match_suffixes]);

% for each name find whether there is a match
FoundChanceCol = 0;
for i_group = 1 : length(data_group_names)
	cur_group_name = data_group_names{i_group};
	
	for i_match_suffix = 1 : length(match_suffix)
		cur_out_col_idx = (i_group - 1) * n_match_suffixes + i_match_suffix;
		cur_match_suffix = match_suffix{i_match_suffix};
		%cur_matched_group_name = [cur_group_name, match_suffix];
		cur_matched_group_name = construct_match_name(cur_group_name, cur_match_suffix, data_group_names, match_all);
		
		cur_matched_idx = find(strcmp(data_group_names, cur_matched_group_name));
		%p_list{cur_out_col_idx} = '';
		if ~isempty(cur_matched_idx)
			p_list{cur_out_col_idx} = fisherexact_pairwaise_P_matrix(i_group, cur_matched_idx);
			cols_idx_per_symbol(:, cur_out_col_idx) = [i_group; cur_matched_idx];
		end
		
		symbol_list{cur_out_col_idx} = '';
		if strcmp(cur_match_suffix, 'chance') && (strcmp('chance', data_group_names(end)) == 1)
			FoundChanceCol = 1;
			chance_idx = length(data_group_names);	% if there each group was tested against chance this will br in the last field...
			p_list{cur_out_col_idx} = fisherexact_pairwaise_P_matrix(i_group, chance_idx);
		end
	end
end

% now map the extracted probabilities to symbols
for i_out_cols = 1 : length(p_list)
	cur_p = p_list{i_out_cols};
	if ~isempty(cur_p)
		cur_p_class = max(find(p_class_upper_bounds_list >= cur_p));
		if ~isempty(cur_p_class);
			symbol_list{i_out_cols} = sorted_symbol_list{cur_p_class};
		else
			symbol_list{i_out_cols} = '';
		end
	end
end


% we naively created a set with directionality, where 1->2 is included as
% well as 2->1 so prune this down again
if(match_all)
	NumNames = length(data_group_names);
	UniqueColumnCombinationsIdx = zeros(size(p_list));
	ColumnCounter = 0;
	for iNames = 1 : NumNames
		for iReminder = 1 : NumNames
			ColumnCounter = ColumnCounter + 1;
			if (iReminder >= iNames)
				UniqueColumnCombinationsIdx(ColumnCounter) = 1;
			end
		end
	end
	UniqueColumnCombinationsIdx = find(UniqueColumnCombinationsIdx);
	symbol_list = symbol_list(UniqueColumnCombinationsIdx);
	p_list = p_list(UniqueColumnCombinationsIdx);
	cols_idx_per_symbol = cols_idx_per_symbol(:, UniqueColumnCombinationsIdx);
end


% clear not assigned output columns...
valid_col_idx = find(cols_idx_per_symbol(1, :) ~= 0);
if ~isempty(valid_col_idx) && (FoundChanceCol)
	valid_col_idx(end + 1) = valid_col_idx(end)+1;	% but leave a faked chance column...
else
% 	disp('Doh...');
end

tmp_idx = zeros(size(valid_col_idx));
for iCell = 1: length(p_list)
	if p_list{iCell} <= p_class_upper_bounds_list(1)
		tmp_idx(iCell) = 1;
	end
end
valid_col_idx = intersect(valid_col_idx, find(tmp_idx));

symbol_list = symbol_list(valid_col_idx);
p_list = p_list(valid_col_idx);
cols_idx_per_symbol = cols_idx_per_symbol(:, valid_col_idx);


return
end

function [	cur_matched_group_name, cur_matched_group_idx ] = construct_match_name( cur_group_name, match_fragment, data_group_names, match_all )
% try to find the matching group, that just differs by including
% match_fragment somewhere in the name

cur_matched_group_name = '';

% the match needs to be of length length(cur_group_name) + length(match_fragment)
% match_length = length(cur_group_name) + length(match_fragment);
if ~(match_all)
	cur_match_fingerprint = sort([cur_group_name, match_fragment]);
else
	cur_match_fingerprint = sort(match_fragment);
end
% alternatively excise the match_fragment from all data_group_names it is
% found in...
group_fingerprint_list = cell(size(data_group_names));
for i_group = 1 : length(data_group_names)
	group_fingerprint_list{i_group} = sort(data_group_names{i_group});
end

cur_matched_group_idx = find(strcmp(group_fingerprint_list, cur_match_fingerprint));
if ~isempty(cur_matched_group_idx)
	if length(cur_matched_group_idx) == 1
		cur_matched_group_name = data_group_names{cur_matched_group_idx};
	else
		error('match heuistic too weak, implement excision algorithm...');
	end
end

return
end