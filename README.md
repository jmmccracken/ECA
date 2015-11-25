Exploratory Causal Analysis (ECA)
===

This collection of code is used to perform exploratory causal analysis with bivariate times series data.  The main script is the MATLAB script _ECA_ which is run as

    [TE,GC,PAI,L,LCC,g] = ECA(x,y,xtol,ytol,lags,E,tau,verb,skipGC)
    
where  _x_ and _y_ are 1 dimensional vectors of time series data, _xtol_, _ytol_, and _lags_ are parameters passed to the leaning functions (see https://github.com/jmmccracken/penchant), _E_ and _tau_ are parameters passed to the PAI functions (see https://github.com/jmmccracken/PAI), _verb_ is a flag to optionally surpress command line outputs, and _skipGC_ is a flag is optionally supress the Granger causality calculations.

_TE_ is an output struct containing the transfer entropy results calculated using the Java Information Dynamics Toolkit (JIDT) which is available at http://jlizier.github.io/jidt/ and introduced in doi:10.3389/frobt.2014.00011.

_GC_ is an output struct containing the Granger log-likelihood statistic calculations using the MVGC Multivariate Granger Causality Toolbox for MATLAB which is available at http://www.sussex.ac.uk/sackler/mvgc/ and introduced in doi:10.1016/j.jneumeth.2013.10.018.

_PAI_, _L_, and _LCC_ are output structs containing the PAI, leaning, and lagged cross-correlation calculations, respectively.  The output vector _g_ is the ECA summary vector described in [1].

The script _DMIninoExample_ produces two example ECA summary vectors using IOD and El Nino index data, and the script _WhistlerDailySnowfallExample\_plotting_ produces an ECA summary vector, along with several data plots, for snowfall data.  All the data files have individual README files that provide brief descriptions and sources.

The scripts use the many internal MATLAB functions and have not been tested on any open source MATLAB equivalents such as Octave or Scilab.  The PAI binary called by _ECA_ may need to be recomplied, which can be done following the instructions at https://github.com/jmmccracken/PAI.

This code has been tested on Ubuntu 13.10 with kernel version 3.13.0-68-generic x86_64 x86_64 x86_64 GNU/Linux with Matlab 7.9.1.671 (R2009b) Service Pack 1 64-bit (glnxa64).

Test by executing `DMIninoExample` and `WhistlerDailySnowfallExample_plotting`

You may need to compile PAI
```
git clone https://github.com/jmmccracken/PAI.git
cd PAI
make
cp PAI ../ECA/pai_exec
```

(If PAI call fails, see note in ECA.m about library linking.)

[1] reference pending
