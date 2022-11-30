function [ ret_val ] = write_out_figure(img_fh, outfile_fqn, verbosity_str, print_options_str)
%WRITE_OUT_FIGURE save the figure referenced by img_fh to outfile_fqn,
% using .ext of outfile_fqn to decide which image type to save as.
%   Detailed explanation goes here
% write out the data

if ~exist('verbosity_str', 'var')
	verbosity_str = 'verbose';
end

% check whether the path exists, create if not...
[pathstr, name, img_type] = fileparts(outfile_fqn);
if isempty(dir(pathstr)),
	mkdir(pathstr);
end

% deal with r2016a changes, needs revision
%if (strcmp(version('-release'), '2016a'))
if (ismember(version('-release'), {'2016a', '2019a', '2019b', '2020b'}))
	set(img_fh, 'PaperPositionMode', 'manual');
	if ~ismember(img_type, {'.png', '.tiff', '.tif'})
		print_options_str = '-bestfit';
	end
end

if ~exist('print_options_str', 'var') || isempty(print_options_str)
	print_options_str = '';
else
	print_options_str = [', ''', print_options_str, ''''];
end
resolution_str = ', ''-r600''';





device_str = [];

switch img_type(2:end)
	case 'pdf'
		% pdf in 7.3.0 is slightly buggy...
		%print(img_fh, '-dpdf', outfile_fqn);
		device_str = '-dpdf';
	case 'ps3'
		%print(img_fh, '-depsc2', outfile_fqn);
		device_str = '-depsc';
		print_options_str = '';
		outfile_fqn = [outfile_fqn, '.eps'];
	case {'ps', 'ps2'}
		%print(img_fh, '-depsc2', outfile_fqn);
		device_str = '-depsc2';
		print_options_str = '';
		outfile_fqn = [outfile_fqn, '.eps'];
	case {'tiff', 'tif'}
		% tiff creates a figure
		%print(img_fh, '-dtiff', outfile_fqn);
		device_str = '-dtiff';
	case 'png'
		% tiff creates a figure
		%print(img_fh, '-dpng', outfile_fqn);
		device_str = '-dpng';
		resolution_str = ', ''-r1200''';
	case 'eps'
		%print(img_fh, '-depsc', '-r300', outfile_fqn);
		device_str = '-depsc';
	case 'fig'
		%sm: allows to save figures for further refinements
		saveas(img_fh, outfile_fqn, 'fig');
	otherwise
		% default to uncompressed images
		disp(['Image type: ', img_type, ' not handled yet...']);
end

if ~isempty(device_str)
	device_str = [', ''', device_str, ''''];
	command_str = ['print(img_fh', device_str, print_options_str, resolution_str, ', outfile_fqn)'];
	eval(command_str);
end

if strcmp(verbosity_str, 'verbose')
	if ~isnumeric(img_fh)
		disp(['Saved figure (', num2str(img_fh.Number), ') to: ', outfile_fqn]);	% >R2014b have structure figure handles
	else
		disp(['Saved figure (', num2str(img_fh), ') to: ', outfile_fqn]);			% older Matlab has numeric figure handles
	end
end

ret_val = 0;

return
end
