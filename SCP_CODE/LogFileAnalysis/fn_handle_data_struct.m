function [ data_struct ] = fn_handle_data_struct( command_str, varargin )
%HANDLE_DATA_STRUCT handle tabularized data
%	This function handeles relation database inspired data collections
%	These always have a field header that describes each column in the
%	numeric data table, the numeric data table called data, and a
%	collection of lists, for each column name that ends in _idx, pure lists
%	are simple cell arrays of the values in the according field,
%	unique_lists give the value_string for each index number used in _idx
%	columns
%
%   create: actually use a defined cell array of columns names to generate
%   the basic structure.
%
%	add_columns: take a full vector/array/cell_list/cell array and a cell list of 
%		column names and add them to the given struct, this should work with 
%		the putput of text scan?
%		current version will only take numeric vectors/array
%
%	add_row: add a new data entry, this will ping-pong the actual
%		data_structer between fn_handle_data_struct and the caller, so only
%		use if adding single/few lines
%
%	add_row_2_global_struct: same as add_row, but instead of copying the
%		data structure around all the time use a global variable to avoid data
%		copies, which get more expensive the larger that data array already
%		is...
% TODO:
%	Implement batch-wise array growth with explicit truncation to size with
%	new command, pass the batch size hint as command line argument
%	add sorted index builder
%	ADD merge function (create option to allow partial match merges, by filling up missing fields with out of bounds markers)

switch command_str
	case 'create'
		if nargin > 3
			error('The create command only requires the column name cell and nothing else.');
		end
		if (length(varargin) == 1)
			varargin{end+1} = 1;
		end
		data_struct = local_create_structure(varargin{1}, varargin{2});
		
	case 'add_row'
		if (nargin > 4)
			error('The add_row command requires three arguments: the command name add_row a data_struct and the row_data to add');
		end
		if (length(varargin) == 2)
			varargin{end+1} = 1;
		end
		
		data_struct = local_add_data_row(varargin{1}, varargin{2}, varargin{3});

	case 'add_columns'
		if (nargin > 4)
			error('The add_row command requires four arguments: the command name add_columns a data_struct and the row_data and the column name to add');
		end
		%if (length(varargin) == 2)
		%	varargin{end+1} = 1;
		%end
		
		data_struct = local_add_data_columns(varargin{1}, varargin{2}, varargin{3});
        
   case 'remove_columns'
		if (nargin > 4)
			error('The add_row command requires three arguments: the command name remove_columns a data_struct and the column names to remove');
		end
		%if (length(varargin) == 2)
		%	varargin{end+1} = 1;
		%end
		
		data_struct = local_remove_data_columns(varargin{1}, varargin{2});

		
	case 'add_row_to_global_struct'
		if (length(varargin) == 1)
			varargin{end+1} = 1;
		end

		if ~(nargin == 3)
			error('The add_row command requires two arguments: the command name add_row and the row_data to add.');
		end
		local_add_data_row_to_global_struct(varargin{1}, varargin{2});
	
	case 'truncate_to_actual_size'	
		if nargin > 2
			error('The truncate_data_to_actual_size command only requires two arguments: the command name truncate_data_to_actual_size and the data_struct.');
		end
		data_struct = local_truncate_to_actual_size(varargin{1});
	otherwise
		error(['Encountered unhandled command: ', command_str, ' halting...']);
end

return
end



function [ data_struct ] = local_create_structure( header_list, batch_size )
% create a cannonical table
if ~(exist('batch_size', 'var'))
	batch_size = 1;
end


data_struct.header = header_list;
data_struct.data = zeros([batch_size length(header_list)]);

data_struct.unique_lists = struct();    % make sure the 'canonical' data_struct filds are always in the same sequence

for i_col = 1 : length(header_list)
	% create lists for column names ending in _idx
	cur_col_name = header_list{i_col};
	if (length(cur_col_name) > 3) && strcmp('_idx', cur_col_name(end-3:end))
		cur_col_list_name = cur_col_name(1:end-4);
		%data_struct.lists.(cur_col_list_name) = {};
		data_struct.unique_lists.(cur_col_list_name) = {};
	end
