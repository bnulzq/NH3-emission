### Calculation: data calculation

Code used in the data calculation:

1. `cal_column_concentration.py`: calculate thec total column concentration of simulated NH3, output in [*concentration_month*](#concentration_month).
2. `cal_GFAS_emi.m`: calculate annual mean of the NH3 emissions in GFAS (0.1°×0.1°), used in [*GFAS*](#GFAS).
3. `cal_IASI_01_emission_12h.m`: calculate the IASI (0.01°×0.01°) emissions by fixed lifetime (12h), used in [*ANNI-NH3*](#ANNI-NH3).
4. `cal_mod_t.m`: calculate the lifetime (𝜏) of NH3 from GEOS-Chem NH3 total column concentration and the total deposition fluxes.
5. `cal_OMPS_SO2.m`: % calculate the OMPS (1°×1°) SO2 concentrations, used in [*OMPS*](#OMPS).
6. `cal_opt_chem_emission.m`: calculate the annual averaged emission of prior and optimization with uncertainty and sensitivity (without ocean), output in [*Results*](#Results).
7. `cal_SO2_trend_regional.m`: calculate the trend of simulated SO2 concentrations, used in [*GEOS-Chem*](#GEOS-Chem).
8. `cal_uncertainty_IASI.m`: calculate the uncertainty of IASI concentrations to emission results
clear all, output in [*uncertainty*](#uncertainty).
9. `cal_uncertainty_lifetime.m`: calculate the uncertainty of modelled lifetime to emission results, has been written into Code **6**.
10. `cal_uncertainty_number.m`: calculate the uncertainty of number of retrievals to emission results, has been written into Code **6**.
11. `cal_uncertainty_trans_emi_r.m`: calculate the uncertainty of transportation/emission ratio to emission results, has been written into Code **x**.
12. `cal_validation_model_ground.py`: calculate the validation of model simulations against ground-based observations, output in [*Results*](#Results).
13. `map_IASI_emi_filter_n_est2.m`: calculate mean spatial distribution of IASI emissions, output in [*Results*](#Results).
14. `map_lifetime_nh3.m`: calculate mean spatial distribution of GEOS-Chem lifetime (NH3), output in [*Budget*](#Budget).
15. `map_niko_nh3_emi_mean.m`: calculate mean spatial distribution of NH3 emissions from Nikolaos over 2008-2016, output in [*Nikolaos*](#Nikolaos).

