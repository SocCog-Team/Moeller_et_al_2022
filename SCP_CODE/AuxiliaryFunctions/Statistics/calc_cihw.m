function [ci_halfwidth_vector] = calc_cihw(std_vector, n, alpha)
%calc_ci : calculate the half width of the confidence interval (for 1 - alpha)
%	the t_value lookup depends on alpha and the samplesize n; the relevant
%	calculation of the degree of freedom is performed inside calc_t_val.
%	ci_halfwidth = t_val(alpha, n-1) * std / sqrt(n)
%	Each groups CI ranges from mean - ci_halfwidth to mean - ci_halfwidth, so
%	the calling function has to perform this calculation...
%
% INPUTS:
%	std_vector: vector containing the standard deviations of all requested
%		groups
%	n: number of samples in each group, if the groups have different
%		samplesizes, specify each groups samplesize in a vector
%	alpha: the desired maximal uncertainty/error in the range of [0, 1]
% OUTPUT:
%	ci_halfwidth_vector: vector containing the confidence intervals half width
%		for each group

% calc_t_val return one sided t-values, for the desired two sidedness one has
% to half the alpha for the table lookup
cur_alpha = alpha / 2;

% if n is scalar use same n for all elements of std_vec
if isscalar(n)
	t_ci = calc_t_val(cur_alpha, n);
	ci_halfwidth_vector = std_vector * t_ci / sqrt(n);
	% if n is a vector, prepare a matching vector of t_ci values
elseif isvector(n)
	t_ci_vector = n;
	% this is probably ugly, but calc_t_val only accepts scalars.
	for i_pos = 1 : length(n)
		t_ci_vector(i_pos) = calc_t_val(cur_alpha, n(i_pos));
	end
	ci_halfwidth_vector = std_vector .* t_ci_vector ./ sqrt(n);
elseif ismatrix(n) && ismatrix(std_vector)
	% if both are matrices of identical size, linearize both, calc ci and
	% reassemble the array again for the ci's
	if (isequal(size(std_vector), size(n)))
		t_ci_vector = n(:);
		% this is probably ugly, but calc_t_val only accepts scalars.
		for i_pos = 1 : length(t_ci_vector)
			t_ci_vector(i_pos) = calc_t_val(cur_alpha, n(i_pos));
		end
		t_ci_array = reshape(t_ci_vector, size(n));
		ci_halfwidth_vector = std_vector .* t_ci_array ./ sqrt(n);
	else
		disp('Could not match standard deviation and N dimensions, bailing out...');
	end
end

return

%-----------------------------------------------------------------------------
function [t_val] = calc_t_val(alpha, n)
% the t value for the given alpha and n
% so call with the n of the sample, not with degres of freedom
% see http://mathworld.wolfram.com/Studentst-Distribution.html for formulas
% return values follow Bortz, Statistik fuer Sozialwissenschaftler, Springer 
% 1999, table D page 775. That is it returns one sided t-values.
% primary author S. Moeller

% TODO:
%	sidedness of t-value???

% basic error checking
if nargin < 2
	error('alpha and n have to be specified...');
end

% probabilty of error
tmp_alpha = alpha ;%/ 2;
if (tmp_alpha < 0) | (tmp_alpha > 1)
	msgbox('alpha has to be taken from [0, 1]...');
	t_val = NaN;
	return
end
if tmp_alpha == 0
	t_val = -Inf;
	return
elseif tmp_alpha ==1
	t_val = Inf;
	return
end
% degree of freedom
df = n - 1;
if df < 1
	%msgbox('The n has to be >= 2 (=> df >= 1)...');
% 	disp('The n has to be >= 2 (=> df >= 1)...');
	t_val = NaN;
	return
end


% only calculate each (alpha, df) combination once, store the results
persistent t_val_array;
% create the t_val_array
if ~iscell(t_val_array)
	t_val_array = {[NaN;NaN]};
end
% search for the (alpha, df) tupel, avoid calculation if already stored
if iscell(t_val_array)
	% cell array of 2d arrays containing alpha / t_val pairs
	if df <= length(t_val_array)
		% test whether the required alpha, t_val tupel exists
		if ~isempty(t_val_array{df})
			% search for alpha
			tmp_array = t_val_array{df};
			alpha_index = find(tmp_array(1,:) == tmp_alpha);
			if any(alpha_index)
				t_val = tmp_array(2, alpha_index);
				return
			end
		end
	else
		% grow t_val_array to length of n
		missing_cols = df - length(t_val_array);
		for i_missing_cols = 1: missing_cols
			t_val_array{end + 1} = [NaN;NaN];
		end
	end
