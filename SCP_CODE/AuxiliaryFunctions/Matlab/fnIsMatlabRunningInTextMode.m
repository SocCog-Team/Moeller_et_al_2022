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

