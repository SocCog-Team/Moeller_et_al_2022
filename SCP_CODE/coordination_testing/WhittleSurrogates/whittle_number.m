function num = whittle_number(f,u,v)
% Shawn Pethel, Oct 2012
%
% INPUTS
% f:            a transition count matrix
% u:           the start word
% v:            the end word
%
% OUTPUTS
% num:      the  natural log of the number of
%               sequences with f, u, and v
%
% EXAMPLE:
% >> d = [0 1 1 0 1 0 1 1 1 0 0 1];
% >> [f w u v] = trans_count(d,1);
% >> n = whittle_number(f,u,v)
% n = 4.3820
% >> exp(n)
% ans = 80.0000

N = size(f,1);
if size(f,2)==1 %if f is not a matrix then use number of permutations
    num = stirl(sum(f)) - sum(stirl(f));
    return
end
rsum = sum(f,2);
% Use sparse matrices in computation
seye = sparse(1:N,1:N,1);
sd = sparse(1:N,1:N,1./rsum);
fs = seye - sd*f;
fs(v,:) = [];
fs(:,u) = [];
cf = abs(det(fs));
num = log(cf) + sum(stirl(rsum))- sum(sum(stirl(nonzeros(f))));

function s = stirl(x)
% Computes log(x!)
% Uses a Stirling series approximation for x > 16
i = (x <= 16);
j = (x > 16);
a = x(i);
b = x(j);
s1 = log(factorial(a));
s2 = b.*log(b) - b + 0.5*log(2*pi*b) + 1./(12*b)- 1./(360*b.^3) + 1./(1260*b.^5)-1./(1680*b.^7);
s = zeros(length(x),1);
s(i) = s1;
s(j) = s2;