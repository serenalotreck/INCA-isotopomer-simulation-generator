% Author: Serena Lotreck, lotrecks@msu.edu 
% with code from Xinyu Fu, fuxinyu2@msu.edu
% this script is hard coded to generate simulated data for the MSU model

%%%% RUN IN SCRATCH %%%%

%%% 1. Model pre-processing

% add inca directory and directory with scripts to path
addpath(genpath('/mnt/gs18/scratch/users/lotrecks/SHLab-copy/INCAv1.8')) 
cd /mnt/home/lotrecks/Shachar-Hill-Lab/Shachar-Hill-Lab-MFA-ML

% load model 
basemodel = load('MSUmodel_v1.mat');
m = basemodel.m;

% define inactive flux 
influxID1 = 'Suc_out-HLacc';
inactive1 = {strcat(influxID1, '.f')};
disp('Inactive fluxes:')
disp(inactive1)


% get free fluxes 
[myFreeFluxes,allFluxValues] = getFreeFluxes(m,inactive1);

% get the ID's of free fluxes (to be changed to new flux values)
rxn_chng = myFreeFluxes;
disp('myFreeFluxes and rxn_chng equivalency')
disp(rxn_chng == myFreeFluxes)

% get 
[~,idx_free] = ismember(rxn_chng,m.rates.flx.id);

% get biologically relevant ranges for all free fluxes
fluxRanges = getFluxRanges(myFreeFluxes,idx_free,allFluxValues);

%%% 2. Initial labeling simulation using the INCA model
disp('performing initial simulation')

% Change nonstationary simulation: relative integration tolerance for MID (reltol)
m.options.int_reltol = 0.0001; %default is 0.001

% Simulate measurements based on fluxes in the  basemodel, returns simdata object
s  = simulate(m);

% Copy simulated measurements (contained in the simdata object) into a new model
simmod = sim2mod(m,s); 
% Extract simulated measurements from the model
[~,simdata] = mod2mat(simmod);
simExporter(simdata, '/mnt/scratch/lotrecks/INCA_sims/simdata')

%%%% 3. Flux Manipulation in the INCA model followed by Label Simulation
%%%% and data export
for N = 1:200 
    iteration_num = int2str(N)
    disp(['simulation # ' iteration_num])
    runSim(myFreeFluxes,allFluxValues,idx_free,m,fluxRanges,iteration_num)
end


