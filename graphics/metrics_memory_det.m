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

data_bracket = { ...
'alle Variablen',{'*'}; ...
'IGA-Variablen',{'model.IGA'};
'Kontroll-Koeffizienten',{'model.IGA.Weights';'model.IGA.NodeComputed';'model.Nodes';'model.IGA.NodeGlob2Loc';'model.NodalMaterials';'model.NodalDOF';'model.inverseNodalDOF'}; ...
'glob. Untert.-Matrix',{'model.IGA.M'}; ...
'Patch-Informationen',{'model.IGA.Patches';'model.IGA.PatchLevel'}; ...
'Element-Informationen',{'model.IGA.ElemLevel';'model.IGA.ElemPatch';'model.ElementInfo';'model.Elements'}; ...
'Eltern-Kind-Informationen',{'model.IGA.ParentElements';'model.IGA.ChildElements';'model.IGA.QuadTree'}; ...
'Element-Kontrollpunkt-Inf.',{'model.inverseConnectivity';'model.Connectivity';'model.IGA.Connectivity_local'}; ...
'Nachbar-Inf.',{'model.IGA.self_inters';'model.IGA.point_inters';'model.IGA.edge_inters';'model.IGA.face_inters';'model.IGA.elem_neighbours';'model.IGA.BoundaryElementNeighbours';'model.IGA.edge_inters';'model.IGA.face_inters'}; ...
};

metrics_memory_data.brackets = struct;
for k=1:size(data_bracket,1)
metrics_memory_data.brackets(k).names = data_bracket{k,1};
metrics_memory_data.brackets(k).content = strjoin(data_bracket{k,2},'<br>');
end

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
                case 1
                    metrics_memory_data.(temp_name)(i).legend_name = ['$\text{IGA sparse: } p=' num2str(metrics_memory_data.(temp_name)(i).p,'%u') ',\;\alpha=' num2str(metrics.alpha,'%.2f') '$'];
                    metrics_memory_data.(temp_name)(i).line_color = '#00FF00';
                    metrics_memory_data.(temp_name)(i).line_text = 'IGA sparse';
                case 2
                    metrics_memory_data.(temp_name)(i).legend_name = ['$\text{IGA mit Ged.: } p=' num2str(metrics_memory_data.(temp_name)(i).p,'%u') ',\;\alpha=' num2str(metrics.alpha,'%.2f') '$'];
                    metrics_memory_data.(temp_name)(i).line_color = '#0000FF';
                    metrics_memory_data.(temp_name)(i).line_text = 'IGA sparse mit Ged.';
            end
        case false
            metrics_memory_data.(temp_name)(i).legend_name = ['$\text{IGA referenz: } p=' num2str(metrics_memory_data.(temp_name)(i).p,'%u') ',\;\alpha=' num2str(metrics.alpha,'%.2f') '$'];
            metrics_memory_data.(temp_name)(i).line_color = '#FF0000';
            metrics_memory_data.(temp_name)(i).line_text = 'IGA referenz';
    end
    metrics_memory_data.(temp_name)(i).bracket = data_bracket(:,1)';
    bracket_val = zeros(size(data_bracket,1),1);
    for e=1:size(data_bracket,1)
%         metrics_memory_data.(temp_name)(i).bracket{e} = num2str(e,'%u');
        if e==1
            temp_val = metrics.struct_mem_L(data_point_sel,size(ConvStudy,1));
        else
            temp_val = 0;
            for s=1:numel(data_bracket{e,2})
                temp_idx = find(cellfun(@(x) strcmp(x,data_bracket{e,2}{s}),metrics.model_sel),1);
                if isempty(temp_idx), disp([data_bracket{e,2}{s} ' not found!!!']); return; end
                temp_mem = grab_elem_memory(metrics.struct_parts,temp_idx,data_point_sel,size(ConvStudy,1)); %%%
                if isempty(temp_mem), continue; end
                temp_val = temp_val+temp_mem;
            end
        end
        bracket_val(e) = temp_val;
    end
    metrics_memory_data.(temp_name)(i).bracket_val = bracket_val;
end
end

cd(old_path);
clearvars -except metrics_memory_data;

jsonStr = jsonencode(metrics_memory_data);

fid = fopen('metrics_memory_data_det.json','w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,jsonStr,'char');
fclose(fid);


function vec = grab_elem_memory(data,i,pos,L)
% helper function to grab certain strutcture element memory of each level
temp_val = data{pos,L}(i);
if isnan(temp_val)
    vec = [];
else
    vec = temp_val;
end
end