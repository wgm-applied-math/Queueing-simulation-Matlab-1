function [res, p] = sort_by(v, f)
    u = zeros(size(v));
    for j = 1:size(v, 2)
        u(j) = f(v{j});
    end
    [~, p] = sort(u);
    res = v(p);
end