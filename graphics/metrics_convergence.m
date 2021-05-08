%% clear workspace
close all; clear all; clc;
old_path = cd('../../04_Ergebnisse');
metrics_convergence_data = struct;

file_list = {'LShape', ...
             {'SC1_L_shape_0_0_000p2_ConvStudy.mat','SC1_L_shape_0_0_000p2_metrics.mat';
              'SC1_L_shape_0_0_000p3_ConvStudy.mat','SC1_L_shape_0_0_000p3_metrics.mat';
              'SC1_L_shape_0_0_080p2_ConvStudy.mat','SC1_L_shape_0_0_080p2_metrics.mat';
              'SC1_L_shape_0_0_080p3_ConvStudy.mat','SC1_L_shape_0_0_080p3_metrics.mat';
              'SC1_L_shape_1_0_000p2_ConvStudy.mat','SC1_L_shape_1_0_000p2_metrics.mat';
              'SC1_L_shape_1_0_000p3_ConvStudy.mat','SC1_L_shape_1_0_000p3_metrics.mat';
              'SC1_L_shape_1_0_080p2_ConvStudy.mat','SC1_L_shape_1_0_080p2_metrics.mat';
              'SC1_L_shape_1_0_080p3_ConvStudy.mat','SC1_L_shape_1_0_080p3_metrics.mat';};
             'PlateHole', ...
             {'SC2_PlateHole_0_0_000p3_ConvStudy.mat','SC2_PlateHole_0_0_000p3_metrics.mat';
              'SC2_PlateHole_0_0_000p4_ConvStudy.mat','SC2_PlateHole_0_0_000p4_metrics.mat';
              'SC2_PlateHole_0_0_060p3_ConvStudy.mat','SC2_PlateHole_0_0_060p3_metrics.mat';
              'SC2_PlateHole_0_0_060p4_ConvStudy.mat','SC2_PlateHole_0_0_060p4_metrics.mat';
              'SC2_PlateHole_1_2_000p3_ConvStudy.mat','SC2_PlateHole_1_2_000p3_metrics.mat';
              'SC2_PlateHole_1_2_000p4_ConvStudy.mat','SC2_PlateHole_1_2_000p4_metrics.mat';
              'SC2_PlateHole_1_2_060p3_ConvStudy.mat','SC2_PlateHole_1_2_060p3_metrics.mat';
              'SC2_PlateHole_1_2_060p4_ConvStudy.mat','SC2_PlateHole_1_2_060p4_metrics.mat';};
             'FicheraCorner', ...
             {'SC3_FicheraCorner_2_000p2_ConvStudy.mat','SC3_FicheraCorner_2_000p2_metrics.mat';
              'SC3_FicheraCorner_2_000p3_ConvStudy.mat','SC3_FicheraCorner_2_000p3_metrics.mat';
              'SC3_FicheraCorner_2_095p2_ConvStudy.mat','SC3_FicheraCorner_2_095p2_metrics.mat';
              'SC3_FicheraCorner_2_095p3_ConvStudy.mat','SC3_FicheraCorner_2_095p3_metrics.mat';};};
data_point_sel = 21; % before local refinement and coarsening : Common\f_IncrementalSolver.m : 132

for k=size(file_list,1):-1:1
    metrics_convergence_data.(file_list{k,1}) = struct;
    temp_name = file_list{k,1};
for i=size(file_list{k,2},1):-1:1
    load(file_list{k,2}{i,2});
    load(file_list{k,2}{i,1});
    switch file_list{k,1}
        case 'PlateHole'
            p0 = 2;
            pmin = 3;
        case 'LShape'
            p0 = 1;
            pmin = 2;
        otherwise
            p0 = 1;
            pmin = 2;
    end
    metrics_convergence_data.(temp_name)(i).p = p0+metrics.Initial_p_Refinement;
    metrics_convergence_data.(temp_name)(i).alpha = metrics.alpha;
    metrics_convergence_data.(temp_name)(i).h1_err = ConvStudy(:,2);
    metrics_convergence_data.(temp_name)(i).dof = ConvStudy(:,5);
    metrics_convergence_data.(temp_name)(i).L = 1:size(ConvStudy,1);
    metrics_convergence_data.(temp_name)(i).runtime = metrics.runtime_L(data_point_sel,1:size(ConvStudy,1));
