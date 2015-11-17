
% load X and Y
[t_DMI,DMI] = DipoleModeIndex();
[t_nino3,nino3] = Nino3Index();
[t_nino4,nino4] = Nino4Index();

% set liblength for plotting
liblength = length(t_DMI);

% subset the NINO data
NINO3_startidx = (t_DMI(1,1)-t_nino3(1,1))*12+1;
NINO3_stopidx = NINO3_startidx+length(t_DMI)-1;
t_nino3_trimmed = t_nino3(1,NINO3_startidx:NINO3_stopidx);
nino3_trimmed = nino3(1,NINO3_startidx:NINO3_stopidx);

NINO4_startidx = (t_DMI(1,1)-t_nino4(1,1))*12+1;
NINO4_stopidx = NINO4_startidx+length(t_DMI)-1;
t_nino4_trimmed = t_nino4(1,NINO4_startidx:NINO4_stopidx);
nino4_trimmed = nino3(1,NINO4_startidx:NINO4_stopidx);

% parameter settings
LCClags = 1:1:20;
DMItol = (max(DMI)-min(DMI))/4;
NINO3tol = (max(nino3_trimmed)-min(nino3_trimmed))/4;
NINO4tol = (max(nino4_trimmed)-min(nino4_trimmed))/4;
E = 100;
tau = 1;
verb = true;
skipGC = false;

% ECA
[TE_DMInino3,GC_DMInino3,PAI_DMInino3,L_DMInino3,LCC_DMInino3,g_DMInino3] =...
    ECA(DMI,nino3_trimmed,DMItol,NINO3tol,LCClags,E,tau,verb,skipGC);
[TE_DMInino4,GC_DMInino4,PAI_DMInino4,L_DMInino4,LCC_DMInino4,g_DMInino4] =...
    ECA(DMI,nino4_trimmed,DMItol,NINO4tol,LCClags,E,tau,verb,skipGC);
 
