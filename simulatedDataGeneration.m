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

% get indices of free fluxes in whole model flux ID vector
[~,idx_free] = ismember(myFreeFluxes,m.rates.flx.id);

% get biologically relevant ranges for all free fluxes
fluxRanges = getFluxRanges(myFreeFluxes,idx_free,allFluxValues);

% determine how many fluxes are already fixed 
alreadyFixed = nnz(m.rates.flx.fix);
disp(['Number of fluxes already fixed:' int2str(alreadyFixed)])

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
outputPath = '/mnt/scratch/lotrecks/INCA_sims/'
simExporter(simdata, [outputPath 'simdata'])

%%%% 3. Flux Manipulation in the INCA model followed by Label Simulation
%%%% and data export
for N = 1:200 
    iteration_num = int2str(N);
    disp(['simulation # ' iteration_num])
    runSim(myFreeFluxes,allFluxValues,idx_free,alreadyFixed,m,fluxRanges,iteration_num,outputPath)
end


