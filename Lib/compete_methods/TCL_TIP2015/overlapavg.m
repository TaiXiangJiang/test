function [outmap] = overlapavg(X, hei, wid, t_hei, t_wid, patch)
% patch should be squared
subdiv = ones(patch, patch);
overlapX = zeros(t_hei, t_wid); 
div = zeros(t_hei, t_wid);

cnt = 1;
for x = 1:t_wid-patch+1
    for y = 1:t_hei-patch+1
        xblock = X(:,cnt);
        overlapX(y:y+patch-1, x:x+patch-1) = overlapX(y:y+patch-1, x:x+patch-1) + reshape(xblock, patch, patch);
        div(y:y+patch-1, x:x+patch-1) = div(y:y+patch-1, x:x+patch-1) + subdiv;
        cnt = cnt + 1;
    end
end
temp = overlapX./div;

outmap = temp(1:hei, 1:wid);
end