end

% check the sign
cdf_sign = 1;
if (1 - tmp_alpha) == 0.5
	t_val = t_cdf;
elseif (1 - tmp_alpha) < 0.5 % the t-cdf is point symmetric around (0, 0.5)
	cdf_sign = -1;
	tmp_alpha = 1 - tmp_alpha; % this will be undone later
end

% init some variables
n_iterations = 0;
delta_t = 1;
last_alpha = 1;
higher_t = 50;
lower_t = 0;
% find a t-value pair around the desired alpha value 
while norm_students_cdf(higher_t, df) < (1 - tmp_alpha);
	lower_t = higher_t;
	higher_t = higher_t * 2;
end

% search the t value for the given alpha...
while (n_iterations < 1000) & (abs(delta_t) >= 0.0001)
	n_iterations = n_iterations + 1;
	% get the test_t (TODO linear interpolation) 
 	% higher_alpha = norm_students_cdf(higher_t, df);
 	% lower_alpha = norm_students_cdf(lower_t, df);
	test_t = lower_t + ((higher_t - lower_t) / 2);
	cur_alpha = norm_students_cdf(test_t, df);
	% just in case we hit the right t spot on...
	if cur_alpha == (1 - tmp_alpha)
		t_crit = test_t;
		break;
	% probably we have to search for the right t
	elseif cur_alpha < (1 - tmp_alpha)
		% test_t is the new lower_t
		lower_t = test_t;
		%higher_t = higher_t;	% this stays as is...
	elseif cur_alpha > (1 - tmp_alpha)
		% 
		%lower_t = lower_t;	% this stays as is...
		higher_t = test_t;
	end
	delta_t = higher_t - lower_t;
	last_alpha = cur_alpha;
end
t_crit = test_t;

% set the return value, correct for negative t values
t_val = t_crit * cdf_sign;
if cdf_sign < 0
	tmp_alpha = 1 - tmp_alpha;
end

% store the alpha, n, t_val tupel in t_val_array
pos = size(t_val_array{df}, 2);
t_val_array{df}(1, (pos + 1)) = tmp_alpha;
t_val_array{df}(2, (pos + 1)) = t_val;

return

%-----------------------------------------------------------------------------
function [scaled_cdf] = norm_students_cdf(t, df)
% calculate the cdf of students distribution for a given degree of freedom df,
% and all given values of t, then normalize the result
% the extreme values depend on the values of df!!!

% get min and max by calculating values for extrem t-values (e.g. -10000000,
% 10000000)
extreme_cdf_vals = students_cdf([-10000000, 10000000], df);

tmp_cdf = students_cdf(t, df);

scaled_cdf =	(tmp_cdf - extreme_cdf_vals(1)) /...
				(extreme_cdf_vals(2) - extreme_cdf_vals(1));
return

%-----------------------------------------------------------------------------
function [cdf_value_array] = students_cdf(t_value_array, df)
%students_cdf: calc the cumulative density function for a t-distribution
% Calculate the CDF value for each value t of the input array
% see http://mathworld.wolfram.com/Studentst-Distribution.html for formulas
% INPUTS:	t_value_array:	array containing the t values for which to
%							calculate the cdf
%			df:	degree of freedom; equals n - 1 for the t-distribution

cdf_value_array = 0.5 +...
		((betainc(1, 0.5 * df, 0.5) / beta(0.5 * df, 0.5)) - ...
		(betainc((df ./ (df + t_value_array.^2)), 0.5 * df, 0.5) /...
		beta(0.5 * df, 0.5))) .*...
		sign(t_value_array);
	
return

%-----------------------------------------------------------------------------
function [t_prob_dist] = students_pf(df, t_arr)
%  calculate the probability function for students t-distribution

t_prob_dist =	(df ./ (df + t_arr.^2)).^((1 + df) / 2) /...
				(sqrt(df) * beta(0.5 * df, 0.5));

% % calculate and scale the cdf by hand...
% cdf = cumsum(t_prob_dist);
% discrete_t_cdf = (cdf - min(cdf)) / (max(cdf) - min(cdf));
% % numericaly get the t-value for the given alpha
% tmp_index = find(discrete_t_cdf > (1 - tmp_alpha));
% t_crit = t(tmp_index(1));
				
return



