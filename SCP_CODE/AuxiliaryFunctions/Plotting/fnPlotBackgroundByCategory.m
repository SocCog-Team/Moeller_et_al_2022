function [] = fnPlotBackgroundByCategory( CategoryByXValList, YLimits, ColorByCategoryList, Transparency )
%FNPLOTBACKGROUNDBYCATEGORY use a point by point vector to color the
%background by category.
%   use patch to plot a color overlay on the current axes.
% CategoryByTrialList gives the category index for each X value
% YLimits gives the lower and upper value for the background plot
% ColorByCategoryList gives the colorspec for each category
% a category index of 0 denotes skip this x value

% TODO:
%   Test and adapt for plots with step size other than one
%   Test and adapt for plots starting at arbitrary values
%       think about how to scsale each individual patch
%
% DONE:
%   test with multiple categories

% default to full opaqueness (the Variable has a terrible name in matlab)
if ~exist('Transparency', 'var') || isempty(Transparency)
    Transparency = 1;
end

unique_categories_list = unique(CategoryByXValList);

if unique_categories_list(1) == 0
    num_categories = length(unique_categories_list) - 1;
    cat_start_idx = 2;
else
    num_categories = length(unique_categories_list);
    cat_start_idx = 1;
end


if unique_categories_list(1) == 0 && length(unique_categories_list) == 1
    disp('All X values belong to category zero, nothing to do...');
    return
end

% the following will mis trigger for sparse category
% %allow empty categories as long as a matchin color row exists for the
% %existing categories
% if size(ColorByCategoryList, 1) ~= num_categories && unique_categories_list(end) ~= size(ColorByCategoryList, 1)
%     error('Fewer colors than categories defined, no clue what to do...');
% end
if size(ColorByCategoryList, 1) < max(unique_categories_list)
    error('Fewer colors than category indices defined, no clue what to do...');
end

% check and expand the transparency
if (length(Transparency) > 1) && (length(Transparency) ~= max(unique_categories_list))
    error(['The number of items in the Transparency array (', num2str(length(Transparency)), ') does not match the highest category index (', num2str(max(unique_categories_list)), ')?']);
end

if (length(Transparency) == 1) && (length(Transparency) < max(unique_categories_list))
    TransparencyByCategory = ones([max(unique_categories_list), 1]) * Transparency;
else
    TransparencyByCategory = Transparency;
end

for i_category = cat_start_idx : length(unique_categories_list)
    CurrentCategory = unique_categories_list(i_category);
    CurrentCatXVals = (CategoryByXValList == CurrentCategory);
    %CurrentCatColor = ColorByCategoryList((i_category - cat_start_idx + 1), :);
    CurrentCatColor = ColorByCategoryList(CurrentCategory, :);
    CurrentCatTransparency = TransparencyByCategory(CurrentCategory);
    
    
    % collect all XValues as rectangles
    patch_x_array = [];
    patch_y_array = [];
    for i_current_cat_xval = 1 : length(CurrentCatXVals)
        if (CurrentCatXVals(i_current_cat_xval) == 1)
            current_x_list = [ i_current_cat_xval - 0.5; i_current_cat_xval - 0.5; i_current_cat_xval + 0.5; i_current_cat_xval + 0.5];
            current_y_list = [ YLimits(1); YLimits(2); YLimits(2); YLimits(1)];
            if ~isempty(patch_x_array) && isequal(current_x_list(1:2), patch_x_array(3:4, end))
                % this is an extension of the last patch, just extend its
                % end
                patch_x_array(3:4, end) = current_x_list(3:4);
            else
                % add a new patchlet
                patch_x_array = [patch_x_array, current_x_list];
                patch_y_array = [patch_y_array, current_y_list];
            end
        end
    end
    % and now actually display the patch on the plot
    patch('XData', patch_x_array, 'YData', patch_y_array, 'FaceColor', CurrentCatColor, 'EdgeColor', CurrentCatColor, 'EdgeAlpha', 0, 'FaceAlpha', CurrentCatTransparency);
end

return
end