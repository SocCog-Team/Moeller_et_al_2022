function [pvalue scount] = MarkovOrderTests(r,N,K)
%
% [pvalues scount] = MarkovOrderTests(r,N,K) computes the exact
% p-values of Markov orders 0 - K for test data r. 
%
% Input arguments:
%   r ---- vector of discrete data (symbols)
%   N ---- the number of surrogates to use
%   K ---- the max Markov order to test
%
% Output arguments:
%   pvalues ---- a vector of p-values corresponding to
%                Markov orders zero through K
%   scount ---- log10 of the total number of unique
%               surrogates possible for each test
%
% Subplots with bar histograms are generated. Horizontal axes are block
% entropy (in bits) of order+2 words.
%
% Block entropy is used as the discrimating statistic, Whittle's formula
% is used to generated surrogates of the appropriate order. For details see 
% S. D. Pethel and D. W. Hahs, Exact significance test for Markov order,
% Physica D 269, 42-47 (2014).

% Example:
% >> r = [1 1 0 1 1 0 1 1 1 0 1 0 1 0 1 0 1 1 1 0 1 0 0 1 0 1 0 1 1 0];
% >> [pvalue scount] = MarkovOrderTests(r,10000,2);
% >> pvalue 
% pvalue = 
%   0.0001
%   0.4429
%   0.8150
%
% These values are the zeroth, first, and second order
% Markov p-values. In this example zeroth order is
% extremely unlikely.
%
% This code takes advantage of the Parallel Computing Toolbox,
% if available. Type 'matlabpool open' at the beginning of the session.
%
% Shawn Pethel, 2014

n = length(r);

% Do 0th order hypothesis test using shuffling
% Compute 0th order block entropy
t = embed(r,2);
h0 = block_entropy(t);

s0 = zeros(N,1);
pvalue = zeros(K+1,1);
scount = zeros(K+1,1);
% Zeroth Markov order test using simple permutation
scount(1) = stirl(n)/log(10);
%[0 h0 scount(1)]
parfor i=1:N
    indx = randperm(n);
    seq = r(indx);
    t = embed(seq,2);
    s0(i) = block_entropy(t);
end
pval = sum(s0 <= h0)/N;
pvalue(1) = pval;
%{
gs = subplot(K+1,1,1);
hist(s0,20)
hs = findobj(gs,'Type','patch');
set(hs,'FaceColor','w','EdgeColor','k')
yl = get(gs,'ylim');
text(h0,yl(2),[' p = ',num2str(pval,3)],'VerticalAlignment','top','FontSize',12)
hold on
plot([h0 h0],[yl(1) yl(2)],'k','linewidth',3)
hold off
%}
% Do orders 1 through K using Whittle surrogates
for k = 1:K
    t = embed(r,k+2);
    h0 = block_entropy(t);
    [matx, rw, st, ed] = trans_count(r,k);
    num = whittle_number(matx,st,ed);
    scount(k+1) = num/log(10);
    %[k h0 num/log(10)];
    h1 = zeros(N,1);
    parfor i=1:N
        seq = whittle_surrogate(matx,rw,st,ed);
        t = embed(seq,k+2);
        h1(i) = block_entropy(t);
    end
    pval = sum(h1 <= h0)/N;
    pvalue(k+1) = pval;
    gs = subplot(K+1,1,k+1);
    hist(h1,20)
    hs = findobj(gs,'Type','patch');
    set(hs,'FaceColor','w','EdgeColor','k')
    yl = get(gs,'ylim');
    text(h0,yl(2),[' p = ',num2str(pval,3)],'VerticalAlignment','top','FontSize',12)
    hold on
    plot([h0 h0],[yl(1) yl(2)],'k','linewidth',3)
    hold off
end

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

function z = embed(x,d)
% Converts the vector x into a matrix of d columns.
% The output columns are shifted in time by one unit.
x = x(:);
N = length(x);
i = (1:d);
j = (0:N-d)';
a = i(ones(N-d+1,1),:);
b = j(:,ones(1,d));
z = x(a+b);

function h = block_entropy(x,varargin)
% Computes the block entropy of the column vector x.
% If x is a matrix, each row is treated as a symbol.
[~, p] = unique_count(x);
m = length(p);
n = length(x);
p = p/sum(p);
h = -sum(p.*log2(p));
if ~isempty(varargin)
    if strcmp(varargin{1},'miller-madow')
        h = h + (m-1)/(2*n);
    end
end

function [y, c] = unique_count(x)
% Unique_count sorts and counts the rows of x
% y lists the unique rows and c their counts
if size(x,1) == 1;
    x = x(:);
end
y = sortrows(x);
d = any(y(1:end-1,:)-y(2:end,:),2);
d = [d; true];
ind = (1:size(y,1));
g=ind(d);
n = length(g);
c(1) = g(1);
c(2:n) = g(2:n) - g(1:n-1);
c = c';
y = y(g,:);