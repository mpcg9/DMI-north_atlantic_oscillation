# How to download data from CMIP6

1. Go to [https://esgf-data.dkrz.de/search/cmip6-dkrz/](https://esgf-data.dkrz.de/search/cmip6-dkrz/).
	* There are other nodes that work the same way and deliver the same results available too.
2. Under 'Variable', select the variable that you want to download
    * See [this Excel table](http://proj.badc.rl.ac.uk/svn/exarch/CMIP6dreq/tags/latest/dreqPy/docs/CMIP6_MIP_tables.xlsx) for details on what those variables mean.
    * Select the corresponding Table under 'Table ID'
    * Some examples: for Table ID 'Amon'...
        * 'psi' is Sea Level Pressure (in Pa)
        * 'ps' is Surface Air Pressure (in Pa)
        * 'pr' is Precipitation (in kg m-2 s-1)
        * 'ta' is Air Temperature (in K)
3. Under 'Experiment ID', select the scenario you want to choose. ([More details here](https://www.geosci-model-dev.net/9/1937/2016/gmd-9-1937-2016.pdf))
    * 'ssp[n][xx]' are the [SSP scenarios](https://www.carbonbrief.org/explainer-how-shared-socioeconomic-pathways-explore-future-climate-change)
    * DECK (Diagnostic, Evaluation and Characterization of Klima) scenarios are:
    	* amip: (1979 - 2014) actual data
		* pindustrial: climate if industrialization had not happened
		* 1pctCO2: 1% increase in CO2-emissions per year
		* abrupt-4xCO2: abruptly increase CO2-emissions
4. Under 'Frequency', select the sample rate (e.g. 'mon' for monthly).
	* Often, each 'Table ID' corresponds to one certain frequency, so if you've already chosen a table ID, you may skip this step.
5. Under 'Source ID', select the models whose output you want to download.
6. Under 'Variant Label', selecting 'r1i1p1f1' should be fine.
    * r1 = run 1
    * i1 = initialization 1
    * p1 = physics 1
    * f1 = forcings 1
		* depending on the selections you made before, there may be no f1 variant.
7. Click on 'search'
8. If you only want to get some test data, you can now click on 'list files' and download one or two if the size is not too large.
   
   If you want to download some more data, create an account and add the files to your data cart. Once vou've got all the data you need in your data cart, go to your data cart, click on 'select all datasets' and then on 'WGET scrips'. It will create a number of links. You will have to download *every* of the scripts that were created (may be more than one!), as different models' data is usually stored on different nodes.
   
9. After downloading your scripts, execute them by `cd`'ing to the desired folder in your Linux console and then typing `bash <your-script-name.sh>`. The files will be downloaded to the same folder in which you've placed the scripts, so make sure you're on your external hard drive (in case this is where you want to put your files)!
	* Remember to repeat this step for every script that you've downloaded before
	* You will likely have to re-enter your OpenID (`https://where-you-ve-created-your-account.somewhere/something/openid/your-username`) + password that you've created before
	* In case that one of the downloads failed or a server becomes unresponsive, you can interrupt the download by pressing `Ctrl`+`C`. If you then start the download again (using `bash <your-script-name.sh>`, as before), your previous download progress will not be lost! You may also use this after the download has finished to check for and resolve any problems that had occurred during the download.
	
## Some Helpful Links
* [A Table displaying all data available](https://pcmdi.llnl.gov/CMIP6/ArchiveStatistics/esgf_data_holdings/)
* [Further Information and Licence for the data](https://pcmdi.llnl.gov/CMIP6/Guide/dataUsers.html)
