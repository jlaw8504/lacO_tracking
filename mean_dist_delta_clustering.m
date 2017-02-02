function [mean_distance, mean_deltadist, mean_normdist] = mean_dist_delta_clustering(stride,pixel,directory)
%% Parse GFP1 and GFP2 coordinates
%get list of all subdirectories of current directory
dirs = subdiralt(directory);
%instantiate the dist and deltadist variables
mean_distance = [];
mean_deltadist = [];
for n=1:length(dirs)
    cd(dirs{n});
    files = dir('GFP_*.xls');
    if length(files) == 2
        GFP1 = xlsread(files(1).name);
        GFP2 = xlsread(files(2).name);
        GFP1_coords = GFP1(:,2:3);
        GFP2_coords = GFP2(:,2:3);
        %% Calculate the distance between the points
        GFP_sub = GFP1_coords - GFP2_coords;
        GFP_sub_sq = GFP_sub.^2;
        GFP_dist = sqrt(GFP_sub_sq(:,1) + GFP_sub_sq(:,2));
        if stride ==1
            % Push distances(minus first entry) to dist
            mean_distance = [mean_distance;mean(GFP_dist(1:(end-1),1))];
            % Push delta distances to deltadist
            mean_deltadist = [mean_deltadist;mean(diff(GFP_dist,stride))];
        else
            mean_dist_temp = [];
            mean_delta_temp = [];
%             for i = 1:stride
                % redo dist set based on stride
                GFP_temp = GFP_dist(1:stride:end);
                %calculate the difference in new array
                GFP_temp_delta = diff(GFP_temp);
                %remove first entry
                GFP_temp = GFP_temp(1:(end-1));                
                %vertcat across stride start positions
                mean_dist_temp = [mean_dist_temp;mean(GFP_temp)];
                mean_delta_temp = [mean_delta_temp;mean(GFP_temp_delta)];
%             end
            % Push distances(minus first entry) to dist
            mean_distance = [mean_distance;mean_dist_temp];
            % Push delta distances to deltadist
            mean_deltadist = [mean_deltadist;mean_delta_temp];
        end
        
    end
end
%Return to original directory
cd(directory);
%% Plot the change in distance vs distance
%Separate out the negative and positive rates
mean_distance = mean_distance * pixel;
mean_slength = mean_distance;
mean_deltadist = mean_deltadist * pixel;
mean_normdist = mean_deltadist./mean_slength *100;
%% Plot mean initial length vs mean percent change
figure;
scatter(mean_distance,mean_normdist);
xlabel('Initial Distance (nm)');
ylabel('Percent Change');
%% Plot initial length vs change per timestep
figure;
scatter(mean_distance,mean_deltadist);
xlabel('Initial Distance (nm)');
ylabel('Change per Timestep (nm)');