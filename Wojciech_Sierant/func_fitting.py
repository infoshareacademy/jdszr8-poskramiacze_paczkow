import pandas as pd
import sqlite3
import numpy as np
import matplotlib.pyplot as plt
import time
import math
from scipy import stats

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

#rv = weibull_min(c=shp, loc=loc, scale=scl)

#data = rv.rvs(1000)
con = sqlite3.connect("/home/wojciechsierant/Documents/projekt_python/database.sqlite")
torrents = pd.read_sql_query("select sum(t.totalSnatched) as totalSnatched, t.groupYear from torrents t group by t.groupYear order by t.groupYear DESC", con)
data = torrents.to_numpy()
#print(data[1:5,])
con.close()

data = np.concatenate([[data[i, 1]]*int(data[i, 0]) for i in range(len(data))])
#print(len(data))
data = data[::10000]
#print(len(data))
# KS test for goodness of fit

def kstest(data, distname, paramtup):
    ks = stats.kstest(data, distname, paramtup, ksN)[0]   # return p-value
    return ks             # return p-value

# distribution fitter and call to KS test

def fitdist(data, dist):    
    fitted = dist.fit(data, floc=0.0)
    ks = kstest(data, dist.name, fitted)
    res = (dist.name, ks, *fitted)
    return res

# call fitting function for all distributions in list
res = [fitdist(data,D) for D in distributions]

# convert the fitted list of tuples to dataframe
pd.options.display.float_format = '{:,.3f}'.format
df = pd.DataFrame(res, columns=["distribution", "KS p-value", "param1", "param2", "param3", "param4", "param5"])
df["distobj"] = distributions
df.sort_values(by=["KS p-value"], inplace=True, ascending=False)
df.reset_index(inplace=True)
df.drop("index", axis=1, inplace=True)
print(df)

def plot_fitted_pdf(df):
    
    N = len(df)
    chrows = math.ceil(N/3)                    # how many rows of charts if 3 in a row
    #fig, ax = plt.subplots(chrows, 3, figsize=(20, 5 * chrows))
    fig, ax = plt.subplots(3)
    ax = ax.ravel()
    dfRV = pd.DataFrame()

    #for i in df.index:
    for i in range(3):
        # D_row = df.iloc[i,:-1]
        D_name = df.iloc[i,0]
        D = df.iloc[i,7]
        KSp = df.iloc[i,1]
        params = df.iloc[i,2:7]    
        params = [p for p in params if ~np.isnan(p)]

        # calibrate x-axis by finding the 1% and 99% quantiles in percent point function
        x = np.linspace(
                    D.ppf(0.01, *params), 
                    D.ppf(0.99, *params), 100)

        #fig, ax = plt.subplots(1, 1)
        # plot histogram of actual observations
        ax[i].hist(data, density=True, histtype='stepfilled', alpha=0.2)
        # plot fitted distribution
        rv = D(*params)
        title = f'pdf {D_name}, with p(KS): {KSp:.2f}' 
        #ax[i].plot(x, rv.pdf(x), 'r-', lw=2, label=title)
        ax[i].legend(loc="upper right", frameon=False)   
    plt.show() 

# from dataframe, select distributions with high KS p-value
df_ks = df.loc[df["KS p-value"] > ALPHA]
print(df_ks.shape)
print("Fitted Distributions with KS p-values > ALPHA:")
plot_fitted_pdf(df_ks)