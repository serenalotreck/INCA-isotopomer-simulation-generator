% Author: Serena Lotreck, lotrecks@msu.edu
% This function is for extracting the independent fluxes in a given networl
% Currently the inactivated fluxes have to be passed explicitly to the
% function, in the future want to figure out how to get those through the
% inca command line rather than having to manually find them in the gui 

function [myFreeFluxes,allFluxValues] = getFreeFluxes(m,inactive1)

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

    % find index of this flux in ID vector 
    index = [];
    for N = 1:numel(fluxIDs)
        if strcmp(fluxIDs(N),inactive1)
            index = [index N];
        end 
    end 

    % get rid of inactive flux from ID vector and flux value vector
    fluxIDs(index) = [];
    
    allFluxValues = m.rates.flx.val
    allFluxValues(index) = [];

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
end

