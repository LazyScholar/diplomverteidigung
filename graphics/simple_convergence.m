%% clear workspace
close all; clear all; clc;
old_path = cd('./simple_convergence');
convergence_data = struct;

file_list = {'ST2_PlateHole_1_2_V03_ConvStudy.mat','ST2_PlateHole_1_2_V03_metrics.mat';
             'ST2_PlateHole_1_2_V01_ConvStudy.mat','ST2_PlateHole_1_2_V01_metrics.mat';
             'ST2_PlateHole_1_2_V02_ConvStudy.mat','ST2_PlateHole_1_2_V02_metrics.mat';};
data_point_sel = 21; % before local refinement and coarsening : Common\f_IncrementalSolver.m : 132

temp_color = lines(size(file_list,1));

for i=size(file_list,1):-1:1
    load(file_list{i,2});
    load(file_list{i,1});
    convergence_data(i).p = 3;
    convergence_data(i).alpha = metrics.alpha;
    files = dir(['./simple_convergence_alpha' num2str(metrics.alpha*100,'%03u') '_i*.png']);
    convergence_data(i).h1_err = ConvStudy(:,2);
    convergence_data(i).dof = ConvStudy(:,5);
    convergence_data(i).L = 1:size(ConvStudy,1);
    convergence_data(i).runtime = metrics.runtime_L(data_point_sel,1:size(ConvStudy,1));
%     convergence_data(i).memory = metrics.whos_mem_L(data_point_sel,size(ConvStudy,1));
    convergence_data(i).memory = metrics.struct_mem_L(data_point_sel,1:size(ConvStudy,1));
    convergence_data(i).images = cellfun(@(x) strcat('./simple_convergence/',x),{files.name},'UniformOutput',false);
    convergence_data(i).line_color = ['rgb(' num2str(temp_color(i,1)*255,'%.2f') ',' num2str(temp_color(i,2)*255,'%.2f') ',' num2str(temp_color(i,3)*255,'%.2f') ')'];
    convergence_data(i).legend_name = ['$p=3,\;\alpha=' num2str(metrics.alpha,'%.2f') '$'];
end

cd(old_path);
clearvars -except convergence_data;

jsonStr = jsonencode(convergence_data);

fid = fopen('simple_convergence.json','w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,jsonStr,'char');
fclose(fid);

% temp_colors = unique(lines(7),'rows'); temp_txt = '['; for i=1:size(temp_colors,1), temp_txt = [temp_txt '''rgb(' num2str(temp_colors(i,1)*255) ',' num2str(temp_colors(i,2)*255) ',' num2str(temp_colors(i,3)*255) ')'',' ]; end, temp_txt = [temp_txt(1:end-1) ']'],