%     metrics_convergence_data.(temp_name)(i).memory = metrics.whos_mem_L(data_point_sel,size(ConvStudy,1));
    metrics_convergence_data.(temp_name)(i).memory = metrics.struct_mem_L(data_point_sel,1:size(ConvStudy,1));
    switch file_list{k,1}
        case 'PlateHole'
            c = sym(-metrics_convergence_data.(temp_name)(i).p/2);
        case 'LShape'
            switch metrics.alpha
                case 0
                    c = sym(-1/3);
                otherwise
                    c = sym(-1/2*min(metrics_convergence_data.(temp_name)(i).p,pi/(2*pi-pi/2)));
            end
        otherwise
            switch metrics.alpha
                case 0
                    c = sym(-1/3);
                otherwise
                    c = sym(-1/2*min(metrics_convergence_data.(temp_name)(i).p,pi/(2*pi-pi/2)));
            end
    end
    [n,d] = numden(sym(-c));
    c = double(c);
    switch double(d)
        case 1
            metrics_convergence_data.(temp_name)(i).k_text = ['$k=-' num2str(double(n),'%u') '$'];
        otherwise
            metrics_convergence_data.(temp_name)(i).k_text = ['$k=-\frac{' num2str(double(n),'%u') '}{' num2str(double(d),'%u') '}$'];
    end
    y2 = exp(log(ConvStudy(end,2))+(log(ConvStudy(end,2))-log(ConvStudy(1,2)))*5/100);
    x2 = ConvStudy(end,5);
    x1 = exp(log(ConvStudy(1,5))+(log(ConvStudy(end,5))-log(ConvStudy(1,5)))/2);
    y1 = exp((log(x1)-log(x2))*c+log(y2));
    metrics_convergence_data.(temp_name)(i).k_x = [x1 x2];
    metrics_convergence_data.(temp_name)(i).k_y = [y1 y2];
    switch metrics.AdaptiveElementGeneration
        case true
            metrics_convergence_data.(temp_name)(i).legend_name = ['$\text{IGA neu: } p=' num2str(metrics_convergence_data.(temp_name)(i).p,'%u') ',\;\alpha=' num2str(metrics.alpha,'%.2f') '$'];
            metrics_convergence_data.(temp_name)(i).line_color = '#0000FF';
            metrics_convergence_data.(temp_name)(i).line_text = 'IGA neu';
        case false
            metrics_convergence_data.(temp_name)(i).legend_name = ['$\text{IGA referenz: } p=' num2str(metrics_convergence_data.(temp_name)(i).p,'%u') ',\;\alpha=' num2str(metrics.alpha,'%.2f') '$'];
            metrics_convergence_data.(temp_name)(i).line_color = '#FF0000';
            metrics_convergence_data.(temp_name)(i).line_text = 'IGA referenz';
    end
    switch metrics.alpha
        case 0
            metrics_convergence_data.(temp_name)(i).line_dash = 'dot';
        otherwise
            metrics_convergence_data.(temp_name)(i).line_dash = 'solid';
    end
	switch metrics_convergence_data.(temp_name)(i).p
        case pmin
            metrics_convergence_data.(temp_name)(i).marker_symbol = 0;
        otherwise
            metrics_convergence_data.(temp_name)(i).marker_symbol = 1;
    end
end
end

% metrics_convergence_data.PlateHole(8).h1_err(end) = [];
% metrics_convergence_data.PlateHole(8).dof(end) = [];
% metrics_convergence_data.PlateHole(8).L(end) = [];
% metrics_convergence_data.PlateHole(8).runtime(end) = [];
% metrics_convergence_data.PlateHole(8).memory(end) = [];

cd(old_path);
clearvars -except metrics_convergence_data;

jsonStr = jsonencode(metrics_convergence_data);

fid = fopen('metrics_convergence_data.json','w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,jsonStr,'char');
fclose(fid);