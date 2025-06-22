% ThingSpeak Channel configuration
channelID = 'channelID';  % Replace with your Channel ID
readAPIKey = 'readAPIKey';  % Replace with your Read API Key

% Read data from ThingSpeak
try
    humiData = thingSpeakRead(channelID, 'Fields', 1:8, 'NumPoints', 1, 'ReadKey', readAPIKey);
catch
    error('Unable to read data from ThingSpeak. Please verify Channel ID and API Key.');
end

% Ensure data is not empty
if isempty(humiData)
    error('No data available.');
end

% Known humidity points' coordinates
x_known = [303, 712, 712, 303];
y_known = [615, 415, 215, 15];

% Unknown points' coordinates
x_unknown = [712, 303, 303, 712];
y_unknown = [615, 415, 215, 15];

% Combine known and unknown points' coordinates
x_all = [x_known, x_unknown];
y_all = [y_known, y_unknown];

% Set reasonable humidity range
min_humi = min(humiData);
max_humi = max(humiData);

% Create 2D grid for interpolation
[Xq, Yq] = meshgrid(0:10:990, 0:10:815);

% Reshape humidity data into column vector
Z_known = humiData([2; 4; 6; 8]);

% Interpolate to estimate values at unknown points
Z_estimated = griddata(x_known, y_known, Z_known, x_unknown, y_unknown, 'nearest');

% Combine known and estimated data
Z_all = [Z_known(:); Z_estimated(:)];

% Interpolate over combined points for smoother grid
Zq = griddata(x_all, y_all, Z_all, Xq, Yq, 'cubic');

% Fill NaN values in grid
Zq_filled_X = fillmissing(Zq, 'linear', 2);  % Fill along X-axis
Zq_filled = fillmissing(Zq_filled_X, 'linear', 1);  % Fill along Y-axis

% Set humidity limits to avoid outliers
Zq_clipped = max(min(Zq_filled, max_humi), min_humi - 3);

Z_offset = max_humi + 1;

% Plot 3D surface
figure;
surf(Xq, Yq, Zq_clipped);
shading interp;
colormap jet;
colorbar;
caxis([min_humi - 10 100]);

% Set plot labels and title
title('Humidity');
xlabel('X axis');
ylabel('Y axis');
zlabel('Humidity (%)');

% Adjust view angle
view(30, 60);

hold on;

% Label known points with humidity values
for i = 1:length(x_known)
    text(x_known(i), y_known(i), Z_offset, ...
        sprintf('%.1f', Z_known(i)), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', 10, 'Color', 'black', 'FontWeight', 'bold');
end

% Set axis limits
xlim([0, 990]);
ylim([0, 815]);
zlim([min_humi - 20, 100]);

hold off;