function [distance, deltadist, normdelta, lengthStds, distPopStd, F] = distance_rate_clustering(stride,pixel,directory)
%% Parse GFP1 and GFP2 coordinates
%get list of all subdirectories of current directory
dirs = subdiralt(directory);
%instantiate counter
m = 1;
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
            distance{m} = (GFP_dist(1:(end-1),1)) * pixel;
            % Push delta distances to deltadist
            deltadist{m} = diff(GFP_dist) * pixel;
            normdelta{m} = (deltadist{m}./distance{m}) * 100;
        else
            %             for i = 1:stride
            % redo dist set based on stride
            GFP_temp = GFP_dist(1:stride:end) * pixel;
            %calculate the difference in new array
            GFP_temp_delta = diff(GFP_temp) * pixel;
            %remove first entry
            GFP_temp = GFP_temp(1:(end-1));
            %vertcat across stride start positions
            distance{m} = GFP_temp;
            deltadist{m} = GFP_temp_delta;
            normdelta{m} = (GFP_temp_delta./GFP_temp) * 100;
        end
        m = m+1;
    end
end
%Calc std deviation for each timelapse
lengthStds = cell2mat(cellfun(@(x) std(x,1,'omitnan'),distance, 'UniformOutput',false));
%Calc std deviation for entire population
distMat = cell2mat(distance);
distPopStd = std(distMat(:),1,'omitnan');
% Return to original directory
cd(directory);
% Plot the data one cell at a time
figure;
scatter(distance{1},deltadist{1});
xlabel('Sister Separation (nm)');
ylabel('Change Per Timestep (nm)');
axis([min(cell2mat(distance(:))) max(cell2mat(distance(:))) min(cell2mat(deltadist(:))) max(cell2mat(deltadist(:)))]);
F(1) = getframe(gcf);
hold on;
for n = 2:length(deltadist)
    waitforbuttonpress;
    scatter(distance{n},deltadist{n});
    xlabel('Sister Separation (nm)');
    ylabel('Change Per Timestep');
    axis([min(cell2mat(distance(:))) max(cell2mat(distance(:))) min(cell2mat(deltadist(:))) max(cell2mat(deltadist(:)))]);
    F(n) = getframe(gcf);
end
hold off;
