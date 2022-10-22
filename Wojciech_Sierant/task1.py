import pandas as pd
import sqlite3
import numpy as np
import matplotlib.pyplot as plt
import time
import math
from scipy import stats
import seaborn as sns
from fitter import Fitter, get_common_distributions, get_distributions
import logging
logger = logging.getLogger(__name__)

ksN = 100           # Kolmogorov-Smirnov KS test for goodness of fit: samples
ALPHA = 0.05        # significance level for hypothesis test

from scipy.stats import (
    norm, beta, expon, gamma, genextreme, logistic, lognorm, triang, uniform, fatiguelife,            
    gengamma, gennorm, dweibull, dgamma, gumbel_r, powernorm, rayleigh, weibull_max, weibull_min, 
    laplace, alpha, genexpon, bradford, betaprime, burr, fisk, genpareto, hypsecant, 
    halfnorm, halflogistic, invgauss, invgamma, levy, loglaplace, loggamma, maxwell, 
    mielke, ncx2, ncf, nct, nakagami, pareto, lomax, powerlognorm, powerlaw, rice, 
    semicircular, trapezoid, rice, invweibull, foldnorm, foldcauchy, cosine, exponpow, 
    exponweib, wald, wrapcauchy, truncexpon, truncnorm, t, rdist
    )

distributions = [
    norm, beta, expon, gamma, genextreme, logistic, lognorm, triang, uniform, fatiguelife,            
    gengamma, gennorm, dweibull, dgamma, gumbel_r, powernorm, rayleigh, weibull_max, weibull_min, 
    laplace, alpha, genexpon, bradford, betaprime, burr, fisk, genpareto, hypsecant, 
    halfnorm, halflogistic, invgauss, invgamma, levy, loglaplace, loggamma, maxwell, 
    mielke, ncx2, ncf, nct, nakagami, pareto, lomax, powerlognorm, powerlaw, rice, 
    semicircular, trapezoid, rice, invweibull, foldnorm, foldcauchy, cosine, exponpow, 
    exponweib, wald, wrapcauchy, truncexpon, truncnorm, t, rdist
    ]


shp, loc, scl = 1.5, 0, 50000

rv = weibull_min(c=shp, loc=loc, scale=scl)
con = sqlite3.connect("/home/wojciechsierant/Documents/projekt_python/database.sqlite")
torrents = pd.read_sql_query("select sum(t.totalSnatched) as totalSnatched, t.groupYear from torrents t group by t.groupYear order by t.groupYear DESC", con)
data = torrents.to_numpy()
con.close()

data = np.concatenate([[data[i, 1]]*int(data[i, 0]) for i in range(len(data))])
#print(new_array)
data = data[::10000]

f = Fitter(data,
           distributions=['weibull',
                          'gamma',
                          'lognorm',
                          "beta",
                          "burr",
                          "norm"])
f.fit()
f.summary()