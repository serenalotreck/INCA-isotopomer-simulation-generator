# INCA-isotopomer-simulation-generator
A software package to generate multiple simulations of 13-C INST-MFA labeling data for a given metabolic model  <br>
Authors: Serena Lotreck (lotrecks@msu.edu) and Xinyu Fu (fuxinyu2@msu.edu) 

## Requirements 
In order to run this software you must have MATLAB 2018a. [Get it here](https://www.mathworks.com/products/new_products/release2018a.html) <br>
You will also need INCA. [Get it here](http://mfa.vueinnovations.com/licensing/mfa-inca)

## Usage 
At the moment, file paths and number of simulations must be hard coded. In simulatedDataGeneration.m, replace the file paths in section 1. (Model pre-processing) to the INCA folder and the repository. In the last line of section 2. (Initial labeling simulation using the INCA model), change the file path to where you want to store your output. Then in section 3. (Flux Manipulation in the INCA model followed by Label Simulation and data export), change the uppoer bound on the range N = 1:200 to the number of simulations you want. Finally, in runSim.m, scroll to the end and change '/mnt/scratch/lotrecks/INCA_sims/' to the path of the directory where you wish to store your output (could be the same or different than the path in 2. of simulatedDataGeneration.m). <br>

After fixing file paths and simulation number, to run the program, you can either run interactively in MATLAB, or, to run non-interactively from the command line, from the INCA-isotopomer-simulation-generator directory, run: 
    matlab -nodisplay -r 'simulatedDataGeneration'


