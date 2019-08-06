# How to download data from CMIP6

1. Go to [https://esgf-data.dkrz.de/search/cmip6-dkrz/](https://esgf-data.dkrz.de/search/cmip6-dkrz/).
2. Under 'Experiment ID', select the scenario you want to choose
    * Select 'AMIP' to use observed data
    * Select 'ssp[n][xx]' to simulate a x.x W/m² forcing at the end of the century
3. Under 'Variable', select the variable that you want to download
    * See [this Excel table](http://proj.badc.rl.ac.uk/svn/exarch/CMIP6dreq/tags/latest/dreqPy/docs/CMIP6_MIP_tables.xlsx) for details on what those variables mean.
    * Select the corresponding Table under 'Table ID'
    * For Table ID 'Amon'...
        * 'psi' is Sea Level Pressure (in Pa)
        * 'ps' is Surface Air Pressure (in Pa)
        * 'pr' is Precipitation (in kg m-2 s-1)
        * 'ta' is Air Temperature (in K)
4. Under 'Variant Label', selecting 'r1i1p1f1' should be fine.
    * r1 = run 1
    * i1 = initialization 1
    * p1 = physics 1
    * f1 = forcings 1
5. Decide on a grid using 'grid label'
    * 'gn' and 'gr' are the most common ones.
6. click on 'search' and go to download (account is required)