end
% were does the data end
data_struct.first_empty_row_idx = 1;
data_struct.out_of_bounds_marker = NaN; % which value to use to mark missing values (use zeros for indexed _idx columns)
% a structure that allows to use names for the column indices
data_struct.cn = local_get_column_name_indices(header_list);
return
end


function [ data_struct ] = local_remove_data_columns( data_struct, column_name_list )
% find all named columns and remove them from the data table, the header
% and potentially from unique_lists
CurrentHeader = data_struct.header;
rmcol_idx = [];
for i_rmcol_candidate = 1 : length(column_name_list)
    CurrentColumnName = column_name_list{i_rmcol_candidate};
    if isfield(data_struct.cn, CurrentColumnName)
        rmcol_idx = [rmcol_idx, data_struct.cn.(CurrentColumnName)];
        if (strcmp(column_name_list{i_rmcol_candidate}(end-3:end), '_idx'))
            if (isfield(data_struct.unique_lists.(column_name_list{i_rmcol_candidate}(1:end-4))))
                data_struct.unique_lists.(column_name_list{i_rmcol_candidate}(1:end-4)) = [];
            end
        end
    else
        disp(['Could not find a column named ', CurrentColumnName, ' in the current data_struct; nothing to remove...']);
    end
end    
if ~isempty(rmcol_idx)
   data_struct.data(:, rmcol_idx) = [];
   data_struct.header(:, rmcol_idx) = [];
end    

% finally fix the column name struct cn
data_struct.cn = local_get_column_name_indices(data_struct.header);
return
end

function [ data_struct ] = local_add_data_columns( data_struct, new_column_data, column_name_list )
% check sizes
[n_rows, n_new_columns] = size(new_column_data);

% allow column addition to empty tables (by expanding the table to contain as many rows as the new column(s) carry)
if ((n_rows ~= size(data_struct.data, 1)) && (data_struct.first_empty_row_idx == 1))
    % the data table is effectively empty, so grow to the correct number of
    % rows
    data_struct.data = zeros([n_rows, length(data_struct.header)]);
    data_struct.first_empty_row_idx = data_struct.first_empty_row_idx + n_rows;
end


% wrong number of rows
if (n_rows ~= size(data_struct.data, 1))
	error(['Failed adding ', num2str(n_rows), ' rows to a data table of ', num2str(size(data_struct.data, 1)), ' rows; these numbers should match, so bailing out...']);
	return
end

% too few column names
if (length(column_name_list) ~= n_new_columns)
	error(['Only found ', num2str(length(column_name_list)), ' column names for ', num2str(n_new_columns), ' columns, bailing out...']);
	return
end

% column names already exist?
ColumnNamesAlreadyExistingIdx = find(ismember(data_struct.header, column_name_list));
if ~isempty(ColumnNamesAlreadyExistingIdx)
	for iExistingColumn = 1 : length(ColumnNamesAlreadyExistingIdx)
		disp(['Name of to be added column (', data_struct.header{ColumnNamesAlreadyExistingIdx(iExistingColumn)}, ') already exists.']);
	end
	error('Bailing out...');
	return
end

% for the time being only handle numeric columns
if isnumeric(new_column_data)  
    % okay we passed all tests, now just concatenate the new column(s)
    data_struct.data = [data_struct.data, new_column_data];
    % also add the column names to the header
    data_struct.header = [data_struct.header, column_name_list];    
