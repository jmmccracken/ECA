function [TE,GC,PAI,L,LCC,g] = ECA(x,y,xtol,ytol,lags,E,tau,verb,skipGC)
% Exploratory Causal Analysis script
%
% returns several different structs and the ECA guess vector (0 is X->Y, 1
% is Y->X, NaN is otherwise)

%% transfer entropy (using JIDT)

if(verb)
    fprintf('Calculating the transfer entropy ...');
    tic;
end;

% JIDT likes column vectors, not row vectors
x_JIDT = x';
y_JIDT = y';

% locate the JAR
javaaddpath('./infodynamics-dist-1.2.1/infodynamics.jar');

% create the JIDT java object used for the TE calculations 
teCalc=javaObject('infodynamics.measures.continuous.kernel.TransferEntropyCalculatorKernel');

% set the normalizaion From JIDT scripts: "Normalise the individual
% variables. Schreiber doesn't explicitly say this is done for TE, but it 
% is done for the raw data plots in Figure 3 [of his original paper]."
teCalc.setProperty('NORMALISE', 'true'); 

% TE is calculated here with lag of 1 and a kernel width of 0.5 [normalized units]
teCalc.initialise(1, 0.5); 

% pass the signals to the JIDT object in X-Y order
teCalc.setObservations(x_JIDT,y_JIDT);

% calculate TE_{x->y}
TE.TE_xy = teCalc.computeAverageLocalOfObservations();

% re-initialized JIDT object with the same parameters used before
teCalc.initialise();

% pass the signals to the JIDT object in Y-X order
teCalc.setObservations(y_JIDT,x_JIDT);

% calculate TE_{y->x}
TE.TE_yx = teCalc.computeAverageLocalOfObservations();

% report TE
TE.D_TE = TE.TE_xy-TE.TE_yx;
XcY(1) = (TE.D_TE > 0);
YcX(1) = (TE.D_TE < 0);
if( TE.D_TE == 0 ), NoCI(1) = true; else NoCI(1) = false; end;

% clean the java stuff from memory
clear teCalc

if(verb),
    fprintf(' done. [%.15f]\n',toc);
end;

%% granger causality (using MVGC)

if( ~skipGC ),

if(verb)
    fprintf('Calculating granger causality ...');
    tic;
end;

% run the start-up script
addpath('mvgc_v1.0');
quiet_startup;

% set some toolbox parameters
regmode   = '';  % VAR model estimation regression mode ('OLS', 'LWR' or empty for default)
icregmode = '';  % information criteria regression mode ('OLS', 'LWR' or empty for default)
morder    = 10;  % model order to use ('actual', 'AIC', 'BIC' or supplied numerical value)
momax     = 10;     % maximum model order for model order estimation
acmaxlags = [];   % maximum autocovariance lags (empty for automatic calculation)
fres      = [];     % frequency resolution (empty for automatic calculation)

% pack data 
XY_ts = [x;y];

% Calculate information criteria up to specified maximum model order.
[AIC,BIC,moAIC,moBIC] = tsdata_to_infocrit(XY_ts,momax,icregmode,false);

% Estimate VAR model of selected order from data.
[A,SIG] = tsdata_to_var(XY_ts,moBIC,regmode);

% Calculate the autocovariance sequence 
[G,info] = var_to_autocov(A,SIG,acmaxlags);

% Calculate time-domain pairwise-conditional causalities 
GC.F = autocov_to_pwcgc(G);

% Calculate spectral pairwise-conditional causalities 
GC.f = autocov_to_spwcgc(G,fres);

% Check that spectral causalities average (integrate) to time-domain
GC.Fint = smvgc_to_mvgc(GC.f); % integrate spectral MVGCs
GC.mad = maxabs(GC.F-GC.Fint);
GC.madthreshold = 1e-5;
if GC.mad < GC.madthreshold
    %fprintf('maximum absolute difference OK: = %.2e (< %.2e)\n',mad,madthreshold);
else
    fprintf(2,'WARNING: high maximum absolute difference = %e.2 (> %.2e)\n',GC.mad,GC.madthreshold);
end

% report GC
if( size(GC.F,1) ~= 0 && size(GC.F,2) ~= 0 )
    XcY(2) = (GC.F(2,1) > GC.F(1,2));
    YcX(2) = (GC.F(1,2) > GC.F(2,1));
    GC.diff = GC.F(2,1)-GC.F(1,2);
    if( GC.F(2,1) == GC.F(1,2) ), NoCI(2) = true; else NoCI(2) = false; end;
else
    GC.diff = NaN;
end;

