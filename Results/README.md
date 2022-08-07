## Data Description

The dataset ia produced based on the Infrared Atmospheric Sounding Interferometer (IASI) observations in Luo et al.,(2022), by updating the prior ammonia (NH3) emission fluxes with the ratio between biases in simulated NH3 concentrations and effective NH3 lifetimes against the loss of the NHx family (NHx $\equiv$ NH3 + $NH_4^+$). We then include sulfur dioxide (SO2) column to correct the NH3 emission trends over India and China, where SO2 emissions have changed rapidly in recent years. Finally, we quantify the uncertainty of NH3 emission by a series of perturbation and sensitivity experiments. The GEOS-Chem simulation driven by top-down estimates has lower bias with the IASI observations than prior emissions, demonstrating the consistency of our estimates with observations.

## Metadata

Spatial resolution: $4^\circ \times5^\circ$

Spatial range: 

* Latitude: $70^\circ S -- 70^\circ N$
* Longitude: $-180^\circ -- \ 180^\circ$
  
Temporal resolution: monthly

Layers:

* TDE: NH3 top-down emission (TDE) estimate
* BUE: NH3 bottom-up emission (BUE) inventory
* NH3_obs: observed NH3 column density
* NH3_mod: simulated NH3 column density
* NH3_lifetime: NH3 lifetime

Fill value: NaN

A mask is applied to non-land area, i.e., the grids that fraction of land < 0.2.

## Known Caveat

Our dataset excludes grid cells with the number of successful retrievals less than 800 in a month, and grids where transport dominates over local prior emissions or depositions in the monthly NHx budget. Caution is needed when analyzing the long-term average/trend of NH3 emission with the missing values. Proper gap-filling procedure is recommended before any long-term analysis.

Note that NH3 emission is produced based on our best knowledge. We welcome users's test, diagnoses, and feedback for this dataset so that we can keep improving it.

## Contact

Dr. Yuzhong Zhang (zhangyuzhong@westlake.edu.cn) and Zhenqi Luo (zl725@cornell.edu)

## Citation

Zhenqi Luo, & Yuzhong Zhang. (2022). Estimating global ammonia (NH3) emissions based on IASI observations from 2008 to 2018 (1.0.0) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.6969734
