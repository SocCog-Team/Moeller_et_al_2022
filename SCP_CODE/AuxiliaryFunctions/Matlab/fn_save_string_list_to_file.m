function [  ] = fn_save_string_list_to_file( file_handle, prefix_string, string_data, sufffix_string, do_write )
%FN_SAVE_STRING_LIST_TO_FILE Summary of this function goes here
%   Detailed explanation goes here

% assume by default the user wants to have the string written out.
if ~exist('do_write', 'var') || isempty(do_write) || (do_write == 0)
	do_write = 1;
end

if (do_write == 0)
	disp('Write cancelled by do_write override');
	return
end
	
if ~exist('file_handle', 'var') || isempty(file_handle)
	disp('File handle empty or missing');
	return
end


% check for file handle or string
if isa(file_handle, 'double')
	file_handle_is_filename = 0;
	current_file_handle = file_handle;
	%fprintf(file_handle, '%s\n', string_data);
else
	if isstr(file_handle)
		file_handle_is_filename = 1;
		error('Handling of filenames not implemented yet');
		[current_file_handle, errmsg] = fopen(file_handle, 'w', 'n', 'UTF-8');
		if (current_file_handle == -1)
			error(errmsg);
		end
	else
		disp('File handle neither double nor string, nothing to do');
		return
	end
end	

% just deal with cells of strings
if isstr(string_data)
	string_data = {string_data};
end

if	iscellstr(string_data)
	for i_cell = 1 : length(string_data)
		current_string = string_data{i_cell};
		if ~isempty(prefix_string)
			current_string = [prefix_string, current_string];
		end
		if ~isempty(sufffix_string)
			current_string = [current_string, sufffix_string];
		end
		% now write the current line of data out to file
		fprintf(current_file_handle, '%s\n', current_string);	
	end
end

% clean up 
if (file_handle_is_filename)
	fclose(current_file_handle);
end

return
end

