% Author: Xinyu Fu, fuxinyu2@msu.edu
function simExporter(simdata, simID)
% SIMEXPORTER exports simulated labeling data to csv files
%
%  1st argument simdata is a struc array extracted from the simulated measurements
%  in the model.
%  2nd argument simID is a text string that represents the identifier of the simdata, MUST be
%  wraped in single quotes. This text string will be used as an idenfier and appear in the
%  filenames of each csv output file.
%
%  The function returns Null and writes multiple csv files in the working directory.
%  Each csv file contains the simulated labeling data of one metabolite.

for i = 1:length(simdata.ms)
    simdata = simdata;
    T = table();
    time = simdata.ms(i).time;
    val = simdata.ms(i).val.';
    sim_mdv = [time val];
    len_mdv = simdata.ms(i).len;
    T = array2table(sim_mdv);
    T.met = repelem({simdata.ms(i).id}, length(time)).';
    T.Properties.VariableNames(1) = {'time'};
    T.Properties.VariableNames(2:len_mdv+1) = sprintfc('M%d',0:len_mdv-1);
    writetable(T,sprintf('%s_%s.csv',simID, simdata.ms(i).id),'Delimiter',',');
end
end