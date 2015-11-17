function [x,y] = DipoleModeIndex()
% see data readme
% -- monthly data --

basedir = 'data/';

% index data
ftemp = sprintf('%sdmi_HadISST.txt',basedir);
year_month_index = dlmread(ftemp);

% unpack data
x = year_month_index(:,1)';
y = year_month_index(:,3)';
