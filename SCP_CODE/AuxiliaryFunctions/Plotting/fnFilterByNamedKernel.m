function [ filt_data_table ] = fnFilterByNamedKernel( data_table, filter_type, filter_half_width, shape )
%FNFILTERBYNAMEDKERNEL convenience function to allow specifying filter
%kernel by name
%   Detailed explanation goes here
%FILTER_ROWS Summary of this function goes here
%   Detailed explanation goes here
% TODO automatically switch to conv2 for 2D data

if (nargin < 4)
        shape = 'same';
end

filt_data_table = [];

if isempty(filter_type)
        filter_type = 'none';
end
% prepare the filter
switch filter_type
        case 'box'
                filter_kernel = ones(1, filter_half_width*2);
        case 'gaussian'
                % construct convolution kernel
                sigma = filter_half_width;
                filter_kernel = fspecial('gaussian',[1 8*sigma], sigma); % full width half maximum is sigma * (2 * sqrt(2 * log(2))), or 2.3548 * sigma
        case 'none'
                % nothing to do...
        otherwise
                error(['Unknown filter type requested: ', filter_type]);
end


if ~(strcmp(filter_type, 'none'))
        filt_data_table = conv(data_table, filter_kernel, shape);      % use conv instead of filter to avoid filter delay (cheaper than filtfilt?)
end

if (strcmp(filter_type, 'box'))
        % correct for the kernel width
        filt_data_table = filt_data_table / (filter_half_width*2);
end

return
end