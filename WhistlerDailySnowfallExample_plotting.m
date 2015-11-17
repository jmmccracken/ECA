
% load X and Y
[x,y] = WhistlerDailySnowfall();

% set liblength for plotting
liblength = length(x);

%% plot X 
width = 8;
height = 4;

figure('Units', 'inches', ...
'Position', [0 0 width height],...
'PaperPositionMode','auto');

hold on;

plot(1:1:liblength,x,'k.','MarkerSize',15);
xlabel('t','FontName','Times','FontSize', 15);
ylabel('x_t','FontName','Times','FontSize', 15);
grid on;
set(gca,'fontsize',15);
% ylim([-1 2.5]);

hold off;
print -depsc2 ./WhistlerDailyExample_X.eps
close;

%% plot Y 
figure('Units', 'inches', ...
'Position', [0 0 width height],...
'PaperPositionMode','auto');

hold on;

plot(1:1:liblength,y,'k.','MarkerSize',15);
xlabel('t','FontName','Times','FontSize', 15);
ylabel('y_t','FontName','Times','FontSize', 15);
grid on;
set(gca,'fontsize',15);
% ylim([-2 3.5]);

hold off;
print -depsc2 ./WhistlerDailyExample_Y.eps
close;

%% histogram X 
figure('Units', 'inches', ...
'Position', [0 0 width height],...
'PaperPositionMode','auto');

hold on;

hist(x,100);
ylabel('counts','FontName','Times','FontSize', 15);
xlabel('x_t bins','FontName','Times','FontSize', 15);
grid on;
set(gca,'fontsize',15);
% ylim([-1 2.5]);

hold off;
print -depsc2 ./WhistlerDailyExample_Xhist.eps
close;

%% histogram Y 
figure('Units', 'inches', ...
'Position', [0 0 width height],...
'PaperPositionMode','auto');

hold on;

hist(y,100);
ylabel('counts','FontName','Times','FontSize', 15);
xlabel('y_t bins','FontName','Times','FontSize', 15);
grid on;
set(gca,'fontsize',15);
% ylim([-2 3.5]);

hold off;
print -depsc2 ./WhistlerDailyExample_Yhist.eps
close;

%% Autocorrelation X and Y

lags = 1:1:50;
autocorrX = nan(length(lags),1);
autocorrY = nan(length(lags),1);

for liter = 1:1:length(lags),
    autocorrX(liter,1) = abs(corr(x((lags(liter)+1):end)',x(1:(end-lags(liter)))'))^2;
    autocorrY(liter,1) = abs(corr(y((lags(liter)+1):end)',y(1:(end-lags(liter)))'))^2;
end;

figure('Units', 'inches', ...
'Position', [0 0 width height],...
'PaperPositionMode','auto');

hold on;

plot(lags,autocorrX,'k.','MarkerSize',15);
ylabel('|r(x_{t-l},x_t)|^2','FontName','Times','FontSize', 15);
xlabel('l','FontName','Times','FontSize', 15);
grid on;
set(gca,'fontsize',15);
% ylim([-2 3.5]);

hold off;
print -depsc2 ./WhistlerDailyExample_autocorrX.eps
close;

figure('Units', 'inches', ...
'Position', [0 0 width height],...
'PaperPositionMode','auto');

hold on;

plot(lags,autocorrY,'k.','MarkerSize',15);
ylabel('|r(y_{t-l},y_t)|^2','FontName','Times','FontSize', 15);
xlabel('l','FontName','Times','FontSize', 15);
grid on;
set(gca,'fontsize',15);
% ylim([-2 3.5]);

hold off;
print -depsc2 ./WhistlerDailyExample_autocorrY.eps
close;

%% Leaning and LCC

addpath('leans_exec');
LCClags = 1:1:20;
xtol = (max(x)-min(x))/4;
ytol = (max(y)-min(y))/4;
leanings = nan(length(LCClags),1);
for lag_iter = 1:1:length(LCClags),
    leantemp = leans_lagged(x,y,xtol,ytol,LCClags(lag_iter));
    leanings(lag_iter,1) = leantemp(1,2);
end;
laggedcorrsXY = nan(length(LCClags),1);
laggedcorrsYX = nan(length(LCClags),1);
for clag_iter = 1:1:length(LCClags),
    laggedcorrsXY(clag_iter,1) = corr(x((LCClags(clag_iter)+1):end)',y(1:(end-LCClags(clag_iter)))');
    laggedcorrsYX(clag_iter,1) = corr(y((LCClags(clag_iter)+1):end)',x(1:(end-LCClags(clag_iter)))');
end;
Deltal = abs(laggedcorrsXY)-abs(laggedcorrsYX);

figure('Units', 'inches', ...
'Position', [0 0 width height],...
'PaperPositionMode','auto');

hold on;

plot(LCClags,leanings,'k.',LCClags,Deltal,'ko','MarkerSize',15);
% ylabel('','FontName','Times','FontSize', 15);
xlabel('l','FontName','Times','FontSize', 15);
legend('\langle \lambda_l \rangle','\Delta_l');
grid on;
set(gca,'fontsize',15);
% ylim([-2 3.5]);

hold off;
print -depsc2 ./WhistlerDailyExample_LandLCC.eps
close;

%% GC, TE, and PAI results (no print to terminal, no plots)

[TE,GC,PAI,L,LCC,g] = ECA(x,y,xtol,ytol,LCClags,100,1,true,false);

