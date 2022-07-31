'''export colormap'''

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
from matplotlib.colors import ListedColormap, LinearSegmentedColormap

name = 'OrRd'
cmp = cm.get_cmap(name, 256)
cmp = cmp(np.linspace(0,1,256))

np.savetxt('D:\\data\\colormap\\' + name + '.txt', cmp)
