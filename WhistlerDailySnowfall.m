function [x,y] = WhistlerDailySnowfall()
% Data pair 87
% From description:
% Whistler Daily Snowfall (from http://www.mldata.org/repository/data/viewslug/whistler-daily-snowfall/)
% 
% Historical daily snowfall data in Whistler, BC, Canada over the period July 1 1972 to December 31 2009. Measured at top of Whistler Gondola: Latitude: 50°04'04.000" N Longitude: 122°56'50.000" W Elevation: 1835.00 m 
% 
% Two attributes were selected: 
% X = MeanTemp (deg Celsius)
% Y = TotalSnow (cm)
% 
% Common sense tells us that X causes Y (with maybe very small feedback of Y on X). Confounders are present (e.g., day of the year).
% 
% X-->Y

basedir = 'PairsForTesting/pairs/';
fprefix = 'pair';
ftype = '.txt';

% snowfall data
ftemp = sprintf('%s%s%04d%s',basedir,fprefix,87,ftype);
SF = dlmread(ftemp);

% unpack data
x = SF(:,1)';
y = SF(:,2)';
