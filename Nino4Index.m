function [x,y] = Nino4Index()
% see data readme
% -- monthly data --

basedir = 'data/';

% index data
ftemp = sprintf('%snino4.long.data.trimmed',basedir);
year_monthXmonth = dlmread(ftemp);

% reformat
year_month = nan(size(year_monthXmonth,1)*12,2);
step = 1;
for yearidx = 1:1:size(year_monthXmonth,1),
    for monthidx = 1:1:(size(year_monthXmonth,2)-1),
        year_month(step,1) = year_monthXmonth(yearidx,1);
        year_month(step,2) = year_monthXmonth(yearidx,1+monthidx);
        step = step+1;
    end;
end;

% unpack data
x = year_month(:,1)';
y = year_month(:,2)';
