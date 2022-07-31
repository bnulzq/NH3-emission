### Data: data processing

Code used in the data processing:

1. `data_check.py`: check the missing file of the IASI daily datasets, used in [*IASI/daily*](#IASI).
2. `data_colormap.py`: export the colormap in Python, output in [*colormap*](#colormap).
3. `data_download_era5.py`: export the command of downloading IASI daily data, output in [*IASI/daily*](#IASI).
4. `data_filter_IASI_daily.py`: filter the IASI daily concentration data by cloud fraction and skin temperature data, output in [*IASI/IASI_filter*](#IASI).
5. `data_results_to_nc.m`: export the NH3 emission results, output in [*Results*](#Results).
6. `pre_bpch_to_nc.py`: convert the individual bpch file to nc, output in [*GEOS-Chem*](#GEOS-Chem).
7. `pre_ceds_sectors.py`: extract the CEDS data (nc format), output in [*CEDS*](#CEDS).
8. `pre_CEDS_to_nc.py`: extract the national NH3 emissions from CEDS to nc, output in [*CEDS*](#CEDS).
9. `pre_emission_to_nc.py`: extract the NH3 emissions from HEMCO to nc, output in [*GEOS-Chem*](#GEOS-Chem).
10. `pre_FAO_N_fertilizer_use.py`: extract the national N fertilizer use to nc, output in [*FAO*](#FAO).
11. `pre_FAO_N_manure.py`: extract the national N manure management to nc, output in [*FAO*](#FAO).
12. `pre_ground_AMoN_NH3.py`/`pre_ground_EANET_NH3.py`/`pre_ground_EMEP_NH3`: extract the groud based (EMEP, EANET, AMoN) NH3 to csv file, output in [*Ground*](#Ground).
13. `submit.filter.geos`: submit the GEOS-Chem simulation task.
