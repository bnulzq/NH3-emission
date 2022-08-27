# NH3-emission

**NH3-emission** is a Github repository that composes of results, data, code, PPT, and some references. It can be found at Github: [https://github.com/bnulzq/NH3-emission.git](https://github.com/bnulzq/NH3-emission.git) and Zenodo: [https://doi.org/10.5281/zenodo.6965444](https://doi.org/10.5281/zenodo.6965444).

The work of *Estimating global ammonia (NH3) emissions based on IASI observations from 2008 to 2018* is published on ACP, and this project is ongoing to improve our NH3 emission estimates. The work progress is presented in the folder [*PPT*](#ppt), the correspond scripts are in the folder [*Code*](#code), some references are in the folder [*Ref*](#ref) and part of the data are in the folder [*Data*](#data). Most of work is done when I visited the Atmospheric Environmental Research Lab of the Westlake University, as I leaved and published our paper, I sorted out some relevant items and wrote this **README** document.

To learn more about my work, check out the [**Estimating global ammonia (NH3) emissions based on IASI observations from 2008 to 2018**](
https://doi.org/10.5194/acp-22-10375-2022) and please feel free to contact me by zl725@cornell.edu.

## Table of Contents

**[Code](#code)**

**[Data](#data)**

**[PPT](#ppt)**

**[Ref](#ref)**

**[Results](#results)**

**[Next Steps, Credits, Feedback, License](#next-steps-credits-feedback-license)**

**[Reference](#reference)**

## Code

### Calculation: data calculation

Code used in the data calculation:

1. `cal_column_concentration.py`: calculate the total column concentration of simulated NH3, output in [*GEOS-Chem*](#geos-chem).
2. `cal_GFAS_emi.m`: calculate annual mean of the NH3 emissions in GFAS (0.1°×0.1°), used in [*GFAS*](#gfas).
3. `cal_IASI_01_emission_12h.m`: calculate the IASI (0.01°×0.01°) emissions by fixed lifetime (12h), used in [*IASI*](#iasi).
4. `cal_mod_t.m`: calculate the lifetime (𝜏) of NH3 from GEOS-Chem NH3 total column concentration and the total deposition fluxes.
5. `cal_OMPS_SO2.m`: % calculate the OMPS (1°×1°) SO2 concentrations, used in [*SO2*](#so2).
6. `cal_opt_chem_emission.m`: calculate the annual averaged emission of prior and optimization with uncertainty and sensitivity (without ocean), output in [*Results*](#results).
7. `cal_SO2_trend_regional.m`: calculate the trend of simulated SO2 concentrations, used in [*GEOS-Chem*](#geos-chem).
8. `cal_uncertainty_IASI.m`: calculate the uncertainty of IASI concentrations to emission results.
9. `cal_uncertainty_lifetime.m`: calculate the uncertainty of modelled lifetime to emission results, has been written into Code **6**.
10. `cal_uncertainty_number.m`: calculate the uncertainty of number of retrievals to emission results, has been written into Code **6**.
11. `cal_uncertainty_trans_emi_r.m`: calculate the uncertainty of transportation/emission ratio to emission results, has been written into Code **6**.
12. `cal_validation_model_ground.py`: calculate the validation of model simulations against ground-based observations, output in [*Results*](#results).
13. `map_IASI_emi_filter_n_est2.m`: calculate mean spatial distribution of IASI emissions, output in [*Results*](#results).
14. `map_lifetime_nh3.m`: calculate mean spatial distribution of GEOS-Chem lifetime (NH3), output in [*GEOS-Chem*](#geos-chem).
15. `map_niko_nh3_emi_mean.m`: calculate mean spatial distribution of NH3 emissions from Nikolaos over 2008-2016, output in [*Nikolaos*](#nikolaos).

### Data: data processing

Code used in the data processing:

1. `data_check.py`: check the missing file of the IASI daily datasets, used in [*IASI*](#iasi).
2. `data_colormap.py`: export the colormap in Python, output in [*Colormap*](#colormap).
3. `data_download_era5.py`: export the command of downloading IASI daily data, output in [*IASI/daily*](#iasi).
4. `data_filter_IASI_daily.py`: filter the IASI daily concentration data by cloud fraction and skin temperature data, output in [*IASI*](#iasi).
5. `data_results_to_nc.m`: export the NH3 emission results, output in [*Results*](#results).
6. `pre_bpch_to_nc.py`: convert the individual bpch file to nc, output in [*GEOS-Chem*](#geos-chem).
7. `pre_ceds_sectors.py`: extract the CEDS data (nc format), output in [*CEDS*](#ceds).
8. `pre_CEDS_to_nc.py`: extract the national NH3 emissions from CEDS to nc, output in [*CEDS*](#ceds).
9. `pre_emission_to_nc.py`: extract the NH3 emissions from HEMCO to nc, output in [*GEOS-Chem*](#geos-chem).
10. `pre_FAO_N_fertilizer_use.py`: extract the national N fertilizer use to nc, output in [*FAO*](#fao).
11. `pre_FAO_N_manure.py`: extract the national N manure management to nc, output in [*FAO*](#fao).
12. `pre_ground_AMoN_NH3.py`/`pre_ground_EANET_NH3.py`/`pre_ground_EMEP_NH3`: extract the ground based (EMEP, EANET, AMoN) NH3 to csv file, output in [*Ground*](#ground).
13. `submit.filter.geos`: submit the GEOS-Chem simulation task.

### Plot: figure drawing

Code used in the figure plotting:

1. `fig_chem_no2_so2_mean.m`: joint the figures of so2 burden and no2 burden into one figure.
2. `fig_comparison_model_iasi_validation.m`: joint the validation maps of modelled NH3 concentrations comparison with IASI observation into one figure.
3. `fig_concentration_iasi_chem_mean_trend.m`: joint the maps of NH3 concentrations mean and trend from IASI and GEOS-Chem.
4. `fig_emission_prior_optimized_mean_trend.m`: joint the maps of NH3 emission mean and trend from adjusted and GEOS-Chem.
5. `fig_r_emi_trans_dep_mean.m`: joint the maps of ratio of transport(-) to deposition and transport(+) to emission.
6. `fig_uncertainty_sensitivity_emi.m`: plot the maps of uncertainty and sensitivity for MH3 emission over 2008-2018.
7. `fig_validation_ground_simulation.m`: joint the validation maps of modelled NH3 concentrations comparison with IASI observation.
8. `figure_bar_agr_emi_region.py`: draw mean NH3 fertilizer and manure emissions from FAOSTAT over different regions.
9. `figure_bar_ch4_livestock_regional.py`: draw mean CH4 livestock emissions over different regions.
10. `figure_change_life&emission_regional.py`: draw regional monthly timeseries of NH3 lifetime (M/E and M/L) and emissions (IASI and GEOS-Chem).
11. `figure_compare_emission_IASI(unfixed t)_Chem.py`: draw comparison of adjusted and GEOS-Chem emissions.
12. `figure_compare_IASI_Chem.py`: draw comparison of seasonal IASI and GEOS-Chem simulated concentrations.
13. `figure_fill_uncertainty_emi_monthly.py`: draw monthly timeseries of NH3 emissions uncertainty over different region
14. `figure_hist_emi_proportion.py`: draw adjusted/GEOS-Chem NH3 emissions proportion of data quantity over different region
15. `figure_pcolor_n_retrieval_month.py`: draw data coverage of number of retrievals binned by latitude, with one-month bin.
16. `figure_pcolor_n_retrieval_regional_day.py`: draw regional data coverage of number of retrievals binned over several months, with one-day bin.
17. `figure_pdf_IASI_Chem.py`: draw PDF of seasonal IASI and GEOS-Chem simulated concentrations.
18. `figure_plot&bar_regional_monthly_mean.py`: draw monthly NH3 concentration mean over different region in GEOS-Chem and IASI (with Ocean background).
19. `figure_plot_agri_emi.py`: draw monthly timeseries of NH3 agriculture emissions (GEOS-Chem and CEDS 2 versions) and their proportions.
20. `figure_plot_bar_compare_emi.py`: draw comparison of adjusted NH3 emission results with results from other literature.
21. `figure_plot_change_lifetime&emission.py`: draw monthly timeseries of NH3 lifetime (M/E and M/L) and emissions.
22. `figure_plot_emi_so2_no2_timeseries_region.py`: draw GEOS-Chem prior emission of SO2, NO2, NH3 emissions change (trend) over different region.
23. `figure_plot_emi_timeseries_region_trend.py`: draw adjusted NH3 emission results of change (trend) over different region, with adjust trend for EC and IP.
24. `figure_plot_emi_trend_regional_prop.py`: draw adjusted NH3 emissions change (trend) by sectors over different region.
25. `figure_plot_FAO_man_fer_regional_trend.py`：draw NH3 fertilizer and manure emissions trends from FAOSTAT over different regions.
26. `figure_plot_lifetime_nh3&nh4.py`: draw monthly timeseries of NH3 lifetime (NH3 and NH4).
27. `figure_plot_monthly_emi_regional.py`: draw mean monthly NH3 emissions variations from GEOS-Chem prior and adjusted over.different region.
28. `figure_plot_N_agr_use_region_trend.py`: draw agriculture N use change (trend) over different region.
29. `figure_plot_N_manure_region_trend.py`: draw agriculture N manure (trend) over different region.
30. `figure_plot_region_change.py`: draw annual NH3 concentration change over different region in GEOS-Chem/IASI.
31. `figure_plot_sox_regional.py`: draw simulated SO2, SO4, SO4s concentration (trend) over EC and IP.
32. `figure_point_emi_monthly_proportion.py`: draw adjusted and GEOS-Chem NH3 emissions proportion of data quantity over different region in monthly variation.
33. `figure_point_emi_monthly_trend_region.py`: draw adjusted NH3 emissions monthly trend over different region.
34. `figure_scatter_emi_regional.py`: draw scatters of NH3 emissions from GEOS-Chem and adjusted over different regions.
35. `figure_scatter_emission_opt_chem_div_region.py`: draw comparison of adjusted and GEOS-Chem emissions divided by sub-regions.
36. `figure_scatter_ground_simulation.py`: draw comparison of ground-based NH3 measurements with GEOS-Chem simulation (validation).
37. `figure_scatter_IASI_GEOS-Chem.py`: draw NH3 concentration comparison of IASI with GEOS-Chem (validation).
38. `figure_scatter_IASI_Van.py`: draw IASI NH3 concentration comparison of ours with Van Dammes.
39. `figure_stackBar_emi_regional.py`: draw seasonal NH3 emissions mean from GEOS-Chem and adjusted over different region.
40. `figure_Stackplots_emi_chem_region.py`: draw annual GEOS-Chem NH3 emissions sectors change (trend) over different region.
41. `figure_plot_percent_grid_remove_TDE.py`: draw the monthly percentage of removed grid cells in filtering over different regions.
42. `map_burden_no2_mean.m`: draw mean spatial distribution of NO2 burden from GEOS-Chem simulations.
43. `map_burden_so2_mean.m`: draw mean spatial distribution of SO2 burden from GEOS-Chem simulations.
44. `map_CEDS_agri_mean_v2.m`: draw mean spatial distribution of CEDS Agriculture emissions in proportion.
45. `map_CEDS_mean.m`: draw mean spatial distribution of CEDS total emissions.
46. `map_CEDS_ratio_mean.m`: draw mean spatial distribution of CEDS emissions ratios.
47. `map_CH4_livestock_mean.m`: draw mean spatial distribution of CH4 emission flux from livestock sources.
48. `map_CH4_livestock_trend.m`: draw trend spatial distribution of CH4 emission flux from livestock sources.
49. `map_chem_agri_mean.m`: draw mean spatial distribution of GEOS-Chem Agriculture emissions.
50. `map_Chem_annual_mean.m`: draw annual mean spatial distribution of GEOS-Chem simulation.
51. `map_Chem_budget_mean.m`: draw mean spatial distribution of GEOS-Chem Budget.
52. `map_chem_emission_mean.m`: draw mean spatial distribution of GEOS-Chem emissions (HEMCO_diagnostics_NH3).
53. `map_Chem_lifetime_mean.m`: draw mean spatial distribution of GEOS-Chem lifetime (τ).
54. `map_Chem_mean.m`: mean spatial distribution of GEOS-Chem simulation.
55. `map_Chem_monthly_trend.m`: draw monthly trend spatial distribution of GEOS-Chem simulation.
56. `map_Chem_seasonal_mean.m`: draw seasonal mean spatial distribution of GEOS-Chem simulation.
57. `map_Chem_seasonal_trend.m`: draw seasonal trend spatial distribution of GEOS-Chem simulation.
58. `map_chem_t.m`: draw  mean spatial distribution of GEOS-Chem τ.
59. `map_corr_diff_emission.m`: draw spatial correlations between seasonal mean difference of IASI and GEOS-Chem.
60. `map_delta_emi_IASI_Chem_mean.m`: draw mean spatial distribution of NH3 emission difference between GEOS-Chem and adjusted.
61. `map_delta_IASI_Chem_mean.m`: draw mean spatial distribution of NH3 concentration difference between IASI and GEOS-Chem.
62. `map_delta_IASI_Chem_relative_mean.m`: draw mean spatial distribution of relative NH3 concentration difference between IASI and GEOS-Chem.
63. `map_diff_ch4_livestock_mean.m`: draw mean spatial distribution of CH4 emission difference from prior and posterior livestock sources.
64. `map_diff_emi_mean_regional.m`: draw mean NH3 emission difference between adjusted and GEOS-Chem monthly data.
65. `map_diff_emi_sector.m`: draw distribution of NH3 emissions difference of GEOS-Chem and adjusted over different sectors.
66. `map_diff_IASI_Chem_emi_seasonal_mean.m`: draw spatial distribution of seasonal emissions mean difference GEOS-Chem and adjusted.
67. `map_diff_IASI_Chem_MFB.m`: draw spatial distribution of concentration mean difference in MFB between IASI and GEOS-Chem (validation). 
68. `map_diff_IASI_Damme.m`: draw mean spatial distribution of IASI concentration difference with Van Dammes's.
69. `map_emi_month_region.m`: draw mean spatial distribution of GEOS-Chem and adjusted regional emissions over months.
70. `map_emi_opt_trend_regional.m`: draw regional trend of adjusted emission.
71. `map_emi_trend.m`: draw trend spatial distribution of adjusted emissions. 
72. `map_emission_season_mean.m`: draw seasonal mean spatial distribution of GEOS-Chem NH3 emissions.
73. `map_emission_season_trend.m`: draw seasonal trend spatial distribution of GEOS-Chem NH3 emissions.
74. `map_IASI_01.m`: draw mean spatial distribution of Van Dammes's IASI (0.01°×0.01°) NH3 concentration over 2008-2016.
75. `map_IASI_annual_mean.m`: draw annual mean spatial distribution of IASI NH3 concentration.
76. `map_IASI_Chem_mean_diff_seasonal.m`: draw seasonal mean  spatial distribution of NH3 concentration difference between GEOS-Chem simulation and IASI. 
77. `map_iasi_chem_mean_regional.m`: draw regional mean difference between IASI and GEOS-Chem monthly data.
78. `map_iasi_chem_trend_regional.m`: draw regional trend difference between IASI and GEOS-Chem monthly data.
79. `map_IASI_daily_retrieval_n_monthly_mean.m`: draw monthly mean spatial distribution of number of retrievals for IASI.
80. `map_IASI_emission_mean.m`: draw mean spatial distribution of NH3 emissions using fixed lifetime.
81. `map_IASI_mean_4x5.m`: draw mean spatial distribution of IASI.
82. `map_IASI_mean_seasonal_filter.m`: draw seasonal mean spatial distribution of IASI daily filtered/unfiltered data.
83. `map_IASI_monthly_trend.m`: draw monthly trend spatial distribution of IASI daily filtered data.
84. `map_IASI_trend_seasonal_filter.m`: seasonal trend spatial distribution of IASI daily filtered data.
85. `map_K_NH4_NH3_mean.m`: draw mean spatial distribution of GEOS-Chem K (NH4/NH3) in ammonia-water equilibrium.
86. `map_lifetime_nh3_mean.m`: draw mean spatial distribution of GEOS-Chem lifetime (nh3).
87. `map_r_IASI_Chem_emi_mean.m`: draw seasonal mean ratio spatial distribution of GEOS-Chem and IASI adjusted emissions.
88. `map_r_transport_emi_mean.m`: draw mean spatial distribution of ratio of transport(+) to emission.
89. `map_r_transport_loss_mean.m`: draw mean spatial distribution of ratio of transport(-) to loss.
90. `map_skt_mean.m`: draw mean spatial distribution of ERA5 skin temperature.
91. `map_uncertainty_iasi.m`: draw mean uncertainty spatial distribution of IASI daily filtered data.
92. `map_uncertainty_iasi_emi.m`: draw mean uncertainty spatial distribution of emission based on IASI relative error.
93. `table_ch4_livestock_trend_regional.py`: visualize mean and trend CH4 livestock emissions over different regions.

### Function: self-defined function

Code used in the self-defined functions:

1. `country`: boundary of the countries.
2. `m_map`: Matlab map function.
3. `Domain.m`: assign values to specific domain.
4. `Extract_season_year.m`: convert monthly data into seasonal data.
5. `MapReclass.m`: reclass the land cover class of the map.
6. `MaskOcean_1x1.m`/`MaskOcean_4x5.m`: mask the ocean grids into 1x1/4x5 deg grid cells.
7. `R2.m`: compute the correlation coefficient of two datasets.
8. `Regrid4x5.m`: regrid the data into 4x5 deg grid cells.
9. `Trend.m`: calculate the trend values of the datasets.

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

## PPT

The progress and meeting of the project, including some results and literature.

### Group meeting

PPT used in the group meeting presentation:

1. **10.30**: study of N2O emission, including sources and bomas in Africa.
2. **11.19**：study of estimating the global satellite-derived surface NH3 concentration.
3. **12.10**: study of NH3 trend in Africa.
4. **12.17**: study of NH3 from Lake Natron.
5. **1.7**: results and study of global NH3 concentrations and emissions.
6. **1.22**: results of NH3 emissions on lifetime, study of NH3 emission from agriculture.
7. **3.17**: results of regional NH3 emission, study of NO2 burden reductions over Africa.
8. **4.16**: results of NH3 emission on budget thresholds, study of anthropogenic emissions.
9. **5.13**: results of NH3 emission over US, study of NH3 emissions over India and China.
10. **6.11**: study of NH3 concentration validation and trend. 

### Progress

PPT used in the 1:1 meeting presentation:

1. **knowle_nitrogen_cycle**: Knowledge ofv the Nitrogen Cycle.
2. **method**: equations used in the study.
3. **2020.9.27**：spatial distributions and timeseries of IASI NH3 concentrations data, and literature of NH3 concentration over global and US.
4. **2020.11**: continuation of the last item, and add GEOS-Chem NH3 concentrations output and literature of N emissions.
5. **2020.11.16**: continuation of the last item, and add total column concentration of GEOS-Chem output.
6. **2020.11.19**: continuation of the last item, and add seasonal mean and trend of GEOS-Chem output and add the literature of IASI NH3.
7. **2020.11.26**: continuation of the last item, and add comparison of GEOS-Chem and IASI and literature of IASI/GEOS-Chem NH3.
8. **2020.12**: continuation of the last item, and add filter IASI daily data and literature of IASI NH3 over US and Africa.
9. **2020.12.1**: continuation of the last item, and add seasonal NH3 emission.
10. **2020.12.10**: continuation of the last item, and add annual concentration change over the India-China, Africa and South America.
11. **2020.12.18**: continuation of the last item, and add spatial difference and correlations between different sectors.
12. **2020.12.29**: continuation of the last item, and add IASI/GEOS-Chem emission comparison.
13. **2021.1**: continuation of the last item, and update the IASI emission and literature of global NH3 emission.
14. **2021.1.25**: continuation of the last item, and update the IASI emission and literature of global NH3 emission.
15. **2021.1.27**: continuation of the last item, and add NH3 lifetime.
16. **2021.4.28**: continuation of the last item, and add uncertainty analysis.
17. **2021.5.8**: continuation of the last item, and add the diagram and the flowchart.
18. **2021.5.12**: continuation of the last item, and add the FAOSTAT N.
19. **2021.8.18-Final**: continuation of the last item, and add the regional NH3 emission.

## Results

### Data Description

The dataset ia produced based on the Infrared Atmospheric Sounding Interferometer (IASI) observations in Luo et al.,(2022), by updating the prior ammonia (NH3) emission fluxes with the ratio between biases in simulated NH3 concentrations and effective NH3 lifetimes against the loss of the NHx family (NHx $\equiv$ NH3 + $NH_4^+$). We then include sulfur dioxide (SO2) column to correct the NH3 emission trends over India and China, where SO2 emissions have changed rapidly in recent years. Finally, we quantify the uncertainty of NH3 emission by a series of perturbation and sensitivity experiments. The GEOS-Chem simulation driven by top-down estimates has lower bias with the IASI observations than prior emissions, demonstrating the consistency of our estimates with observations.

### Metadata

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

### Known Caveat

Our dataset excludes grid cells with the number of successful retrievals less than 800 in a month, and grids where transport dominates over local prior emissions or depositions in the monthly NHx budget. Caution is needed when analyzing the long-term average/trend of NH3 emission with the missing values. Proper gap-filling procedure is recommended before any long-term analysis.

Note that NH3 emission is produced based on our best knowledge. We welcome users's test, diagnoses, and feedback for this dataset so that we can keep improving it.

### Contact

Dr. Yuzhong Zhang (zhangyuzhong@westlake.edu.cn) and Zhenqi Luo (zl725@cornell.edu)

### Citation

Zhenqi Luo, & Yuzhong Zhang. (2022). Estimating global ammonia (NH3) emissions based on IASI observations from 2008 to 2018 (1.0.0) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.6969734

## Next Steps, Credits, Feedback, License

### Next steps

See the [**PPT**](#ppt) files, all figures, accomplishment, data, and future plan in them.

Feel free to contact and discuss with me if what you want is not already there. If you would prefer a less formal approach to talk to me, add the Wechat: *bnulzq*.

It also takes a fair bit of work to study further with the NH3 emission, including more satellite for SO2 concentration and explore if the NH3 emission could be improved especially over important source regions (e.g., China, India etc.).

### Feedback

All bugs, feature requests, pull requests, feedback, etc., are welcome. Or send me by Email: [zl725@cornell.edu](<zl725@cornell.edu>).

### Credits

This ongoing project was studied by Zhenqi Luo for around one year (2020.9-2021.7) as a visiting student at the Westlake University.

This README was written by Zhenqi Luo in Summer, 2022 at Ithaca, NY.

### License 

MIT License

Copyright (c) 2022 bnulzq

## Reference

Evangeliou, N., Balkanski, Y., Eckhardt, S., Cozic, A., Van Damme, M., Coheur, P.-F., Clarisse, L., Shephard, M. W., Cady-Pereira, K. E., and Hauglustaine, D.: 10-year satellite-constrained fluxes of ammonia improve performance of chemistry transport models, Atmospheric Chemistry and Physics, 21, 4431-4451, 10.5194/acp-21-4431-2021, 2021.

Van Damme, M., Clarisse, L., Whitburn, S., Hadji-Lazaro, J., Hurtmans, D., Clerbaux, C., and Coheur, P. F.: Industrial and agricultural ammonia point sources exposed, Nature, 564, 99-103, 10.1038/s41586-018-0747-1, 2018.

Wang, Y. and Wang, J.: Tropospheric SO2 and NO2 in 2012–2018: Contrasting views of two sensors (OMI and OMPS) from space, Atmospheric Environment, 223, 10.1016/j.atmosenv.2019.117214, 2020.
