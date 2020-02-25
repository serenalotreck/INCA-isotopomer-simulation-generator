function fluxExporter(model, filename)
% FLUXEXPORTER exports flux parameters to a csv file
%
%  1st argument model is an .mod object from INCA model
%  2nd argument filename is a text string that represents the identifier of the exported file, MUST be
%  wraped in single quotes. This text string will be used as an idenfier and appear in the
%  filename of the csv output file.
%
%  The function returns Null and writes multiple csv files in the working directory.

m = model;
id =m.rates.flx.id(:);
rxn =m.rates.flx.rxn(:);
dir = m.rates.flx.dir(:);
val = m.rates.flx.val(:);
fix = m.rates.flx.fix(:);
lb = m.rates.flx.lb(:);
ub = m.rates.flx.ub(:);
T = table( id, rxn, dir, val, fix, lb, ub);
T.Properties.VariableNames = {'ID' 'Equation' 'Direction' 'FluxValue' 'Fixed' 'LB' 'UB'};
writetable(T,sprintf('%s.csv',filename),'Delimiter',',');
end
