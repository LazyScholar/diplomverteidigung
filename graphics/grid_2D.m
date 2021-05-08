%% clear workspace
close all; clear all; clc;
grid_data = struct;

%% create triangular mesh by matlab
model = createpde('structural','static-planestress');
g = [1  0 -1 1 0 0 1 0 0 1;
     2  0  0 1 8 1 0 0 0 0;
     1  0 -8 8 0 1 0 0 0 8;
     2 -8 -1 0 0 1 0 0 0 0]';
geometryFromEdges(model,g);
subplot(1,2,1);
generateMesh(model);
temp = pdeplot(model);
set(temp(1),'Color',[0 0.45 0.75])
set(temp(2),'LineWidth',2,'Color',[0 0 0]);
axis equal;
xlim([-8 0]); ylim([0 8]);
box on;
xlabel('$x$','Interpreter','latex');
ylabel('$y$','Interpreter','latex');

grid_data.grid_1.x_grid = temp(1).XData;
grid_data.grid_1.y_grid = temp(1).YData;
grid_data.grid_1.x_boundary = temp(2).XData;
grid_data.grid_1.y_boundary = temp(2).YData;

%% create NURBS mesh
addpath ../../02_Tests/Matlab;
n_samples = 20; h_ref = 4;
knots = {[0 0 0 1 1 1],[0 0 0 1 1 1]};
p = [2 2];
temp = sqrt(2.0)/2.0;
points = [-1.0 -1.0  0.0 -4.5 -4.5  0.0 -8.0 -8.0  0.0;
           0.0  1.0  1.0  0.0  4.5  4.5  0.0  8.0  8.0;
           0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0;
           1.0 temp  1.0  1.0 temp  1.0  1.0 temp  1.0]';
grid_samples = {linspace(knots{1}(1),knots{1}(end),n_samples)',linspace(knots{2}(1),knots{2}(end),n_samples)'};
temp = [grid_samples{1} repmat(grid_samples{2}(1),n_samples,1);
        repmat(grid_samples{1}(end),n_samples-2,1) grid_samples{2}(2:end-1);
        flipud(grid_samples{1}) repmat(grid_samples{2}(end),n_samples,1);
        repmat(grid_samples{1}(1),n_samples-1,1) flipud(grid_samples{2}(1:end-1))];
C = bivariate_NURBS(temp,p,knots,points(:,1:3),points(:,4),[3 3]);
for d=2:-1:1
    [multiplicity,unique_knots,~] = knot_mult_var(p(d),knots{d});
    multiplicity(1) = p(d)+1;
    multiplicity(end) = p(d)+1;
    for s=1:h_ref
        unique_knots = [ reshape([unique_knots(1:end-1); unique_knots(1:end-1)+diff(unique_knots)/2 ],1,[]) unique_knots(end)];
        multiplicity = [ reshape([ multiplicity(1:end-1); ones(1,size(multiplicity,2)-1)],1,[]) multiplicity(end)];
    end
    knots_new{d} = repelem(unique_knots,multiplicity);
    knots_unique{d} = unique_knots;
    M_d_subd{d} = oslo1_global(p(d),knots{d},knots_new{d});
end
M = 1; for d=1:2, M = kron(M_d_subd{d},M); end
points(:,1:3) = points(:,1:3).*points(:,4);
points = M'*points;
points(:,1:3) = points(:,1:3)./points(:,4);
subplot(1,2,2);
s = plot(C(:,1),C(:,2),'LineWidth',2,'Color',[0 0 0]);
for d=1:2, knots_unique{d} = knots_unique{d}(2:end-1); end
temp = [reshape(repmat(knots_unique{1},n_samples,1),[],1) reshape(repmat(grid_samples{2},1,numel(knots_unique{1})),[],1);
        reshape(repmat(grid_samples{1},1,numel(knots_unique{2})),[],1) reshape(repmat(knots_unique{2},n_samples,1),[],1)];
C = bivariate_NURBS(temp,p,knots_new,points(:,1:3),points(:,4),cellfun(@numel,knots_new)-p-1);
hold on;
plot(reshape([reshape(C(:,1),n_samples,[]);nan(1,sum(cellfun(@numel,knots_unique)))],[],1)',reshape([reshape(C(:,2),n_samples,[]);nan(1,sum(cellfun(@numel,knots_unique)))],[],1)','Color',[0 0.45 0.75]);
hold off;
axis equal;
xlim([-8 0]); ylim([0 8]);
box on;
xlabel('$x$','Interpreter','latex');
ylabel('$y$','Interpreter','latex');

grid_data.grid_2.x_grid = reshape([reshape(C(:,1),n_samples,[]);nan(1,sum(cellfun(@numel,knots_unique)))],[],1)';
grid_data.grid_2.y_grid = reshape([reshape(C(:,2),n_samples,[]);nan(1,sum(cellfun(@numel,knots_unique)))],[],1)';
grid_data.grid_2.x_boundary = s.XData;
grid_data.grid_2.y_boundary = s.YData;

clearvars -except grid_data;

jsonStr = jsonencode(grid_data);

fid = fopen('grid_2D.json','w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,jsonStr,'char');
fclose(fid);
