function [res, p] = sort_by(v, f)
% sort_by  Sort a cell array based on the value of a function applied to
% each item
%
% [res, p] = sort_by(v, f) Sort v, giving the result vector res, and
% permutation p.
    u = zeros(size(v));
    for j = 1:size(v, 2)
        u(j) = f(v{j});
    end
    [~, p] = sort(u);
    res = v(p);
end