if(verb),
    fprintf(' done. [%.15f]\n',toc);
end;

else
    GC = NaN;
end;
%% PAI

if(verb)
    fprintf('Calculating PAI ...');
    tic;
end;

% add path to executable
exec_dir = 'pai_exec';
addpath(exec_dir);

% set the embedding dimension
% E = 3;
% E = 5;

% set the delay vector lag time step
% tau = 1;

% create the input file for the C code        
tic;
CoutputfilenameXY = sprintf('%s/XYoutPAI.dat',exec_dir);
CinputfilenameXY = sprintf('%s/XYPAI_temp.dat',exec_dir);
fileID = fopen(CinputfilenameXY,'w');
for tstep = 1:1:length(x),
    fprintf(fileID,'%.20f,%.20f;\n',x(tstep),y(tstep));
end;
fclose(fileID);

% call the C code
tic;
CCommandString = sprintf('./%s/PAI -E %i -t %i -Ey 1 -ty 1 -L %i -f %s -n %i -o %s -eY tempeYout.dat -PAI',...
                              exec_dir,E,tau,length(x),CinputfilenameXY,1,...
                              CoutputfilenameXY);
[PAI.status,PAI.cmdout] = system(CCommandString);
RMCommandString = sprintf('rm %s',CinputfilenameXY);
system(RMCommandString);

% read the output file from the C codeand delete it        
tic;
fileID = fopen(CoutputfilenameXY,'r');
PAI.paiout = fscanf(fileID,'%f,%f,%f,%f');
fclose(fileID);
RMCommandString = sprintf('rm %s',CoutputfilenameXY);
system(RMCommandString);

% report PAI
PAI.diff = PAI.paiout(4,1)-PAI.paiout(2,1);
XcY(3) = (PAI.paiout(2,1) > PAI.paiout(4,1));
YcX(3) = (PAI.paiout(4,1) > PAI.paiout(2,1));
if( PAI.paiout(2,1) == PAI.paiout(4,1) ), NoCI(3) = true; else NoCI(3) = false; end;

if(verb),
    fprintf(' done. [%.15f]\n',toc);
end;

%% leaning

if(verb)
    fprintf('Calculating leaning ...');
    tic;
end;

% add path to scripts
addpath('leans_exec');

% set the lags to tested
%lags = 1:1:(floor(0.1*length(x)));

% set the x tolerance
%xtol = 0.1;

% set the y tolerance
%ytol = 0.1;

% find the leanings
L.leanings = nan(1,length(lags));
for lag_iter = 1:1:length(lags),
    leantemp = leans_lagged(x,y,xtol,ytol,lags(lag_iter));
    L.leanings(1,lag_iter) = leantemp(1,2);
end;

% report leanings
testlean = mean(L.leanings);
XcY(4) = (testlean > 0);
YcX(4) = (testlean < 0);
if( testlean == 0 ), NoCI(4) = true; else NoCI(4) = false; end;

L.testlean = testlean;

if(verb),
    fprintf(' done. [%.15f]\n',toc);
end;

%% lagged cross-correlations

if(verb)
    fprintf('Calculating lagged cross-correlation ...');
    tic;
end;

% set the lags (use the same as for the leaning calculation)
clags = lags;

% find the lagged cross-correlations
LCC.laggedcorrsXY = nan(1,length(clags));
LCC.laggedcorrsYX = nan(1,length(clags));
for clag_iter = 1:1:length(clags),
    LCC.laggedcorrsXY(1,clag_iter) = corr(x((clags(clag_iter)+1):end)',y(1:(end-clags(clag_iter)))');
    LCC.laggedcorrsYX(1,clag_iter) = corr(y((clags(clag_iter)+1):end)',x(1:(end-clags(clag_iter)))');
end;

% report correlations
LCC.Delta = abs(LCC.laggedcorrsXY)-abs(LCC.laggedcorrsYX);
testcorr = mean(LCC.Delta);
XcY(5) = (testcorr < 0);
YcX(5) = (testcorr > 0);
if( testcorr == 0 ), NoCI(5) = true; else NoCI(5) = false; end;

LCC.testcorr = testcorr;

if(verb),
    fprintf(' done. [%.15f]\n',toc);
end;

%% ECA guess vector

g = nan(1,5);
for giter = 1:1:5,
    if( XcY(giter) == 1 ),
        g(giter) = 0;
    elseif( YcX(giter) == 1 ),
        g(giter) = 1;
    elseif( NoCI(giter) == 1 ),
        g(giter) = 2;
    else
        g(giter) = NaN;
    end;
end;
    
    
    