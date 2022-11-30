function [ aggregate_struct, report_string ] = fn_statistic_test_and_report(group_1_name, group_1_data, group_2_name, group_2_data, stat_type, verbose)

if ~exist('verbose', 'var') || isempty(verbose)
	verbose = 0;
end
report_string = [];

aggregate_struct.([group_1_name, '_mean']) = mean(group_1_data(:), 'omitnan');
aggregate_struct.([group_2_name, '_mean']) = mean(group_2_data(:), 'omitnan');
aggregate_struct.([group_1_name, '_median']) = median(group_1_data(:), 'omitnan');
aggregate_struct.([group_2_name, '_median']) = median(group_2_data(:), 'omitnan');
aggregate_struct.([group_1_name, '_std']) = std(group_1_data(:), 'omitnan');
aggregate_struct.([group_2_name, '_std']) = std(group_2_data(:), 'omitnan');
aggregate_struct.([group_1_name, '_n']) = length(group_1_data(~isnan(group_1_data)));
aggregate_struct.([group_2_name, '_n']) = length(group_2_data(~isnan(group_2_data)));


switch stat_type
	case {'ttest', 'paired_ttest'}
		% paired t-test
		[aggregate_struct.h, aggregate_struct.p, aggregate_struct.ci, aggregate_struct.stats] = ttest1(group_1_data(:), group_2_data(:));
		report_stat = 'mean_t';
	case 'ttest2'
		[aggregate_struct.h, aggregate_struct.p, aggregate_struct.ci, aggregate_struct.stats] = ttest2(group_1_data(:), group_2_data(:));
		report_stat = 'mean_t';
	case 'ttest2_unequalvariance'
		[aggregate_struct.h, aggregate_struct.p, aggregate_struct.ci, aggregate_struct.stats] = ttest2(group_1_data(:), group_2_data(:), 'Vartype','unequal');
		report_stat = 'mean_t';
	case 'ranksum'
		[aggregate_struct.p, aggregate_struct.h, aggregate_struct.stats] = ranksum(group_1_data(:), group_2_data(:), 'method', 'exact');
		report_stat = 'median';
		%[~, ~, aggregate_struct.stats_approximate] = ranksum(group_1_data(:), group_2_data(:), 'method', 'approximate');
		%report_stat = 'median';
	case 'ranksum_approximate'
		[aggregate_struct.p, aggregate_struct.h, aggregate_struct.stats] = ranksum(group_1_data(:), group_2_data(:), 'method', 'approximate');
		report_stat = 'median';
	otherwise
		error(['Unhandled statistics requested: ', stat_type]);
end

report_string = [stat_type, ': ', ];
switch report_stat
	case 'mean_t'
		% for t-tests....
		% the first mean and SD
		report_string = [report_string, group_1_name, ': (M: ', num2str(mean(group_1_data(:), 'omitnan'), '%.5f'), '; SD: ', num2str(std(group_1_data(:), 'omitnan')), '; N: ', num2str(aggregate_struct.([group_1_name, '_n'])), '); ', ...
			group_2_name, ': (M: ', num2str(mean(group_2_data(:), 'omitnan'), '%.5f'), '; SD: ', num2str(std(group_2_data(:), 'omitnan')), '; N: ', num2str(aggregate_struct.([group_2_name, '_n'])), '); ', ...
			't(', num2str(aggregate_struct.stats.df, '%.4f'), '): ', num2str(aggregate_struct.stats.tstat, '%.4f'), '; p:< ', num2str(aggregate_struct.p, '%.10f')];
		%disp(report_string);
		%disp(' ');
	case 'median'
		% the first median and SD
		disp(stat_type);
		report_string = [report_string, group_1_name, ': (MD: ', num2str(median(group_1_data(:), 'omitnan'), '%.5f'), '; N: ', num2str(aggregate_struct.([group_1_name, '_n'])), '); ', ...																		]);
			group_2_name, ': (MD: ', num2str(median(group_2_data(:), 'omitnan'), '%.5f'), '; N: ', num2str(aggregate_struct.([group_2_name, '_n'])), '); ', ...
			'p:< ', num2str(aggregate_struct.p, '%.10g')];
		if isfield(aggregate_struct.stats, 'ranksum')
			report_string = [report_string, '; ', 'ranksum: ', num2str(aggregate_struct.stats.ranksum, '%.4g')];
		end
		if isfield(aggregate_struct.stats, 'zval')
			 report_string = [report_string, '; ', 'Z: ', num2str(aggregate_struct.stats.zval)]; %', r: ', num2str(aggregate_struct.stats.zval/sqrt(aggregate_struct.([group_1_name, '_n'])))]};
			 if (aggregate_struct.([group_1_name, '_n']) == aggregate_struct.([group_2_name, '_n']))
				 report_string = [report_string, '; ','r: ', num2str(aggregate_struct.stats.zval/sqrt(aggregate_struct.([group_1_name, '_n'])), '%.4g')];
			 end
		end
		%disp(report_string);
		%disp(' ');
end

if (verbose)
	disp(report_string);
end

return
end

