function [ output_args ] = AddToMatlabPath( FullyQualifiedDirectoryToAdd, MfileToRun, MfileToOpen )
%ADDTOMATLABPATH Add the current or given path including its sub-folders
%temporarily to the matlab path.
%
% AddToMatlabPath( FullyQualifiedDirectoryToAdd, MfileToRun, MfileToOpen )
% FullyQualifiedDirectoryToAdd: if not empty add the directory tree
% starting at that directory to the matlab path, otherwise take the current
% directory.
% MfileToRun: if specified, execute that matlab mfile after adding to the
% matlab path
% MfileToOpen: if specified, open that matlab mfile after adding to the
% matlab path
% Note: This will first remove all entries of the matlab path starting with
% FullyQualifiedDirectoryToAdd to work around the fact that change
% notification on network shares sometimes does not work.

% exclude path segments containing the following sections
ExcludeDirectoryPatternList = {'.git'};

output_args = [];
CurrentDir = pwd;

% allow empty or missing FullyQualifiedDirectoryToAdd
if ~exist('FullyQualifiedDirectoryToAdd', 'var') || isempty(FullyQualifiedDirectoryToAdd)
	FullyQualifiedDirectoryToAdd = fileparts(mfilename('fullpath'));
end
if ~exist('MfileToRun', 'var') || isempty(MfileToRun)
	MfileToRun = [];
end
if ~exist('MfileToOpen', 'var') || isempty(MfileToOpen) || fnIsMatlabRunningInTextMode()
	MfileToOpen = [];
end


if isfolder(FullyQualifiedDirectoryToAdd)
cd(FullyQualifiedDirectoryToAdd);
CurrentMatlabPath = path;


PathToAddIsAlreadyDefined = strfind(CurrentMatlabPath, [FullyQualifiedDirectoryToAdd, pathsep]);

% delete existing paths containing the calling directory
% this is a work around for matlab's inability to detect changed files on
% many network shares (especially windows)
if ~isempty(PathToAddIsAlreadyDefined)
	disp([mfilename, ': Removing directory tree from matlab path starting with ', FullyQualifiedDirectoryToAdd]);
	disp([mfilename, ': This might take a while...']);
	% turn the path into cell array
	while length(CurrentMatlabPath) > 0
		[CurrentPathItem, remain] = strtok(CurrentMatlabPath, pathsep);
		CurrentMatlabPath = remain(2:end);
		if ~isempty(strfind(CurrentPathItem, FullyQualifiedDirectoryToAdd))
			rmpath(CurrentPathItem);
		end
	end
end
% now add them again
disp([mfilename, ': Adding ', FullyQualifiedDirectoryToAdd, ' and subdirectories temporarily to matlab path.']);
addpath(genpath(pwd()));

else
	disp(['WARNING: Requested folder (', FullyQualifiedDirectoryToAdd, ' does not exist, skipping']);
end



% remove .git folders to keep the matlab path reasonable
CurrentMatlabPath = path;
for iExcludeDirectoryPattern = 1 : length(ExcludeDirectoryPatternList)
	CurrentExcludePattern = ExcludeDirectoryPatternList{iExcludeDirectoryPattern};
	while length(CurrentMatlabPath) > 0
		[CurrentPathItem, remain] = strtok(CurrentMatlabPath, pathsep);
		CurrentMatlabPath = remain(2:end);
		if ~isempty(strfind(CurrentPathItem, CurrentExcludePattern))
			rmpath(CurrentPathItem);
		end
	end
end


if ~isempty(MfileToOpen)
	open(MfileToOpen);
end

if ~isempty(MfileToRun)
	run(MfileToOpen);
end

cd(CurrentDir);

return
end

function [ running_in_text_mode ] = fnIsMatlabRunningInTextMode( input_args )
%FNISMATLABRUNNINGFROMCLI is this matlab instance running as textmode
%application
%   Detailed explanation goes here

running_in_text_mode = 0;

if (~usejava('awt'))
	running_in_text_mode = 1;
end

return
end

