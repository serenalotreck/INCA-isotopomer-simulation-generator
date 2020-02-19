% Author: Serena Lotreck, lotrecks@msu.edu
% this function runs 1 simulation

function runSim(myFreeFluxes,m,fluxRanges)

    % Select the Reaction ID names to be changed to new flux values
    rxn_chng = myFreeFluxes;
    % Cell numbers you want to change the flux values of
    [~,idx_chng] = ismember(rxn_chng,m.rates.flx.id);
    % It's very important to fix the flux to be changed before changing it
    % otherwise it will be rebalanced after flux feasibility adjustment
    m.rates.flx.fix(idx_chng) = 1;
    % Now change the fluxes of interest to a new value
    for I = 1:numel(
        % randomly assign new flux within range 
        newFlux = (fluxRange(2) - fluxRange(1)).*rand + fluxRange(1);

        % assign new flux 
        m.rates.flx.val(idx_chng(M)) = newFlux;