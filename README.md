# INCA-isotopomer-simulation-generator
A software package to generate multiple simulations of 13-C INST-MFA labeling data for a given metabolic model  <br>
Authors: Serena Lotreck (lotrecks@msu.edu) and Xinyu Fu (fuxinyu2@msu.edu) 
**PLEASE NOTE:** This package is under active development, and is currently not ready for use

## Requirements 
In order to run this software you must have MATLAB 2018a. [Get it here](https://www.mathworks.com/products/new_products/release2018a.html) <br>
You will also need INCA. [Get it here](http://mfa.vueinnovations.com/licensing/mfa-inca)

## Usage 
At the moment, file paths and number of simulations must be hard coded. Steps to customize this module: 
1. In simulatedDataGeneration.m, replace the file paths in section 1. (Model pre-processing) to the INCA folder and the repository. 
2. At the end of section 2, change the `outputPath` variable to the path where simulation outputs will be stored. 
3. In section 3. (Flux Manipulation in the INCA model followed by Label Simulation and data export), change the upper bound on the range N = 1:200 to the number of simulations you want.  
4. Define inactive fluxes (see 2. in **Important Assumptions and Behaviors**)

After customizing file paths, inactive fluxes, and simulation number, the program can either be run interactively in MATLAB, or non-interactively from the command line by running: 
    matlab -nodisplay -r 'simulatedDataGeneration'
from the `INCA-isotopomer-simulation-generator` directory

## Important Assumptions and Behaviors 
1. Fixed fluxes
    * Assumes: that if the user wants to fix dependent fluxes, they will have done so before running this code 
    * Behaves: the program will subtract the number of previously fixed fluxes from the number of degrees of freedom of the model. # free fluxes - # previously fixed fluxes = # of free fluxes that will be fixed in the simulation. The free fluxes that get fixed will then be randomly selected. 
2. Inactive fluxes 
    * Assumes: nothing. There is an inactive flux in the model this simulation was made with, and therefore code is included to exclude inactive fluxes. `inactive1` must be an array of cells containing the ID's of inactive fluxes. This code supports multiple inactive fluxes. 
    * Behaves: In order to customize, replace the code under the header `% define inactive flux` to make `inactive1` equal to an array of cells containing the ID's of inactive fluxes.

