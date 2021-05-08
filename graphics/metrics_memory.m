%% clear workspace
close all; clear all; clc;
old_path = cd('../../04_Ergebnisse');
metrics_memory_data = struct;

file_list = {'LShape', ...
             {'SM1_L_shape_0_0_V00_ConvStudy.mat','SM1_L_shape_0_0_V00_metrics.mat';
              'SM1_L_shape_1_0_V00_ConvStudy.mat','SM1_L_shape_1_0_V00_metrics.mat';
              'SM1_L_shape_1_1_V00_ConvStudy.mat','SM1_L_shape_1_1_V00_metrics.mat';
              'SM1_L_shape_1_2_V00_ConvStudy.mat','SM1_L_shape_1_2_V00_metrics.mat';};
             'PlateHole', ...
             {'SM2_PlateHole_0_0_V00_ConvStudy.mat','SM2_PlateHole_0_0_V00_metrics';
              'SM2_PlateHole_1_0_V00_ConvStudy.mat','SM2_PlateHole_1_0_V00_metrics';
              'SM2_PlateHole_1_1_V00_ConvStudy.mat','SM2_PlateHole_1_1_V00_metrics';
              'SM2_PlateHole_1_2_V00_ConvStudy.mat','SM2_PlateHole_1_2_V00_metrics';};
             'FicheraCorner', ...
             {'SM3_FicheraCorner_1_0_V00_ConvStudy.mat','SM3_FicheraCorner_1_0_V00_metrics.mat';
              'SM3_FicheraCorner_1_1_V00_ConvStudy.mat','SM3_FicheraCorner_1_1_V00_metrics.mat';
              'SM3_FicheraCorner_1_2_V00_ConvStudy.mat','SM3_FicheraCorner_1_2_V00_metrics.mat';};
              };
data_point_sel = 21; % before local refinement and coarsening : Common\f_IncrementalSolver.m : 132

for k=size(file_list,1):-1:1
    metrics_memory_data.(file_list{k,1}) = struct;
    temp_name = file_list{k,1};
for i=size(file_list{k,2},1):-1:1
    load(file_list{k,2}{i,2});
    load(file_list{k,2}{i,1});
    switch file_list{k,1}
        case 'PlateHole'
            p0 = 2;
        case 'LShape'
            p0 = 1;
        otherwise
            p0 = 1;
    end
    metrics_memory_data.(temp_name)(i).p = p0+metrics.Initial_p_Refinement;
    metrics_memory_data.(temp_name)(i).alpha = metrics.alpha;
    metrics_memory_data.(temp_name)(i).h1_err = ConvStudy(:,2);
    metrics_memory_data.(temp_name)(i).dof = ConvStudy(:,5);
    metrics_memory_data.(temp_name)(i).L = 1:size(ConvStudy,1);
    metrics_memory_data.(temp_name)(i).runtime = metrics.runtime_L(data_point_sel,1:size(ConvStudy,1));
%     metrics_memory_data.(temp_name)(i).memory = metrics.whos_mem_L(data_point_sel,size(ConvStudy,1));
    metrics_memory_data.(temp_name)(i).memory = metrics.struct_mem_L(data_point_sel,1:size(ConvStudy,1));
    switch metrics.AdaptiveElementGeneration
        case true
            switch metrics.useAdaptiveMemory
                case 0
                    metrics_memory_data.(temp_name)(i).legend_name = ['$\text{IGA voll: } p=' num2str(metrics_memory_data.(temp_name)(i).p,'%u') ',\;\alpha=' num2str(metrics.alpha,'%.2f') '$'];
                    metrics_memory_data.(temp_name)(i).line_color = '#00a1a1';
                    metrics_memory_data.(temp_name)(i).line_text = 'IGA voll';
                    metrics_memory_data.(temp_name)(i).marker_symbol = 101;
                    metrics_memory_data.(temp_name)(i).line_dash = 'dot';
                case 1
                    metrics_memory_data.(temp_name)(i).legend_name = ['$\text{IGA sparse: } p=' num2str(metrics_memory_data.(temp_name)(i).p,'%u') ',\;\alpha=' num2str(metrics.alpha,'%.2f') '$'];
                    metrics_memory_data.(temp_name)(i).line_color = '#00FF00';
                    metrics_memory_data.(temp_name)(i).line_text = 'IGA sparse';
                    metrics_memory_data.(temp_name)(i).marker_symbol = 100;
                    metrics_memory_data.(temp_name)(i).line_dash = 'solid';
                case 2
                    metrics_memory_data.(temp_name)(i).legend_name = ['$\text{IGA mit Ged.: } p=' num2str(metrics_memory_data.(temp_name)(i).p,'%u') ',\;\alpha=' num2str(metrics.alpha,'%.2f') '$'];
                    metrics_memory_data.(temp_name)(i).line_color = '#0000FF';
                    metrics_memory_data.(temp_name)(i).line_text = 'IGA sparse mit Ged.';
                    metrics_memory_data.(temp_name)(i).marker_symbol = 1;
                    metrics_memory_data.(temp_name)(i).line_dash = 'solid';
            end
        case false
            metrics_memory_data.(temp_name)(i).legend_name = ['$\text{IGA referenz: } p=' num2str(metrics_memory_data.(temp_name)(i).p,'%u') ',\;\alpha=' num2str(metrics.alpha,'%.2f') '$'];
            metrics_memory_data.(temp_name)(i).line_color = '#FF0000';
            metrics_memory_data.(temp_name)(i).line_text = 'IGA referenz';
            metrics_memory_data.(temp_name)(i).marker_symbol = 2;
            metrics_memory_data.(temp_name)(i).line_dash = 'solid';
    end
end
end

cd(old_path);
clearvars -except metrics_memory_data;

jsonStr = jsonencode(metrics_memory_data);

fid = fopen('metrics_memory_data.json','w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,jsonStr,'char');
fclose(fid);