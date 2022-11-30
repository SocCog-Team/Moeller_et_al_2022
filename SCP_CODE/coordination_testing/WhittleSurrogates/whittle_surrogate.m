function seq = whittle_surrogate(f,w,u,v)
% WHITTLE_SURROGATE 
%
% seq = whittle_surrogate(f,w,u,v);
%
% Given a transition matrix produces a random sequence 
% with exactly the same transition count and beginning and
% end words as the original sequence. Keeping the same 
% beginning and end words guarantees that transition 
% probabilities are exactly the same as the original sequence.
%
% INPUTS (from trans_count.m)
% f:            a transition count matrix
% w:          a list of words
% u:           the start word
% v:            the end word
%
% OUTPUTS
% seq:      a randomly chosen sequence of words 
%               that have transition count f and beginning 
%               word u and end word v
%
% EXAMPLE:
% >> d = [0 1 1 0 1 0 1 1 1 0 0 1];
% >> [f w u v] = trans_count(d,1);
% >> seq = whittle_surrogate(f,w,u,v)
% seq = 0   1   0   1   1   0   1   1   1   0   0   1
% >> seq = whittle_surrogate(f,w,u,v)
% seq = 0   1   0   0   1   1   1   0   1   1   0   1
%
% Sucessive calls produce sequences sampled 
% randomly and uniformly from the set of all sequences
% with the same transition count and beginning and end
% word.
%
% Shawn Pethel, 2012

N = size(f,1);
sym = (1:N);
if size(f,2)==1 %if f is not a matrix then use random permutation
    indx = randperm(sum(f));
    seq = w(indx);
    return
end
n = sum(sum(f))+1;
% Generate a LUT for stirling's formula
stlut = stirl((0:n));
% tf = f;   % Uncomment here and below for error checking if wanted
seye = sparse(1:N,1:N,1);
ytrial = zeros(1,n);
ytrial(end) = v;
% Precompute as much as possible before entering inner loop
rsum = sum(f,2);
term1 = sum(stlut(rsum+1))- sum(sum(stlut(nonzeros(f)+1))); %The +1 is for correct indexing in the stlut
rsum(rsum==0) = 1;
sd = sparse(1:N,1:N,1./rsum); %Much faster than spdiags!
rsum = sum(f,2);
for mm=1:n-2
    ytrial(mm) = u;
    % Update row sum
    rsum(u) = rsum(u) -1;
    if rsum(u) > 0
        sd(u,u) = 1/rsum(u);
    else
        sd(u,u) = 0;
    end
    rw = sym(f(u,:) > 0); %These are the remaining options
    numb = zeros(1,3);
    cnt = 1;
    % Loop through all options for the next number
    for i=1:length(rw)
        ut = rw(i);
        g = f;
        g(u,ut) = g(u,ut) - 1;
        fs = seye - sd*g;
        fs(v,:) = [];
        fs(:,ut) = [];
        cf = abs(det(fs)); % % Possibility of accuracy issue here
        if cf > 0
            % g differs from f in only one element, so we take the
            % precomputed sum, remove the original element, and replace
            % with the corresponding one from g
            numb(cnt,3) = term1+stlut(f(u,ut)+1)-stlut(g(u,ut)+1);
            numb(cnt,2) = ut;
            numb(cnt,1) = numb(cnt,3) + log(cf);
            % computing log(cf) is safer, but slower with
            % sum(log(abs(diag(u)))), where [l u] = lu(fs)
            cnt = cnt + 1;
        end
    end
    % Compute relative probabilities of the different options
    ec = exp(numb(:,1) - max(numb(:,1)));
    ec = ec/sum(ec);
    rng = [0 cumsum(ec)'];
    % Choose one in accordance with their probabilites
    sr = rand(1);
    indx = (sr >= rng(1:end-1)) & (sr <= rng(2:end));
    ut = numb(indx,2);
    f(u,ut) = f(u,ut) - 1;
    u = ut;
    term1 = numb(indx,3);
end
ytrial(n-1) = numb(cnt-1,2);

% Uncomment  for error checking if wanted
% f = zeros(N,N);
% a = embed(ytrial,2);
% for i = 1:size(a,1)
%     f(a(i,1),a(i,2)) = f(a(i,1),a(i,2)) + 1;
% end
% if any(any(tf - f))
%     fprintf('Error!\n')
% end

% Convert number sequence back to symbol sequence
ls = size(w,2);
seq = zeros(1,n+ls-1);
seq(1:ls) = w(ytrial(1),:);
for i=2:n
    seq(ls+i-1) = w(ytrial(i),ls);
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