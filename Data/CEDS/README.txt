README -- Describes the CEDS_GBD-MAPS emission inventory (DOI: 10.5281/zenodo.3754964)
25 April 2020
Erin McDuffie
erin.mcduffie@dal.ca

ABOUT
CEDS_GBD-MAPS: Global Anthropogenic Emission Inventory of NOx, SO2, CO, NH3, NMVOCs, BC, and OC from 1970-2017
version tag: 2020_v1.0 (April 2020)
Annual anthropogenic emissions of 7 key atmospheric pollutants from 1970 - 2017, produced using the Community Emissions Data System, updated for the Global Burden of Disease Major Air Pollution Sources project (CEDS_GBD-MAPS).

************************************************************************************

SUMMARY

Emissions are provided for NOx, SO2, CO, NH3, NMVOCs, Black Carbon (BC), and Organic Carbon (OC) from 11 anthropogenic sectors and four fuel categories as both annual country totals and global gridded emission fluxes (0.5 x 0.5 degree resolution). 
Note: The CEDS_GBD-MAPS inventory does not include emissions from open fires or aircraft.

Sectors: 
1. Agriculture (non-combustion sources only, excludes open fires)
2. Energy (transformation and extraction)
3. Industry (combustion and non-combustion processes)
4. On-Road Transportation
5. Non-Road/Off-Road Transportation (rail, domestic navigation, other)
6. Residential Combustion
7. Commercial Combustion
8. Other Combustion
9. Solvent production and application
10. Waste (disposal and handling)
11. International Shipping (including VOCs from oil tanker loading/leakage)

Fuel Categories:
1. Total Coal Combustion (hard coal + brown coal + coal coke)
2. Solid Biofuel Combustion
3. Liquid Fuel (light oil + heavy oil + diesel oil) plus Natural Gas Combustion
4. CEDS Process Source Categories (see McDuffie, et al., (ESSD) 2020) for further details.
Note: Total anthropogenic emissions = the sum of fuel categories 1-4

************************************************************************************

GRIDDED DATA (CMIP Format)

The emissions from 1970 - 2017 are provided at monthly resolution, on a 0.5 degrees global grid with no more than 50-years per data file as per ESFG formatting conventions. 
The files are in netCDF4 (HDFv5) format with CF-compliant metadata. 
Data are in one variable, with sectors included as a dimension. 
Data are compliant with the CMIP6 file format, following the CEDSv2019-12-23 system
Note: These data include total anthropogenic emissions only and do not distinguish emissions from different fuel categories. 

The sectors in the netCDF files are: 
Dimension Sector  Description
0:		  AGR     Non-combustion agricultural sector
1:		  ENE	  Energy transformation and extraction
2:        IND     Industrial combustion and processes
3:        NRTR    Non-Road/Off-Road transportation (rail, domestic navigation, other)
4:        ROAD    On-Road transportation
5:        RCOR    Residential combustion
6:        RCOC    Commercial combustion
7:        RCOO    Other combustion
8:        SLV     Solvent production and application
9:        WST     Waste disposal and handling
10:       SHP     International shipping (including VOCs from oil tanker loading/leakage)

Within the netCDF files the sector ids are:
sector:ids = '0: Agriculture; 1: Energy; 2: Industrial; 3a: Non-Road/Other Transportation; 3b: Road Transportation; 4a: Residential; 4b: Commercial; 4c: Other; 5: Solvents production and application; 6: Waste; 7: International Shipping'
Note: The id numbers here do not correspond to the dimension number and are a legacy of the disaggregation here of the original CEDSv2019-12-23 aggregate sectors.

The variable names in the netCDF files are: 
Name					Size			Dimensions/Description   
lon						720x1			0.5 degree longitude
lat						360x1			0.5 degree latitude
sector					11x1			11 sectors
time					576x1			days since 1750-01-01 0:0:0 (12 months x 48 years)
[compound]_em_anthro  	720x360x11x576	gridded emission fluxes by sector and month

The gridded emissions incorporate a monthly seasonal cycle by sector, largely from the ECLIPSE project.

VOC speciation is provided at the 23 species resolution used in HTAP and RETRO (details below)

Filenames are in the following format:
[compound]-em-total-anthro_input4CMIP_emissions_CEDS-2020-v1_gn_197001-201712.nc
[compound] names are as follows:
BC
OC
NOx
CO
SO2
NH3

