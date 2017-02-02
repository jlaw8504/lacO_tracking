function [mean_r_x, indiv_r] = distance_rate_analysis(directory)
%% Parse GFP1 and GFP2 coordinates
%get list of all subdirectories of current directory
dirs = subdiralt(directory);
%instantiate the dist and deltadist variables
distance = [];
deltadist = [];
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
            distance = [distance;GFP_dist(1:(end-1),1)];
            % Push delta distances to deltadist
            deltadist = [deltadist;diff(GFP_dist,stride)];
        else     
        end
        
    end
end
%Return to original directory
cd(directory);
%% Plot the change in distance vs distance
%Separate out the negative and positive rates
distance = distance * pixel;
slength = distance;
deltadist = deltadist * pixel;
normdist = deltadist./slength *100;
negidx = deltadist < 0;
posidx = deltadist >= 0;
grow = deltadist(posidx);
mean(grow)
shrink = deltadist(negidx);
mean(shrink)
growlength = slength(posidx);
shrinklength = slength(negidx);
percent_increase = normdist(posidx);
percent_decrease = normdist(negidx);
%% Plot initial length vs percent change
figure;
scatter(growlength,percent_increase);
xlabel('Initial Distance (nm)');
ylabel('Percent Change');
hold on;
scatter(shrinklength,percent_decrease);
hold off;
%% Plot initial length vs change per timestep
figure;
scatter(growlength,grow);
xlabel('Initial Distance (nm)');
ylabel('Change per Timestep (nm)');
hold on;
scatter(shrinklength,shrink);
hold off;