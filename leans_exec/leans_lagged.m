function leanout = leans_lagged(x,y,xtol,ytol,lags)
% This is constructed such that a positive leaning means x drives y more 
% than y drives x (and vice versa for a negative leaning).

leans = nan(length(lags),2);

for liter = 1:1:length(lags),
    leans(liter,1) = lags(liter);
    leans(liter,2) = mean(pen_lagged(x,y,xtol,ytol,lags(liter))-pen_lagged(y,x,ytol,xtol,lags(liter)));
end;
    
leanout = leans;