elseif iscell(new_column_data)
    if (n_new_columns > 1)
        error('We currently only allow addition of single cell columns, bailing out...');
    end    
    if strcmp(column_name_list{1}(end-3:end), '_idx')
        data_struct.header = [data_struct.header, column_name_list];
        
        if (n_rows > 0) && (isstr(new_column_data{1,1}))
            % turn this into an indexed column, also add to data_struct. unique
            [UniqueValueList, ~, indexed_new_column_data] = unique(new_column_data);
            data_struct.unique_lists.(column_name_list{1}(1:end-4)) = UniqueValueList';
            
            % empty names should result in a zero index
            EmptyValueStringIdx = find(strcmp(UniqueValueList, ''));
            if ~isempty(EmptyValueStringIdx)
                EmptyRowIdx = find(indexed_new_column_data == EmptyValueStringIdx);
                indexed_new_column_data(EmptyRowIdx) = 0;
            end
            data_struct.data = [data_struct.data, indexed_new_column_data];
        else
            if (n_rows == 0) & (n_new_columns == 1)
                % this is an empty field in an indexed column, set to zero
                % to denote impossible index in UniqueValueList
                disp([mfilename, ': local_add_data_columns: empty indexed column ', column_name_list{1}]);
                data_struct.data = [data_struct.data, 0];
                data_struct.unique_lists.(column_name_list{1}(1:end-4)) = {};
            end
        end
    end
else
    error(['We currently only allow addition of numeric columns, bailing out...']);
    return
end

% finally fix the column name struct cn
data_struct.cn = local_get_column_name_indices(data_struct.header);

return
end

function [ data_struct ] = local_add_data_row( data_struct, new_row_data, batch_size )

if ~(exist('batch_size', 'var'))
	batch_size = 1;
end
% is new_row_data numeric? then just try to add it
if isnumeric(new_row_data)
	if (size(new_row_data, 2) == length(data_struct.header))
		data_struct.data(data_struct.first_empty_row_idx, :) = new_row_data;
	else
		error(['Failed adding a row of ', num2str(size(new_row_data, 2)), ' columns to a table', num2str(length(data_struct.header)), ' columns wide.']);
	end
end

% alternatively interpret the input as a cell_list and loop through the
% members...
if iscell(new_row_data)
	cur_col_idx = 1;
	n_cells = length(new_row_data);
	for i_cell = 1 : n_cells
		cur_data = new_row_data{i_cell};
		% accept numeric vectors and add them at the current col_idx
		if isnumeric(cur_data)
			n_cols_in_cur_cell = size(cur_data, 2);
			data_struct.data(data_struct.first_empty_row_idx, cur_col_idx : cur_col_idx + n_cols_in_cur_cell - 1) = cur_data;
		end
				
		% accept strings for _idx columns
		if ischar(cur_data)
			cur_col_name = data_struct.header{cur_col_idx};
			if isempty(cur_data)
				% this catches potentially empty arras which eventIDE
				% exports as ; ; and we import as empty string (''), once
				% the strings are parsed that will need disentangling...
				disp(['Found empty column data for ', cur_col_name, ', replacing by EMPTY']);
				cur_data = 'EMPTY';
			end
			
			if (length(cur_col_name) > 3) && strcmp('_idx', cur_col_name(end-3:end))
				n_cols_in_cur_cell = size(cur_data, 1);
				[numeric_idx_value, data_struct.unique_lists.(cur_col_name(1:end-4))] = local_get_idx_in_unique_list(cur_data, data_struct.unique_lists.(cur_col_name(1:end-4)));
				data_struct.data(data_struct.first_empty_row_idx, cur_col_idx : cur_col_idx + n_cols_in_cur_cell - 1) = numeric_idx_value;
			else
				error(['Failed adding a string value (', cur_data,')to a non _idx data column (', cur_col_name,').']);
			end
		end
		cur_col_idx = cur_col_idx + n_cols_in_cur_cell;
	end
end

data_struct.first_empty_row_idx = data_struct.first_empty_row_idx + 1;

if (batch_size > 1) && (data_struct.first_empty_row_idx > size(data_struct.data, 1))
	data_struct.data(end+1:end+batch_size, :) = zeros([batch_size, size(data_struct.data, 2)]);
end

return
end



function [ ] = local_add_data_row_to_global_struct( new_row_data, batch_size )
global data_struct
if ~(exist('batch_size', 'var'))
	batch_size = 1;