for NMVOCs, filenames are in the following format:
[voc-name]-em-speciated-VOC-total-anthro_input4CMIP_emissions_CEDS-2020v1-supplemental-data_gn_197001-201712.nc
[voc-names] are as follows:
VOC01-alcohols
VOC02-ethane
VOC03-propane
VOC04-butanes
VOC05-pentanes
VOC06-hexanes-pl
VOC07-ethene
VOC08-propene
VOC09-ethyne
VOC12-other-alke
VOC13-benzene
VOC14-toluene
VOC15-xylene
VOC16-trimethylb
VOC17-other-arom
VOC18-esters
VOC19-ethers
VOC20-chlorinate
VOC21-methanal
VOC22-other-alka
VOC23-ketones
VOC24-acids
VOC25-other-voc

Total Number of Files : 29 (1 per compound)

Emissions are provided in units of mass flux (kg m-2 s-1), as a monthly average flux, as noted in the netCDF files. Units are total mass of the indicated species as follows:
SO2: Mass flux of SOx, reported as SO2
NOx: Mass flux of NOx, reported as NO2
CO: Mass flux of CO
NH3 : Mass flux of NH3
BC : Mass flux of BC, reported as carbon mass (e.g., molecular weight 12)
OC: Mass flux of OC, reported as carbon mass (e.g., molecular weight 12)
VOC01-VOC25 : Mass flux of subVOC group (molecular weights in speciated VOC section below)

Note that total monthly emissions were converted to fluxes using a 365 day calendar. If your model uses a different calendar, you should ideally adjust fluxes such that the integrated annual fluxes are maintained. 

************************************************************************************

GRIDDED DATA (annual file format)

