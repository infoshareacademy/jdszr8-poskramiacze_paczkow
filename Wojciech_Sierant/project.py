
import pandas as pd
import sqlite3
import numpy as np
import matplotlib.pyplot as plt
import time
import math
from scipy import stats

con = sqlite3.connect("/home/wojciechsierant/Documents/projekt_python/database.sqlite")
torrents = pd.read_sql_query("select sum(t.totalSnatched) as totalSnatched, t.groupYear from torrents t group by t.groupYear order by t.groupYear DESC", con)
np_array = torrents.to_numpy()[0:,0]
print(torrents)
con.close()

torrents.plot(x ='groupYear', y='totalSnatched')



plt.show()
