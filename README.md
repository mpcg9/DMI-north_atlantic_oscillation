# DMI_summer2019

## Required tools for running this code
To run most of this code, you will have to download a few additional tools:

- [M_Map](https://www.eoas.ubc.ca/~rich/map.html) (Version 1.4k+) is required for all plotting routines.
- [Climate Data Toolbox](https://de.mathworks.com/matlabcentral/fileexchange/70338-climate-data-toolbox-for-matlab) (Version 1.01+) is required for NAO index computations.
- [Cbrewer](https://de.mathworks.com/matlabcentral/fileexchange/34087-cbrewer-colorbrewer-schemes-for-matlab) (Version 1.1.0.0+) for the preset color schemes. 

### Where to place these?

For the M_Map and Climate Data Toolbox, extract them and place the resulting folder (`/m_map` or `/cdt`) in a top-level folder called `/toolboxes`. You can however also place them anywhere you like as long as they are in your MATLAB paths, even though this will result in warnings (they're annoying yet harmless).
For the Cbrewer files, place them inside a folder called `tools`. You will likely need to add the `colorbrewer.mat` file, which you can find online.

## Further requirements

This code has been written in and tested on MATLAB 2017b. Make sure to execute every script from the folder where it has been placed or to add the whole repository to the MATLAB paths, so that referenced functions and scipts can be found. 

## How to convert .nc files into .mat files

There are data ingestion methods available in the folder `io`. Here's a quick guide:

1. Download some data using our [guide](https://github.com/mpcg9/DMI-north_atlantic_oscillation/blob/coding/documentation/data_download_guide.md).
2. If it is only one file: use `readClimateData_singleFile.m`, otherwise go to the next step
3. Create a folder for each model/scenario/variable/run combination and place the corresponding `*.nc`-files in those folders.
4. If there are only one (or very few) folders now, use `readClimateData_singleFolder.m`. If not, use `readClimateData_tree.m` to search for data in the entire folder structure you've created (Make sure not to select a very top-level folder as it will attempt to convert all `*.nc`-files in all subdirectories).

A general advise is to **NOT FORGET TO CHECK THE OPTIONS IN THE SCRIPTS**. You can use these options to extract only parts (certain lon/lat regions or a certain pressure level) of the data, saving *A LOT* of memory space. Lastly, keep in mind that all the routines only work on data using grid vectors for lat/lon specifications.
