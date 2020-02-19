% Author: Xinyu Fu, fuxinyu2@msu.edu
% Modified by Serena Lotreck, lotrecks@msu.edu
% This script is developed for manipulating fluxes in INCA models, simulating isotope
% labeling data ,and exporting fluxes and simulated data to csv files
% 091819updated: Line 27 to change integration time span, Line 30 to change relative integration tolerance

% First, navigate to INCAv1.8 folder
cd '~/Shachar-Hill_Lab/INCAv1.8'
setpath 

% After running setpath, all subfolders in the INCAv1.8 should appear in Matlab
% set path so that INCA functions can be used.

% Then, go to your working directory with .mat  files and this .m scripts
cd '~/Shachar-Hill_Lab/INCA_isotopomer_simulation_x3'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Labeling simulation using the INCA model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load an INCA model 
% Using the MSU model, MSU model v1.
basemodel = load('MSUmodel_v1.mat');
m = basemodel.m;

% Change nonstationary simulation: integration time span (tspan) 
% m.options.int_tspan = [0 0.25];

% Change nonstationary simulation: relative integration tolerance for MID (reltol)
m.options.int_reltol = 0.0001; %default is 0.001

% Simulate measurements based on fluxes in the  basemodel, returns simdata object
s  = simulate(m);

% If s  = simulate(m) doesn't work, use the line below instead
% try s = simulate(m); catch simmod = simulate(m); end

% Copy simulated measurements (contained in the simdata object) into a new model
simmod = sim2mod(m,s); 
% Extract simulated measurements from the model
[~,simdata] = mod2mat(simmod);

% simdata contains the simulated isotope labeling data, so can be directly
% acessed in Matlab 
% To access the metabolite id of simulated data
simdata.ms.id;
% To access the time points in simulated data
simdata.ms.time;
% Access mass isotope distribution ratio of simulated data
simdata.ms.val;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Flux Manipulation in the INCA model followed by Label Simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Select the Reaction ID names to be fixed in flux values
rxn_fix = {'PGI.p.f', 'T_DHAP.f', 'T_DHAP.b'};
% Cell numbers you want to fix the flux values
[~,idx_fix] = ismember(rxn_fix,m.rates.flx.id);
% Fix the aboves fluxes by assigning 'fix' to 1
m.rates.flx.fix(idx_fix) = 1;

% Select the Reaction ID names to be changed to new flux values
rxn_chng = {'GAPDH.p.f'};
% Cell numbers you want to change the flux values of
[~,idx_chng] = ismember(rxn_chng,m.rates.flx.id);
% It's very important to fix the flux to be changed before changing it
% otherwise it will be rebalanced after flux feasibility adjustment
m.rates.flx.fix(idx_chng) = 1;

% Loop to create 200 simulations
for i = 1:5
    %Now change the flux of interest to a new value
    m.rates.flx.val(idx_chng) = i+100; 

    % Let INCA reconcile the flux values to ensure network feasibility.
    % Overwrite the flux values in the model with adjusted new flux values.
    % Need to select row# for m.rates.flx.val, otherwise a matrix will be assigned
    m.rates.flx.val(1:length(m.rates.flx.val)) = mod2stoich(m);

    % Optional: You can print flux data in console to make sure the new flux values
    % are what you expect
    % type(m.rates.flx)

    % Simulating new isotope labeling data based on the model with flux values
    % changed and adjusted.
    s  = simulate(m);
    % Copy new simulated measurements into model and assign it to new model
    simmod_new = sim2mod(m,s); 
    % Extract simulated measurements from the new model,
    % simdata_new contains the simulated isotope labeling data based on new
    % flux values
    [~,simdata_new] = mod2mat(simmod_new);

    % simdata_new can directly used for downstream analysis in Matlab 
    % To Access metabolite id of newly simulated data
    simdata_new.ms.id;
    % To access the time points in the newly simulated data
    simdata_new.ms.time;
    % To access mass the mass distribution vectors of newly simulated data
    simdata_new.ms.val;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 3. Export simulated labeling data to CSV files
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Make sure simExporter.m is in the working directory
    % The simExporter(simdata, simID) function is to export simdata as csv
    % 1st argument is the simulated data (saved in simdata or simdata_new)
    % 2nd argurment is a string used as an idenfier and will appear in the
    % filenames of each csv output files
    % Each metabolite is saved separately since they vary in matrix size
    simExporter(simdata_new, 'simdata_num_'+i)
end

% exporting data from first simulation
simExporter(simdata, 'simdata')