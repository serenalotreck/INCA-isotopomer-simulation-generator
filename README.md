# Shachar-Hill-Lab-MFA-ML
Developing a machine learning model that can predict metabolic fluxes from experimental 13-CO2 labelling data 

## Repo contents 
### hpcc_INCA_isotopomer_simulation
Contains MATLAB .m files for running 500 simulations of the included model (MSUmodel.mat). Code for simExpoerter.m and fluxExporter.m written by Xinyu Fu, and code for simulatedDataGeneration.m adapted from Xinyu Fu's original code. 

### feature_table_formatting.py
Script for organizing the csv outputs of simulatedDataGeneration.m into 3D tensors.
