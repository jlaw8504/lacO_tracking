function [init_length, delta, percent_change] = dist_delta_sim(stride,directory)

%% Parse the directory
fileList = dir(directory);
for n = 1:64
    fileName = strcat(directory,'/','coord_summ',num2str(n),'.csv');
    matrix(:,:,n) = csvread(fileName,1,0);
end
%% Trim selected number of timepoints from the simulation
[time,~,~] = size(matrix);
prompt = ['Your files have',' ', num2str(time),' ',...
    'timepoints. How many initial timepoints should we disregard?\n'];
offset = input(prompt);
matrix = matrix((offset + 1):end,:,:);
%% Calculate and display the average correlation coefficient of sister strands
for i = 1:32
    iMod = mod(i,2);
    if iMod == 1
        subMatX_sister_sq = (matrix(1:stride:end,2,i) - matrix(1:stride:end,2,(i+1))).^2;
        subMatY_sister_sq = (matrix(1:stride:end,3,i) - matrix(1:stride:end,3,(i+1))).^2;
        subMatZ_sister_sq = (matrix(1:stride:end,4,i) - matrix(1:stride:end,4,(i+1))).^2;
        sister_dist(:,i) = sqrt(subMatX_sister_sq + subMatY_sister_sq...
            + subMatZ_sister_sq);
    else
        subMatX_sister_sq = (matrix(1:stride:end,2,i) - matrix(1:stride:end,2,(i-1))).^2;
        subMatY_sister_sq = (matrix(1:stride:end,3,i) - matrix(1:stride:end,3,(i-1))).^2;
        subMatZ_sister_sq = (matrix(1:stride:end,4,i) - matrix(1:stride:end,4,(i-1))).^2;
        sister_dist(:,i) = sqrt(subMatX_sister_sq + subMatY_sister_sq...
            + subMatZ_sister_sq);
    end
    
end
delta = diff(sister_dist,1,1);
init_length = sister_dist(1:(end-1),:);
% Convert from m to nm
delta = delta*10^9;
init_length = init_length*10^9;
% normalize to percent change
percent_change = (delta./init_length) *100;
neg_idx = percent_change < 0;
pos_idx = percent_change >= 0;
percent_increase = percent_change(pos_idx);
percent_decrease = percent_change(neg_idx);
grow_length = init_length(pos_idx);
shrink_length = init_length(neg_idx);
pos_delta = delta(pos_idx);
neg_delta = delta(neg_idx);
%% Plot percent change versus inital length
figure;
hold on;
scatter(grow_length,percent_increase);
scatter(shrink_length,percent_decrease);
title(strcat('Stride:',num2str(stride)));
xlabel('Initial Sister Distance');
ylabel('Percent Change');
hold off;
%% Plot change per timestep versus inital length
figure;
hold on;
scatter(grow_length,pos_delta);
scatter(shrink_length,neg_delta);
title(strcat('Stride:',num2str(stride)));
xlabel('Initial Sister Distance');
ylabel('Change per Timestep');
hold off;
