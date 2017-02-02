function [init_length, delta, percent_change] = dist_delta_sim_batch(stride,directory)

%% Parse the directory
fileList = dir(directory);
for n = 1:64
    fileName = strcat(directory,'/','coord_summ',num2str(n),'.csv');
    matrix(:,:,n) = csvread(fileName,1,0);
end
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


