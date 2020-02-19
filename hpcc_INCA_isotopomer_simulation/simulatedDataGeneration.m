% Author: Serena Lotreck, lotrecks@msu.edu 
% with code taken from Xinyu Fu, fuxinyu2@msu.edu
% this script is hard coded to generate simulated data for the MSU model
% currently, these scripts have to be inside INCA folder (can't figure out 
% why MATLAB throws an error for setpath when run non-interactively)

%%%% RUN FROM SCRATCH %%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% from getFreeFluxes.m, Serena Lotreck
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% cd to inca directory 
cd /mnt/gs18/scratch/users/lotrecks/SHLab-copy/INCAv1.8_copy/INCAv1.8

% load model 
basemodel = load('MSUmodel_v1.mat');
m = basemodel.m;

% get S object 
% S is the stoich object, which contains: 
% S.N is the stoichiometric matrix
% S.K is the kernel (nullspace) matrix
% S.u is the vector of free flux values that defines your initial guess
% S.vf is a logical vector where true entries correspond to free fluxes
% S.v0 is a vector of fixed flux values 
[v, S] = mod2stoich(m); 

% get free flux vector S.vf
freeFluxes = S.vf;

% S.vf is unlabeled. To identify which fluxes are which, we need the 
% vector of flux id's, which corresponds to the entries in all the elements
% of the S object.
fluxIDs = m.rates.flx.id; 

% remove inactivated reactions from the fluxIDs vector
% unclear how to do this generalizably, at the moment just opening the
% model in the gui and using reaction editor to see which ones are
% activated, and then manually exclude them from the ID vector

% define inactive flux 
influxID1 = 'Suc_out-HLacc';
inactive1 = {strcat(influxID1, '.f')};

% find index of this flux in ID vector 
index = [];
for N = 1:numel(fluxIDs)
    if strcmp(fluxIDs(N),inactive1)
        index = [index N];
    end 
end 

% get rid of inactive flux from ID vector
fluxIDs(index) = [];

% get indices for the true (free) fluxes 
indices = [];
for N = 1:numel(freeFluxes)
    if freeFluxes(N)
        indices = [indices N];
    end 
end

% use these indices to get free fluxes in a new vector
myFreeFluxes = [];
for N = 1:numel(fluxIDs)
    if ismember(N,indices)
        myFreeFluxes = [myFreeFluxes fluxIDs(N)];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% from INCA_isotopomer_simulation_script_x4.m, Xinyu Fu
% modified by SL 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% 1. Labeling simulation using the INCA model

% Change nonstationary simulation: relative integration tolerance for MID (reltol)
m.options.int_reltol = 0.0001; %default is 0.001

% Simulate measurements based on fluxes in the  basemodel, returns simdata object
s  = simulate(m);

% Copy simulated measurements (contained in the simdata object) into a new model
simmod = sim2mod(m,s); 
% Extract simulated measurements from the model
[~,simdata] = mod2mat(simmod);
simExporter(simdata, '/mnt/scratch/lotrecks/INCA_sims/simdata')

%%%% 2. Flux Manipulation in the INCA model followed by Label Simulation
for N = 1:500
    % Select the Reaction ID names to be changed to new flux values
    rxn_chng = myFreeFluxes(1);
    % Cell numbers you want to change the flux values of
    [~,idx_chng] = ismember(rxn_chng,m.rates.flx.id);
    % It's very important to fix the flux to be changed before changing it
    % otherwise it will be rebalanced after flux feasibility adjustment
    m.rates.flx.fix(idx_chng) = 1;
    % Now change the fluxes of interest to a new value
    for N = 1:numel(idx_chng)
        origFlux = m.rates.flx.val(N);

        % determine a relevant range for this flux 
        if origFlux > 0
            rangeNum = origFlux*3;
            fluxRange = [0 origFlux+rangeNum];
        elseif origFlux < 0
            rangeNum = abs(origFlux)*3;
            fluxRange = [origFlux-rangeNum 0];
        end

        % randomly assign new flux within range 
        newFlux = (fluxRange(2) - fluxRange(1)).*rand + fluxRange(1);

        % assign new flux 
        m.rates.flx.val(idx_chng(N)) = newFlux;
    end

    % remove inactive fluxes
    fluxVals = m.rates.flx.val;
    fluxVals(index) = [];

    % Let INCA reconcile the flux values to ensure network feasibility.
    % Overwrite the flux values in the model with adjusted new flux values.
    % Need to select row# for m.rates.flx.val, otherwise a matrix will be assigned
    fluxVals(1:length(fluxVals)) = mod2stoich(m);

    % Simulating new isotope labeling data based on the model with flux values
    % changed and adjusted.
    s  = simulate(m);
    % Copy new simulated measurements into model and assign it to new model
    simmod_new = sim2mod(m,s); 
    % Extract simulated measurements from the new model,
    % simdata_new contains the simulated isotope labeling data based on new
    % flux values
    [~,simdata_new] = mod2mat(simmod_new);

    %%% 3. Export simulated labeling data to CSV files

    % Make sure simExporter.m is in the working directory
    % The simExporter(simdata, simID) function is to export simdata as csv
    % 1st argument is the simulated data (saved in simdata or simdata_new)
    % 2nd argurment is a string used as an idenfier and will appear in the
    % filenames of each csv output files
    % Each metabolite is saved separately since they vary in matrix size
    metabolites = ['/mnt/scratch/lotrecks/INCA_sims/' int2str(N) '_simdata']
    simExporter(simdata_new, metabolites)

    %%% 4. Export flux data to CSV files

    % Make sure fluxExporter.m is in the working directory
    % The fluxExporter(model, filename) function is to export flux properties as csv
    % 1st argument is an .mod object from the INCA model, from which you want
    % to export the flux properties
    % 2nd argurment is a string used as an idenfier and will appear in the
    % filenames of each csv output files
    fluxes = ['/mnt/scratch/lotrecks/INCA_sims/' int2str(N) '_flux_after_manipulation' ]
    fluxExporter(m, fluxes)
end