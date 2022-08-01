## Data

### CEDS

Available from CEDS, NH3 prior bottom-up emissions.

**Note**: Check the updated version of the datasets.

### CH4

Available from Dr. Yuzhong, posterior emissions and their trends from 2010 to 2018.

When using it, make sure to contact Dr. Yuzhong (zhangyuzhong@westlake.edu.cn) and acknowledge accordingly.

### Colormap

Colormaps used in the map converted from Python package.

### EDGAR

Available from EDGAR, anthropogenic emissions as BUE2. NH3 prior bottom-up emissions from 1970 to 2015.

**Note**: Check the updated version of the datasets.

### ERA5_skin_temperature

Available from ERA5. Daily skin temperature from 2008 to 2018.

### FAO

Available from http://www.fao.org/faostat.

#### N fertilizer use

Synthetic fertilizer, the information on agricultural use, production and trade of chemical and mineral fertilizers.

#### N manure

Livestock manure amount, the estimates of N inputs to agricultural soils from livestock manure.

### Fire

Available from GFED4 and GFAS from 2008 to 2015.

### GEOS-Chem

The GEOS-Chem CTM v12.9.3 (10.5281/zenodo.3974569) simulation output.

#### Budget

Computed NHx budget as the ratio of the simulated NH3 transport to the model input emission and simulated depositions.

#### Concentration

Computed monthly NH3 concentration from GEOS-Chem simulation outputs.

#### Emission

NH3 prior bottom-up emissions (BUE1). Anthropogenic emissions of simulated NH3 are taken from a global emission inventory CEDS, overridden by regional inventories in Canada (APEI), the United States (NEI-2011), Asia (MIX-Asia v1.1), and Africa (DICE-Africa). Fire emissions are from GFED4, and biogenic VOC emissions are from the MEGAN.

#### Lifetime

Computed lifetime as the ratio of the simulated NH3 column to the sum of simulated loss rate of the NHx family through the dry and wet depositions of NH3 and $NH_4^+$.

#### SOx

Computed SO2/SO4/SO4s concentration from GEOS-Chem simulation outputs.

#### Validation

GEOS-Chem simulations in selected years (2008, 2013, 2018) to examine the validation and consistency of NH3 emission estimates with the ground-based measurements and IASI observations. 

### Ground

Ground-based NH3 concentration measurements, Available from AMoN: https://nadp.slh.wisc.edu/networks/ammonia-monitoring-network/, EMEP: http://ebas-data.nilu.no/, and EANET: https://www.eanet.asia/.

**Note**: The units of datasets are different, you need to convert µg m^−3^ to ppbv (I use a factor of 1.44 assuming 25 ℃ temperature and 1 atmosphere pressure).

### IASI

The daily original and monthly filtering NH3 concentration data from 2008 to 2018.

#### ANNI-NH3

Available from https://doi.pangaea.de/10.1594/PANGAEA.894736. The 9-year (2008-2016) oversampled high-resolution (0.01°x0.01°) average map (Level 3) of the Level 2 data presented in [Van Damme et al. (2018)](https://www.nature.com/articles/s41586-018-0747-1).

### Daily

Available from https://iasi.aeris-data.fr/. 

When using it, make sure to contact Dr. Martin and ask cooperation.

**Note**: Check the updated version of the datasets.

### IASI_filter

Monthly filtered data by cloud fraction greater than 10 % and skin temperature below 263 K. 

### Map_iso3c

Provided by Dr. Yuzhong. The map of the countries and regions all over the world and their corresponding iso3c/iso3n codes.

**Note**: Check the updated version of the country boundary.

### Nikolaos

Available from Dr. Nikolaos Evangeliou from Norwegian Institute for Air Research. The monthly NH3 emission data from 2008 to 2017 based on top-down estimation presented in [Evangeliou et al., (2021)](https://doi.org/10.5194/acp-21-4431-2021).

When using it, make sure to contact Dr. Evangeliou and acknowledge accordingly.

### SO2

Available from Dr. Yi Wang from the University of Iowa. The monthly SO2 concentration data from 2012 to 2018 from OMI and OMPS sensors presented in [Wang and Wang, (2019)](https://doi.org/10.1016/j.atmosenv.2019.117214).

When using it, make sure to contact Dr. Wang and acknowledge accordingly.