end

% is new_row_data numeric? then just try to add it
if isnumeric(new_row_data)
	if (size(new_row_data, 2) == length(data_struct.header))
		data_struct.data(data_struct.first_empty_row_idx, :) = new_row_data;
	else
		error(['Failed adding a row of ', num2str(size(new_row_data, 2)), ' columns to a table', num2str(length(data_struct.header)), ' columns wide.']);
	end
end

% alternatively interpret the input as a cell_list and loop through the
% members...
if iscell(new_row_data)
	cur_col_idx = 1;
	n_cells = length(new_row_data);
	for i_cell = 1 : n_cells
		cur_data = new_row_data{i_cell};
		% accept numeric vectors and add them at the current col_idx
		if isnumeric(cur_data)
			n_cols_in_cur_cell = size(cur_data, 2);
			data_struct.data(data_struct.first_empty_row_idx, cur_col_idx : cur_col_idx + n_cols_in_cur_cell - 1) = cur_data;
		end
		
		% accept strings for _idx columns
		if ischar(cur_data)
			cur_col_name = data_struct.header{cur_col_idx};
			if (length(cur_col_name) > 3) && strcmp('_idx', cur_col_name(end-3:end))
				n_cols_in_cur_cell = size(cur_data, 1);
				[numeric_idx_value, data_struct.unique_lists.(cur_col_name(1:end-4))] = local_get_idx_in_unique_list(cur_data, data_struct.unique_lists.(cur_col_name(1:end-4)));
				data_struct.data(data_struct.first_empty_row_idx, cur_col_idx : cur_col_idx + n_cols_in_cur_cell - 1) = numeric_idx_value;
			else
				error(['Failed adding a string value (', cur_data,')to a non _idx data column (', cur_col_name,').']);
			end
		end
		cur_col_idx = cur_col_idx + n_cols_in_cur_cell;
	end
end

data_struct.first_empty_row_idx = data_struct.first_empty_row_idx + 1;
% increase batch_wise
if (batch_size > 1) && (data_struct.first_empty_row_idx > size(data_struct.data, 1))
	data_struct.data(end+1:end+batch_size, :) = zeros([batch_size, size(data_struct.data, 2)]);
end


return
end


function [ data_struct ] = local_truncate_to_actual_size( data_struct )
% remove assigned but unused rows of the data array.
if (data_struct.first_empty_row_idx <= size(data_struct.data, 1))
	disp(['Removing ', num2str((size(data_struct.data, 1) - data_struct.first_empty_row_idx + 1)),' unused rows from data_struct.data']);
	data_struct.data(data_struct.first_empty_row_idx:end, :) = [];
end

return
end


function [ idx_in_list, list ] = local_get_idx_in_unique_list( cur_value, cur_value_list )
%try to find cur_value in the list of string values, add at the end if it
%did not exist yet
list = cur_value_list;
% find the current value in the list
idx_in_list = find(ismember(cur_value_list, cur_value));

% we came up empty, just add it to the end..
if  isempty(idx_in_list) || ~(idx_in_list)
	idx_in_list = length(cur_value_list) + 1;
	list{end + 1} = cur_value;
end

return
end



function [columnnames_struct, n_fields] = local_get_column_name_indices(name_list, start_val)
% return a structure with each field for each member if the name_list cell
% array, giving the position in the name_list, then the columnnames_struct
% can serve as to address the columns, so the functions assigning values
% to the columns do not have to care too much about the positions, and it
% becomes easy to add fields.
% name_list: cell array of string names for the fields to be added
% start_val: numerical value to start the field values with (if empty start
%            with 1 so the results are valid indices into name_list)

if nargin < 2
	start_val = 1;  % value of the first field
end
n_fields = length(name_list);
for i_col = 1 : length(name_list)
	cur_name = name_list{i_col};
	% skip empty names, this allows non consequtive numberings
	if ~isempty(cur_name)
		columnnames_struct.(cur_name) = i_col + (start_val - 1);
	end
end
return
end