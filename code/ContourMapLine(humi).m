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

% Set reasonable humidity range
min_humi = min(humiData);
max_humi = max(humiData);

% Reshape humidity data into column vector
Z_known = humiData([2; 4; 6; 8]);

% Combine known and unknown points' coordinates
x_all = [x_known, x_unknown];
y_all = [y_known, y_unknown];

% Interpolate to estimate values at unknown points
Z_estimated = griddata(x_known, y_known, Z_known, x_unknown, y_unknown, 'nearest');

% Combine known and estimated data
Z_all = [Z_known(:); Z_estimated(:)];

% Create interpolation grid
[Xq, Yq] = meshgrid(0:10:990, 0:10:815);

% Interpolate over combined points for smoother grid
Zq = griddata(x_all, y_all, Z_all, Xq, Yq, 'cubic');

% Fill NaN values in grid
Zq_filled_X = fillmissing(Zq, 'linear', 2);  % Fill along X-axis
Zq_filled = fillmissing(Zq_filled_X, 'linear', 1);  % Fill along Y-axis

% Set humidity limits to avoid outliers
Zq_clipped = max(min(Zq_filled, 100), min_humi - 5);

% Plot contour map
figure;
[C, h] = contour(Xq, Yq, Zq_clipped, 5);  % Draw contour with 5 levels
colormap(jet);
colorbar;
title('Humidity');
xlabel('X axis');
ylabel('Y axis');

% Label contour lines
clabel(C, h, 'FontSize', 10, 'Color', 'black');

% Label measurement points with data values
hold on;
for i = 1:length(x_known)
    text(x_known(i), y_known(i), sprintf('%.1f%%', Z_known(i)), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', 10, 'Color', 'black', 'FontWeight', 'bold');
end

hold off;