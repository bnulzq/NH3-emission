### Plot: figure drawing

Code used in the figure plotting:

1. `fig_chem_no2_so2_mean.m`: joint the figures of so2 burden and no2 burden into one figure.
2. `fig_comparison_model_iasi_validation.m`: joint the validation maps of modelled NH3 concentrations comparison with IASI observation into one figure.
3. `fig_concentration_iasi_chem_mean_trend.m`: joint the maps of NH3 concentrations mean and trend from IASI and GEOS-Chem.
4. `fig_emission_prior_optimized_mean_trend.m`: joint the maps of NH3 emission mean and trend from adjusted and GEOS-Chem.
5. `fig_r_emi_trans_dep_mean.m`: joint the maps of ratio of transport(-) to deposition and transport(+) to emisssion.
6. `fig_uncertainty_sensitivity_emi.m`: plot the maps of uincertainty and sensitivity for MH3 emission over 2008-2018.
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
50. `map_Chem_annual_mean.m`: draw annnual mean spatial distribution of GEOS-Chem simuilation.
51. `map_Chem_budget_mean.m`: draw mean spatial distribution of GEOS-Chem Budget.
52. `map_chem_emission_mean.m`: draw mean spatial distribution of GEOS-Chem emissions (HEMCO_diagnostics_NH3).
53. `map_Chem_lifetime_mean.m`: draw mean spatial distribution of GEOS-Chem lifetime (τ).
54. `map_Chem_mean.m`: mean spatial distribution of GEOS-Chem simuilation.
55. `map_Chem_monthly_trend.m`: draw monthly trend spatial distribution of GEOS-Chem simulation.
56. `map_Chem_seasonal_mean.m`: draw seasonal mean spatial distribution of GEOS-Chem simuilation.
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
75. `map_IASI_annual_mean.m`: draw annnual mean spatial distribution of IASI NH3 concentration.
76. `map_IASI_Chem_mean_diff_seasonal.m`: draw seasonal mean  spatial distribution of NH3 concentration difference between GEOS-Chem simuilation and IASI. 
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