The emissions from 1970 - 2017 are provided at monthly resolution, on a 0.5 degree global grid, split into annual contributions.
The files are in netCDF4 (HDFv5) format with CF-compliant metadata. 
Data are split into sector contributions, with each sector as a variable. 
Data are formatted for input into the HEMCO emissions module for use in the GEOS-Chem 3D chemical transport model (http://acmg.seas.harvard.edu/geos/)
Note: These data include total anthropogenic emissions, split into contributions from different sectors and fuel categories. Emissions from each fuel are reported in separate files, while the sector contributions from these fuel types are provided as variables in each netCDF.

The fuel categories in the netCDF files are:
Fuel							Description
liquid-fuel-plus-natural-gas	Emissions from the combustion of liquid fuel (heavy oil + diesel oil + light oil) and natural gas
solid-biofuel					Emissions from the combustion of solid biofuel
total-coal						Emissions from the combustion of total coal (hard coal + brown coal + coal coke)
process							Emissions from all remaining CEDS 'process-level' sources (includes all non-combustion emissions)
**total-anthro					Total anthropogenic emissions (liquid-fuel-plus-natural-gas + solid-biofuel + total-coal + process)

** IMPORTANT NOTE: Use either the fuel-specific emission files OR the total-anthro emission files. DO NOT use emissions from the total-anthro files in combination with with 4 fuel-specific gridded files.

The sectors in the netCDF files are: 
Sector  Description
AGR     Non-combustion agricultural sector
ENE	  	Energy transformation and extraction
IND     Industrial combustion and processes
NRTR    Non-Road/Off-Road transportation (rail, domestic navigation, other)
ROAD    On-Road transportation
RCOR    Residential combustion
RCOC    Commercial combustion
RCOO    Other combustion
SLV     Solvent production and application
WST     Waste disposal and handling
SHP     International shipping (including VOCs from oil tanker loading/leakage)


The variable names in the netCDF files are: 
Name				Size			Dimensions/Description   
lon					720x1			0.5 degree longitude
lat					360x1			0.5 degree latitude
time				12x1			days since 1950-01-01 0:0:0 (12 months x 1 year)
[compound]_agr	  	720x360x12		gridded agr sectoral emission fluxes by month
[compound]_ene	  	720x360x12		gridded ene sectoral emission fluxes by month
[compound]_ind	  	720x360x12		gridded ind sectoral emission fluxes by month
[compound]_road	  	720x360x12		gridded road sectoral emission fluxes by month
[compound]_nrtr	  	720x360x12		gridded nrtr sectoral emission fluxes by month
[compound]_rcor	  	720x360x12		gridded rcor sectoral emission fluxes by month
[compound]_rcoc	  	720x360x12		gridded rcoc sectoral emission fluxes by month
[compound]_rcoo	  	720x360x12		gridded rcoo sectoral emission fluxes by month
[compound]_wst	  	720x360x12		gridded wst sectoral emission fluxes by month
[compound]_slv	  	720x360x12		gridded slv sectoral emission fluxes by month
[compound]_shp	  	720x360x12		gridded shp sectoral emission fluxes by month

The gridded emissions incorporate a monthly seasonal cycle by sector, largely from the ECLIPSE project.

VOC speciation is provided at the 23 species resolution used in HTAP and RETRO (details below)

File names are in the following format:
[compound]-em-[fuel]_CEDS_YYYY.nc

[compound] names are as follows:
ALD2
ALK4_butanes
ALK4_hexanes
ALK4_pentanes
BC
BENZ
BUTENE
C2H2
C2H4
C2H6
C3H8
CH2O
CHC
CO
EOH
ESTERS
ETHERS
HCOOH
MEK
NH3
NO
OC
OTHER_AROM
OTHER_VOC
PRPE
SO2
TBM
TOLU
XYLE

[fuel] names are listed above

Total Number of Files : 145 per year x 48 years

Emissions are provided in units of mass flux (kg m-2 s-1), as a monthly average flux, as noted in the netCDF files. Units are total mass of the indicated species as follows:
SO2: Mass flux of SOx, reported as SO2 
NOx: Mass flux of NOx, reported as NO
CO: Mass flux of CO
NH3 : Mass flux of NH3
BC : Mass flux of BC, reported as carbon mass (e.g., molecular weight 12)
OC: Mass flux of OC, reported as carbon mass (e.g., molecular weight 12)
subVOCs : Mass flux of subVOC group (molecular weights in speciated VOC section below)

Note that total monthly emissions were converted to fluxes using a 365 day calendar. If your model uses a different calendar, you should ideally adjust fluxes such that the integrated annual fluxes are maintained. 


************************************************************************************

GRIDDING METHODOLOGY

Emissions were first estimated at the level of country, sector, and fuel. Emissions by sector and fuel were then mapped to spatial grids by country and sector (i.e., the same spatial sectoral mapping is applied to each fuel category). Grid cells that contain more than one country have portions of emissions from each country. 

Emissions were mapped to the grid level largely using the distribution of emissions from EDGAR v4.3.2 (usually using year-specific EDGAR grids from 1970 - 2012). For additional details see the McDuffie et al., ESSD 2020 manuscript.


************************************************************************************

SPECIATED VOC INFORMATION

CEDS_GBD-MAPS NMVOC emissions are split into 23 species groups using the splits developed by TNO as used in the RETRO project (and also HTAPv2)

NMVOC emissions are split into the following 23 groups:
VOC_id (CMIP data)	VOC_name (annual data)		VOC_long_name					molecular_weight (g/mol)
VOC01				EOH							alcohols						46.2
VOC02				C2H6						ethane							30
VOC03				C3H8						propane							44
VOC04				ALK4_butanes				butanes							57.8
VOC05				ALK4_pentanes				pentanes						72
VOC06				ALK4_hexanes_pl				hexanes_plus_higher_alkanes		106.8
VOC07				C2H4						ethene							28
VOC08				PRPRE						propene							42
VOC09				C2H2						ethyne							26
VOC10				-							isoprene						- not included
VOC11				-							terpenes						- not included
VOC12				BUTENE						other_alkenes_and alkynes		67
VOC13				BENZ						benzene							78
VOC14				TOLU						toluene							92
VOC15				XYLE						xylene							106
VOC16				TMB							trimethylbenzenes				120
VOC17				OTHER_AROM					other_aromatics					126.8
VOC18				ESTERS						esters							104.7
VOC19				ETHERS						ethers							81.5
VOC20				CHC							chlorinated_hydrocarbons		138.8
VOC21				CH2O						methanal						30
VOC22				ALD2						other_alkanals					68.8
VOC23				MEK							ketones							75.3
VOC24				HCOOH						acids							59.1
VOC25				OTHER_VOC					other_voc						68.9

It is assumed that isoprene (VOC10) and terpenes (VOC11) are not emitted in significant quantities by anthropogenic sources, and are not included in the anthropogenic split

The split between these 23 categories was done by extracting from the 0.5 degree gridded RETRO speciation files (retro_nmvoc_ratio.zip) downloaded from the HTAPv2 wiki website. Sector-specific speciation profiles were extracted for each country and, where necessary, noramlized to sum to 1. These profiles were applied to each country and sector and fuel category int eh CEDS_GBD-MAPS emissions data. The profiles are held constant over time. 

Note that these are the same species groups that were used in the CMIP6 emissions dataset (Hoesly et al., 2018).

************************************************************************************

ANNUAL AGGREGATE COUNTRY DATA

In addition to the gridded data, aggregate data by country, sector, and fuel category are also available in units of kilo-tonne (kt) per year. 
DOI: 10.5281/zenodo.3754964

File names are as follows:
CEDS_GBD-MAPS_[compound]_global_emissions_by_country_sector_fuel_2020_v1.csv

[compound] names are as follows:
BC
CO
NH3
NMVOC
NOx
OC
SO2

Total Number of files : 7 (1 per compound)

Each file contains a time series of annual emission totals for each country from 1970 - 2017. 
Countries are listed by their International Organization of Standards (ISO) 3-letter country codes
This dataset also include the 'global' region for international shipping emissions

The sectors in the .csv files are: 
Sector  Description
AGR     Non-combustion agricultural sector
ENE	  	Energy transformation and extraction
IND     Industrial combustion and processes
NRTR    Non-Road/Off-Road transportation (rail, domestic navigation, other)
ROAD    On-Road transportation
RCOR    Residential combustion
RCOC    Commercial combustion
RCOO    Other combustion
SLV     Solvent production and application
WST     Waste disposal and handling
SHP     International shipping (including VOCs from oil tanker loading/leakage)

The fuel categories in the .csv files are:
Fuel							Description
LIQUID_FUEL_PLUS_NATURAL_GAS	Emissions from the combustion of liquid fuel (heavy oil + diesel oil + light oil) and natural gas
SOLID_BIOFUEL					Emissions from the combustion of solid biofuel
TOTAL_COAL						Emissions from the combustion of total coal (hard coal + brown coal + coal coke)
PROCESS							Emissions from all remaining CEDS 'process-level' sources (includes all non-combustion emissions)

Note : total anthropogenic emissions for each country are calculated as the sum of emissions from each of the 4 fuel categories and 11 sectors. International shipping emissions are provided for the 'global' region only. Domestic shipping emissions are included in the NRTR sector. 

Emissions are provided in units of of mass (kilo-tonne (kt)) per year. Units are total mass of the indicated species are as follows:
SO2: Mass flux of SOx, reported as SO2 
NOx: Mass flux of NOx, reported as NO2
CO: Mass flux of CO
NH3 : Mass flux of NH3
BC : Mass flux of BC, reported as carbon mass (e.g., molecular weight 12)
OC: Mass flux of OC, reported as carbon mass (e.g., molecular weight 12)
Total NMVOCs : reported as carbon mass (e.g., molecular weight 12)

************************************************************************************

GENERAL PROJECT AND DATA INFORMATION

An overview of the CEDS project is available from the project website (http://www.globalchange.umd.edu/ceds/) and Hoesly et al., (GMD) 2018. 
An overview of the CEDS data produced for the GBD-MAPS project are described on the project website (https://sites.wustl.edu/acag/datasets/gbd-maps/) and in the following manuscript:
McDuffie, E. E., S. J. Smith, P. O'Rourke, K. Tibrewal, C. Venkataraman, E. A. Marais, B. Zheng, M. Crippa, M. Brauer, R. V. Martin, A global anthropogenic emission inventory of atmospheric pollutants from sector- and fuel- specific sources (1970- 2017): An application of the Community Emissions Data System (CEDS), Earth System Science Data, Submitted

KNOWN ISSUES
Known issues are documented in the Supplemental Section S4 in McDuffie et al., ESSD - Submitted


Please contact: erin.mcduffie@dal.ca for further details or questions about this dataset


************************************************************************************

DOCUMENT VERSION

25 April 2020 - Initial Version

